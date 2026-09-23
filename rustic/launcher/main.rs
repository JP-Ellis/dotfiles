//! Runs ~/.local/bin/rustic-scheduled as a child process for the rustic
//! LaunchAgents.
//!
//! macOS privacy controls attribute a child's file access to the process launchd
//! started. Spawning (not exec'ing) the shell keeps this signed binary as that
//! process, so access granted to RusticScheduled.app covers the backup without
//! extending to every /bin/sh script.
//!
//! Standard library only, so `rustc main.rs` builds it without cargo.

use std::env;
use std::os::unix::process::ExitStatusExt;
use std::path::Path;
use std::process::{Command, ExitCode};
use std::sync::atomic::{AtomicI32, Ordering};

const SIGHUP: i32 = 1;
const SIGINT: i32 = 2;
const SIGTERM: i32 = 15;

unsafe extern "C" {
    fn signal(sig: i32, handler: extern "C" fn(i32)) -> usize;
    fn kill(pid: i32, sig: i32) -> i32;
}

static CHILD: AtomicI32 = AtomicI32::new(0);

// launchd stops a job with SIGTERM; pass it on so rustic exits cleanly and the
// wrapper's trap releases the repository lock.
extern "C" fn forward(sig: i32) {
    let pid = CHILD.load(Ordering::SeqCst);
    if pid > 0 {
        unsafe { kill(pid, sig) };
    }
}

fn main() -> ExitCode {
    let Some(home) = env::var_os("HOME") else {
        eprintln!("rustic-scheduled: HOME is unset");
        return ExitCode::FAILURE;
    };
    let script = Path::new(&home).join(".local/bin/rustic-scheduled");

    for sig in [SIGHUP, SIGINT, SIGTERM] {
        unsafe { signal(sig, forward) };
    }

    let mut child = match Command::new("/bin/sh")
        .arg(&script)
        .args(env::args_os().skip(1))
        .spawn()
    {
        Ok(child) => child,
        Err(err) => {
            eprintln!("rustic-scheduled: spawn /bin/sh: {err}");
            return ExitCode::FAILURE;
        }
    };
    CHILD.store(child.id() as i32, Ordering::SeqCst);

    let status = match child.wait() {
        Ok(status) => status,
        Err(err) => {
            eprintln!("rustic-scheduled: wait: {err}");
            return ExitCode::FAILURE;
        }
    };

    let code = status
        .code()
        .or_else(|| status.signal().map(|sig| 128 + sig))
        .unwrap_or(1);
    ExitCode::from(code as u8)
}

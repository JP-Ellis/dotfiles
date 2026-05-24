# CLAUDE.md

RTK is used to optimise token usage across all commands. Compatible commands are automatically rewritten with a hook. Avoid filtering commands with `grep` as RTK should have abbreviated the output already. Only use `rtk proxy` if was a last resort if you must get the full output.

## Tool Usage

-   **Prefer dedicated file tools over bash.** Use Read, Grep, and Glob for reading and searching files rather than `cat`, `sed`, `head`, `tail`, or `find` in bash. Only reach for bash when you need shell execution (build, test, git, etc.).
-   **Capture long command output before grepping.** For commands that take more than a few seconds, redirect to a temp file first: `command > /tmp/out.log 2>&1`, then `grep` the file. Don't re-run slow commands just to filter their output.

## Git Workflow

-   **Never push without an explicit user request.** After committing, stop and let the user vet the result before it goes to the remote.
-   Prefer explaining the intent of a change in the commit, not the implementation details.

## Code Style

-   **No change-explanation inline comments.** Don't annotate code with comments explaining what changed or why (e.g. `/* darkened from 0.56 — was failing WCAG AA */`). That context belongs in the commit message or PR description, not in the source.
-   **Section markers:** use `# MARK: SectionName` in config and source files, not `# === SectionName ===`. VSCode highlights `MARK:` in the minimap and outline panel for faster navigation.

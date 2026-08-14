# CLAUDE.md

RTK is used to optimise token usage across all commands. Compatible commands are automatically rewritten with a hook. Avoid filtering commands with `grep` as RTK should have abbreviated the output already. Only use `rtk proxy` as a last resort if you must get the full output.

## Writing

These rules bind everything you produce: chat replies, code comments, docs, commit messages, PR bodies. No exceptions.

- End on the specific thing. Never close with a general truth about its category.
- Drop "X rather than Y" and "X, not Y" constructions. State X. Stop.
- Use `the` only for a noun already introduced. A fresh noun takes `a`, or gets named properly.
- Use simple past for past events: "marked", never "was marking".
- Name the referent. Ban "that job", "this pattern", "that asymmetry".
- Give objects no intentions and no strength. A comma does no job.
- One idea per sentence. If a sentence hinges on "and", split it and cut the decorative half.

## Tool Usage

- **Prefer dedicated file tools over bash.** Use Read, Grep, and Glob for reading and searching files rather than `cat`, `sed`, `head`, `tail`, or `find` in bash. Only reach for bash when you need shell execution (build, test, git, etc.).
- **Capture long command output before grepping.** For commands that take more than a few seconds, redirect to a temp file first: `command > /tmp/out.log 2>&1`, then `grep` the file. Don't re-run slow commands just to filter their output.

## Git Workflow

- **Never push without an explicit user request.** After committing, stop and let the user vet the result before it goes to the remote.
- Explain the intent of a change in the commit. Leave implementation details out.

## Code Style

- **Describe the present.** Comments, READMEs, and docs state what the code does now, plus why when the reason is non-obvious.
- **Keep history out of the codebase.** How something reached its present shape belongs in commit messages and PR bodies. Never write `/* darkened from 0.56 — was failing WCAG AA */`, "refactored from X, Y and Z", or "adopted from our previous stack" into a source or docs file.
- **Section markers:** use `# MARK: SectionName` in config and source files. Avoid `# === SectionName ===`. VSCode highlights `MARK:` in the minimap and outline panel for faster navigation.

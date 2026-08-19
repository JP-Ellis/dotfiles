# CLAUDE.md

RTK abbreviates command output through a hook, so do not pipe that output through `grep`. Use `rtk proxy` only when you need the untrimmed version. Redirect a slow command to a file in the scratchpad, then search the file. Never re-run a slow command to filter it.

## Writing

Applies to chat, comments, docs, commit messages, PR bodies.

- Close on a concrete detail. No closing moral about the category.
- State the choice. Cut "X rather than Y" and "X, not Y".
- Name the thing. No bare "that job", "this pattern", "that asymmetry".
- Inanimate things take no agency. A comma does no job.
- One idea per sentence. Split on "and"; keep both halves when both carry information.

## Git

- Never push unless asked.
- A commit message explains the intent of its own change. Give it the depth it needs — git history outlives any forge.
- A PR body explains the arc across its commits: the goal, the sequence, the alternatives weighed.

## Code Style

- Comments and docs describe current behaviour. Give a reason only when it is non-obvious, in one to three lines.
- Keep history, process and README restatement out of source and docs files. That material belongs in commit messages and PR bodies. A historical reason that constrains present code stays: a compat shim, an upstream workaround.
- Section markers: `# MARK: Name`.

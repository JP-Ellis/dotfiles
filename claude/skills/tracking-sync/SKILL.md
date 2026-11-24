---
name: tracking-sync
description: Use when a repository's tracking records need reconciling against work that has landed — forge issues and epics, roadmap files, agent instruction files, Markdown docs, agent memory — when merged branches and worktrees need clearing, or when choosing what to start next. Triggers on "sync the roadmap", "are the docs still accurate", "update the tracking issues", "is this issue still worth fixing", "prune the backlog", "prune stale memories", "clean up branches", "what should I work on next", or a periodic check-in after several PRs have merged.
---

# tracking-sync

## Overview

A repository's state is described in several records, and each one drifts: the
forge's issues and epics, roadmap files, the agent instruction files
(`CLAUDE.md`, `AGENTS.md`), the Markdown docs, the agent memory, and the
branches and worktrees themselves. This skill reads what has landed since the
last run and proposes a single reconciling change set.

**Nothing is written until the user approves.** The run's product is a proposal.

Two rules decide what a record may say:

- **Docs, roadmaps and memory describe the present.** A finished item is
  deleted. A sentence about how things used to be is deleted.
- **Tracking issues keep history.** A finished sub-item is ticked, never
  removed.

## Files

Per-repository files live in `<common>/tracking-sync/`, where `<common>` is

```sh
git rev-parse --path-format=absolute --git-common-dir
```

Git never commits that directory, and every worktree of the repository shares
it.

| File | Holds |
| --- | --- |
| `profile.md` | What this repository tracks and where. Format in [profile.md](profile.md). |
| `state.json` | Watermarks: `{"repos": {".": "<sha>", "<nested path>": "<sha>"}, "last_run": "<ISO time>", "audit_cursor": <issue number>}` |
| `forge-index.txt` | On Forgejo, every issue and PR number with its state as of the last applied run. |
| `next-sessions.md` | The brainstorm prompts from Step 6. |

Arguments: `--since <ref|date>` overrides the watermark for this run. `--full`
sweeps every Markdown file. `--agents <n>` caps the subagents Step 2 dispatches.
`--next` runs Step 6.

## Step 0 — Profile and state

Read `profile.md`. If it does not exist, build it by following
[profile.md](profile.md), show it to the user, and write it once they confirm
it. The profile is the one file written before Step 4.

Read `state.json`. If it does not exist, this is the first run: use the last 14
days as the window and say so.

The profile's **Private material** section binds every later step. The agent
and its subagents read those files freely on this machine. Their text reaches
an issue, a PR or a commit only in the form that section allows.

## Step 1 — Gather

Fetch first, so the default branch and the remote branch list are current:

```sh
git fetch --prune
```

`<default>` is a repository's default branch name. `<tip>` is
`origin/<default>`, or `<default>` itself in a repository with no remote. The
window runs from each watermark to `<tip>`, whichever branch is checked out.
For the main repository and each nested repository in the profile:

```sh
git -C <repo> log <watermark>..<tip> --format='%h %s'
git -C <repo> log <watermark>..<tip> --name-only --format= | sort -u
```

When the profile names a forge, build its three artefacts with the commands in
[forge.md](forge.md): the **issue dump** (every issue, open and closed, with
bodies), the **window lists** (PRs merged, issues filed, issues closed) and,
on Forgejo, the forge index. A first run already built the issue dump in
Step 0; reuse it.

Issues filed or closed in the window are landed work too. The dedup check, the
checklist sweep and the backlog audit all search the issue dump.

From the window's commits and PR bodies, list every issue they cite without
closing it: `Refs #N`, `Part of #N`, "tracks #N", or a bare `#N`. A fix that
only references its issue leaves the issue open with the problem gone.

Reduce the touched paths to owning areas (a crate, a package, a docs
subdirectory). That set decides which documents Step 2 reads.

Gather the cleanup evidence by following [cleanup.md](cleanup.md). It needs no
subagent.

If the worktree is dirty, say so before proceeding. This run's edits cannot
otherwise be told from what was already there.

If the window is empty, say so in one line. Run only the cleanup and the
backlog audit's rolling slice.

## Step 2 — Review streams

Five streams review the records. Skip a stream whose record the profile says
the repository does not have. Each stream returns *proposed* edits as text. No
stream applies anything, commits, or moves `HEAD`.

| Stream | Model tier | Reads | Brief |
| --- | --- | --- | --- |
| Local records | middle | the profile's local records | Maintain each file as the profile says. For a roadmap: delete completed items, keep one line only where a finished item still constrains what comes next, and correct claims the landed work falsifies. |
| Public tracking | middle | the profile's tracking issues, the issue dump | [public-tracking.md](public-tracking.md) |
| Backlog audit | strongest | the issue dump, the tree on the default branch | [backlog-audit.md](backlog-audit.md) |
| Docs | cheapest | instruction files and the touched-area Markdown from the profile's doc roots, or all of it under `--full`; symlinks resolved, historical artefacts left out | [docs-and-memory.md](docs-and-memory.md) |
| Memory | cheapest | the memory directory this session's context names | [docs-and-memory.md](docs-and-memory.md) |

### Sizing the dispatch

Size the dispatch to the reading each stream has to do. A subagent earns its
cost in two ways: it keeps a large read out of this context, and it runs
beside the others. Every subagent also re-reads its brief and reference file,
and returns a summary that drops detail.

- **Do a stream inline** when its whole input is small: a handful of memory
  files, one short roadmap, two or three touched documents, an audit set of
  five issues. Follow the stream's reference file yourself.
- **Give a stream one subagent** when its input would crowd this context but
  fits comfortably in one agent's.
- **Split a stream** only when one agent could not hold its input, or the
  parts share nothing. Split docs by owning area and the audit by subsystem,
  so each agent reads shared code once. Several documents or a few dozen
  issues per agent is normal.
- **Merge small streams** into one subagent when they run on the same tier.
  Docs and memory share a reference file.

`--agents <n>` caps the subagent count, and `--agents 0` runs every stream
inline. Without it, plan the dispatch and state it in one line before
starting: which streams run inline and how many subagents the rest take. A
plan above six subagents waits for the user's yes.

Dispatch the subagents in **one message** so they run concurrently. Each brief
contains the landed-work list from Step 1, the relevant profile sections, and
the absolute path of the stream's reference file. The stream reads the
reference file itself. No stream re-derives the landed work.

Files under the profile's **Read-only inputs** are evidence. No stream proposes
an edit to one.

## Step 3 — Spot-check

Dispatch a cheapest-tier subagent to grep the tree and confirm a claim before
it is marked done in two cases: the user asks, or the claim is an epic close or
a roadmap phase transition. Every other claim trusts the commit and issue
record. Do not run the test suite.

## Step 4 — Propose

One consolidated proposal in chat:

- file edits as diffs, grouped by document;
- issue actions as `#N — tick / comment / retitle / merge / close`, each with
  its evidence;
- the backlog audit as one table, close and merge candidates first, every row
  carrying its trigger-and-impact sentence;
- memory deletions and rewrites, each with its reason;
- cleanup in three groups: local removals, **remote branch deletions**, and
  items flagged without a proposal. Each row carries its evidence.

Then stop and wait. Remote branch deletions need their own explicit yes. A
general "go ahead" covers every other group.

## Step 5 — Apply

On approval, in this order:

1. Fast-forward the local default branch if the cleanup proposed it. Then
   write the file edits. Leave them **dirty in the worktree**: no commit, no
   branch, no push.
2. Post the issue updates with the write commands in [forge.md](forge.md).
3. Delete and rewrite the memory files. Remove the index line of every deleted
   file.
4. Run the approved cleanup. Re-run each item's evidence commands immediately
   before removing it, because the evidence predates the user's reply.
5. On Forgejo, copy this run's forge index over the saved one. Write
   `state.json`: each repository's `<tip>` SHA as read in Step 1, the timestamp, and `audit_cursor` set to the highest issue number in
   this run's rolling slice.

A partly approved run still advances the watermarks. The window has been
reviewed, and a declined item is an outcome.

An abandoned or unapproved run leaves `state.json` untouched.

If the forge was unreachable, apply everything else, say the forge half was
skipped, and leave the watermarks and the forge index where they were.

## Step 6 — Next tasks

Run this step when `--next` was passed or the user asks. Otherwise end the
Step 5 report with one line offering it. Follow [handover.md](handover.md).

## Red flags

| Thought | Reality |
| --- | --- |
| "This edit is obviously right, I'll just apply it" | The product is the proposal. Step 4 gates every write. |
| "I'll note in the roadmap that this shipped in PR #N" | Roadmaps keep no history. Delete the item. |
| "This doc paragraph on the old behaviour is useful context" | Docs describe the present. Propose its deletion unless the profile lists the file as a historical artefact. |
| "The epic's sub-items look stale, I'll tidy the body" | Issues keep history. Tick, never delete. |
| "I'll commit the doc fix, it's trivial" | The run never moves `HEAD`. Leave it dirty. |
| "The nested repo's commits will show in the main log" | It is a separate repository. Log it with `git -C`. |
| "The forge is hanging, I'll skip the issues and finish" | Finish the rest and hold the watermarks, or the window is lost. |
| "This memory is probably still true" | If nothing in the tree or the issues still supports it, it is stale. |
| "No open issue matched my keyword, so it is unfiled" | One keyword over open issues is not a dedup. Search the issue dump on symbol, file and paraphrases. |
| "`git log main..branch` shows commits, so the branch is unmerged" | A rebase or squash changes the SHA. Run the three landed tests in cleanup.md. |
| "`git cherry` shows `+`, so the branch is unmerged" | A squash of several commits has a new patch-id. Run the other two tests. |
| "The tip is in main's history, so the branch has landed" | A branch created a minute ago looks the same. Without a merged PR it is an empty branch: flag it. |
| "The branch landed, so `git branch -d`" | `-d` refuses a rebase or squash merge. Use `-D` once a landed test has passed. |
| "The user approved the proposal, so the remote branches can go" | Remote deletions need their own yes. |
| "The PR lists it as a follow-up, so it needs an issue" | Pass the filing gate first. |
| "Nothing in the window touched this issue, so it is still accurate" | Neighbouring work removes premises silently. The rolling slice re-reads it. |
| "The fix commit says `Refs #N`, so the issue tracks leftovers" | Read the issue against the default branch. Usually the fix covered it. |
| "The task looks small, I'll dispatch it" | Dispatch needs all four bounded tests in handover.md and the user's yes. |

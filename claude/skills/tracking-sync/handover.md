# Next tasks and handover

## Candidates

Draw candidates from three places:

- the backlog audit's FIX and SHOULD-HAVE-FIXED rows;
- the next unstarted items in the profile's local records and tracking root;
- KEEP rows the roadmap or root puts next in order.

Offer at most five. Order them by the repository's own ordering record when it
has one, then by impact.

## Classify each candidate

A candidate is **bounded** when all four hold:

1. the outcome is stated as an observable result;
2. the code location is named;
3. a command or check verifies it;
4. no design decision is open.

Every other candidate is **open-ended**.

Present the candidates as one table: candidate, class, the test it fails if
open-ended, and the proposed handover.

## Bounded: the issue is the handover

If the candidate has no issue, or its issue does not show all four points,
propose the issue text first: outcome, location, verification, and "no open
decisions". Post it on approval, as a new issue or an edit, through the filing
gate and the private-material rule.

Then ask one question: dispatch subagents for the bounded candidates now, or
leave them as ready issues.

On a yes:

- Dispatch only candidates whose likely footprints are apart. Hold back one of
  any pair that would rework the same code, and say which.
- One subagent per candidate, all in one message.
- Each subagent works in its own worktree at the profile's worktree location
  (`default` means the harness's own worktree isolation), on its own branch.
  No subagent works in the primary checkout.
- The brief is the issue number, the four points, the branch name and the
  worktree path. The subagent reads the issue for the rest.
- The subagent commits on its branch and stops. It does not push, open a PR or
  close the issue unless the user's yes said so.

Report each result with its branch, its worktree path and the output of its
verification command.

## Open-ended: a brainstorm prompt

Write one copy-pasteable prompt per open-ended candidate to
`<common>/tracking-sync/next-sessions.md`, replacing the file's previous
contents, and print the prompts in chat. Each prompt:

- states the problem and links the issue or roadmap item;
- asks for a brainstorm of the problem and nothing further. The brainstorm
  decides whether a spec, a plan or code follows;
- leaves scope open. It lists no files the session may touch and no files
  another session owns;
- names its own worktree at the profile's worktree location, with a distinct
  name per prompt, so concurrent sessions stay off the primary checkout.

Choose prompts whose likely footprints are apart. Fold two tracks that would
rework the same code into one prompt, or hold one back. Open the file with one
sentence saying why the tracks are expected to stay apart.

When the user declines a brainstorm for a candidate that has an issue, propose
a comment on the issue naming the open decision, so the issue shows why it is
not yet bounded.

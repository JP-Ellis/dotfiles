# Backlog audit

An open issue drifts in two ways the window never shows. Neighbouring work
fixes it or removes its premise without closing it. Or it was never worth
fixing: a review-time follow-up whose trigger needs a contrived scenario.

## Choosing the audit set (dispatcher)

The audit set is the union of:

- **touched issues:** every open issue the window cited without closing, plus
  every open issue whose body names a file or symbol the window changed;
- **the rolling slice:** the next 15 open issues after `audit_cursor`, by
  number, wrapping to the lowest.

A repository with 30 or fewer open issues audits all of them every run and
keeps no cursor.

Step 2 of SKILL.md decides how many agents audit the set. When it is split,
split by subsystem so one agent reads the shared code once. Give each agent
its issue numbers, the path of the issue dump, the profile's filing gate, and
the path of this file.

## Auditing

You are read-only. For each issue, read it and its comments, check the code it
names on the default branch, and return one row:

`#N | verdict | trigger and impact in one sentence | evidence`

Evidence is a `file:line`, a commit or another issue.

| Verdict | Means |
| --- | --- |
| FIX | Real users hit it, or it gives wrong output or loses data. |
| KEEP | Wanted feature or tech debt, still accurate. |
| KEEP, retitle | Real, but the title or body no longer matches the code. Propose the new text. |
| CLOSE-TRIVIAL | Real, but it fails the filing gate. |
| SHOULD-HAVE-FIXED | Small work that belonged in its originating PR. Propose a small PR. |
| CLOSE-FIXED | Resolved on the default branch. Cite the commit. |
| CLOSE-OBSOLETE | The premise no longer holds: the code was removed or redesigned. |
| CLOSE-DUPLICATE | Another issue covers it. Name it. |
| MERGE → #N | A sibling issue covers the same work. List the requirements to fold into #N. |

Read the issue text adversarially. Filers overstate triggers. State the trigger
you can actually construct from the code.

A wrong-output or data-loss bug is never CLOSE-TRIVIAL, however rare its
trigger. Rarity excuses only cosmetic and friction bugs.

For every FIX and KEEP row, add one more field for the handover step:
`bounded: yes` when the issue already names the outcome, the code location and
a way to verify it, and leaves no design decision open. Otherwise write
`bounded: no — <what is missing>`.

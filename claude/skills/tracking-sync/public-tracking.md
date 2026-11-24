# Public tracking stream

You are read-only. Return proposed issue actions as text. Post nothing.

Your brief gives you the landed-work list, the profile's tracking issues, its
filing gate and its private-material rule, and the path of the issue dump.

Return four lists:

1. **Ticks and prose.** Sub-items the landed work completed, and tracking-issue
   prose it made wrong.
2. **Closes.** Issues the landed work resolved without closing, each with the
   commit or PR as evidence.
3. **New issues and comments.** Deferred work from the window's PR bodies that
   passes the filing gate and the dedup.
4. **Checklist sweep findings.**

Never propose deleting a checklist line. An epic's closed sub-items stay
ticked.

## Filing gate

PR bodies name deferred work in "not done", "follow-up" and "to be filed"
sections. A deferred item becomes an issue only when it passes the gate.

When the profile's filing gate points at a repository rule, apply that rule.
When it says `default`, the candidate must name the trigger and the outcome for
a real user of the project, and qualify on one of these:

- the outcome is wrong output, lost data, or a silent change to stored data,
  however rare the trigger;
- the trigger is ordinary use;
- it is a feature or tech-debt item the owner would schedule on its own merit.

Everything else stays in the PR body as a known limitation: a missing test with
no user-visible failure, a race that needs two concurrent writers, a parser
edge that fails loudly and writes nothing, a cosmetic glitch that clears on the
next action. A candidate whose own text says "rare", "unreachable" or "cosmetic
and safe" has failed the gate.

## Dedup

A new-issue proposal first proves the issue does not exist. The same PR that
named the deferred work often filed some of it already.

- Search the issue dump, open and closed, in title and body.
- Search on the symbol, the function, the file, and two or three paraphrases of
  the failure.
- Name the nearest existing issue and say why the candidate is not it. A
  candidate that is a facet of an open issue becomes a proposed comment on that
  issue.

Report each candidate with the search terms you tried.

## Checklist sweep

Run this over the root and **every** open epic, whatever the window touched.
Work mechanically from the issue dump:

- an unchecked box, or "still open" prose, pointing at a closed issue;
- a checked box pointing at an open issue;
- a reference that no longer resolves;
- an open issue whose body names a parent ("Part of #N") that does not list it;
- an open issue listed by no epic, the root or the catch-all. An epic that
  closed orphans its open children; propose a new parent for each.

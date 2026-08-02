---
name: secondary-review
description: Use when implementation work is finished and needs an independent review pass before it lands — a working diff about to become a PR, a branch ready to merge, or an open PR whose forge review comments need folding in
---

# Secondary Review

## Overview

An independent review pass run by two reviewers that differ in **what context they are given**, not just what they look for.

**Core principle:** a reviewer who knows what the change was *supposed* to do grades it against that intent and stops looking. A reviewer who knows nothing judges the code on its own terms. Running both, and reconciling where they disagree, catches what either alone misses.

## When to Use

- Implementation is complete and tests pass; before opening a PR or merging
- A PR is open and has forge review comments (Copilot, CodeRabbit, human) to reconcile
- After a large refactor, when you want a second opinion you didn't author

Prefer `superpowers:requesting-code-review` for a single task inside a plan. Use this when the whole change is done and a missed defect costs more than two reviewers.

**Not for:** work in progress, or when you want code *changed* — use `/simplify`. Also not for a branch that turned out to be several changes at once — see the cohesion gate.

## The Two Lenses

| | Blind | Sighted |
|---|---|---|
| **Gets** | The diff, and the surrounding code needed to understand it | The diff, plus issue, PR description, specs, project docs |
| **Asks** | "Is this code correct and well-made?" | "Is this the right change, and is it complete?" |
| **Catches** | Bugs, broken invariants, DRY violations, bad patterns | Missed requirements, scope creep, stale docs, wrong problem solved |

**Specs yes, plans no.** The sighted reviewer gets specs and requirements, never implementation plans.

## Roster

Two agents, both on Sonnet. One carries the whole blind lens, the other the whole sighted lens.

| Agent | Model | Covers |
|---|---|---|
| **Blind** | `sonnet` | correctness, failure-modes, test-quality, type-design, comment-drift |
| **Sighted** | `sonnet` | intent, coverage, doc-consistency |

Splitting these into one agent per aspect produced findings that mostly overlapped, at one full diff-and-codebase read each. The lens split is what changes findings; the aspect split only multiplied the bill. The aspects survive as checklists inside the two prompts.

Neither reuses `pr-review-toolkit`'s equivalent agents: those fetch PR context by design, which defeats the blind lens.

Forge comments are not an agent. Run `gh pr view --comments` (or the forge equivalent) yourself and reduce it to one line per comment as `file:line — claim`, with no judgement attached.

**Escalation, at most one extra agent.** A deep dive is a second, dedicated pass on an aspect the blind reviewer already covers — depth, not coverage:

- New or modified public types → **type-design**
- Diff is substantially comments, docstrings, or markdown → **comment-drift**

If both trigger, take the one the diff is more about. Never dispatch both.

Reviewers run on Sonnet, so the confidence filter below is doing real work rather than rubber-stamping. Do not skip it.

## Scope and Sizing

```bash
BASE=$(git merge-base origin/main HEAD)
HEAD=$(git rev-parse HEAD)
git diff --stat $BASE..$HEAD | tail -1
```

For **uncommitted** work, either commit first, or set `[HEAD_SHA]` to the literal string `(working tree)` in the templates — reviewers then use `git diff $BASE` with no second revision.

| Changed lines | Action |
|---|---|
| ≤ 1000 | Dispatch. No assessment. |
| > 1000 | Assess cohesion first — see below. |

Reconciling existing forge comments with no fresh review wanted: collect the comments and dispatch the blind reviewer only.

Dispatch selected agents in one message so they run concurrently.

## The Cohesion Gate

Above 1000 changed lines, a diff is as likely to be several changes wearing one branch as it is to be a large single change. Reviewing the first kind well is not possible — findings scatter, and the sighted lens has no single intent to review against.

Dispatch one `general-purpose` agent with `model: "haiku"`, giving it **only** `git diff --stat $BASE..$HEAD` and `git log --oneline $BASE..$HEAD`. Not the diff body — the gate must not cost what it is trying to save. Ask it to answer:

- Does this diff do one thing, or several unrelated things?
- If several: what are they, and which files belong to each?

If it reports one thing, dispatch the normal roster. If it reports several, **stop and do not dispatch**. Report the size, list the split points it named, and ask whether to split the branch or review it anyway. Proceed only on an explicit instruction to review anyway.

A large cohesive diff gets the same two reviewers as a small one. Size is a reason to question the change, not to buy more opinions about it.

## Dispatch

The blind reviewer uses [blind-reviewer.md](blind-reviewer.md); the sighted reviewer uses [sighted-reviewer.md](sighted-reviewer.md). Both are dispatched as `general-purpose` with `model: "sonnet"`.

**The blind prompt is the template verbatim with three substitutions: `[ASPECTS]`, `[BASE_SHA]`, `[HEAD_SHA]`. Nothing is added, no section is inserted, no sentence is rewritten.** `[ASPECTS]` gets every row of that file's aspect briefs table — all five — unless this is the deep-dive agent, which gets one. The sighted prompt is the template with its seven slots filled, `[ASPECTS]` likewise taking all three rows.

## Confidence Filter

Reviewers self-score, but **you re-score every finding** before it reaches the user — their scales are not calibrated against each other.

| Score | Meaning |
|---|---|
| 0 | False positive under light scrutiny |
| 25 | Might be real; could not verify |
| 50 | Verified real, but a nitpick or rare in practice |
| 75 | Verified, will be hit in practice, current approach insufficient |
| 100 | Confirmed by direct evidence |

Drop below 75. Re-score against the code, not against the reviewer's reasoning — a Sonnet reviewer that argues its way to 75 has still only argued. A finding you cannot reproduce from the diff yourself is a 25. Reviewers are already told to skip compiler-caught, untouched-line, vague, and explicitly-silenced issues; drop any that slip through, plus behaviour changes that are plainly the point of the change.

## Synthesis

Disagreements do not fall out of the reports — you produce them. Before writing the output, take each blind finding and re-check it yourself against the intent context. If the context explains it away, that is a disagreement, not a dismissal. Do the same in reverse for sighted findings with no corresponding code defect.

## Output Contract

Group by agreement, not by agent.

1. **Confirmed** — corroborated by both lenses or by an existing forge comment, or scored 100 on your own re-check. File:line, what's wrong, why it matters. With two reviewers this section is small; that is expected, not a sign the review was thin.
2. **Disagreements** — from the synthesis step above, with both positions stated. Highest value: a blind finding the context waves away usually means context is doing work the code should do itself; a sighted finding with no code defect behind it usually means a requirement nobody implemented.
3. **Single-source** — surviving findings from one agent, ranked.
4. **Forge overlap** — which existing PR comments the reviewers corroborated, and which they contradicted.
5. **Verdict** — ready to merge: yes / no / with fixes, in one sentence.

Do not post to the forge unless asked. Do not apply fixes as part of the review.

Hand findings to `superpowers:receiving-code-review` — verify before implementing, push back where a reviewer is wrong.

## Common Mistakes

| Mistake | Consequence |
|---|---|
| Pasting intent context into a blind prompt "for context" | Collapses two lenses into one; you paid for two reviewers and got one |
| Giving the sighted reviewer the implementation plan | Findings become "deviates from plan" rather than "is wrong" |
| Including a simplifier or fixer in the roster | A reviewer that edits invalidates the other reviewer's diff |
| Splitting an aspect out into its own agent "to be thorough" | The aspect is already in the blind prompt; you buy a duplicate diff read and duplicate findings |
| Reviewing a >1000-line diff that the gate called incoherent | Findings scatter across unrelated changes and the sighted lens has no intent to review against |

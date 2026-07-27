---
name: secondary-review
description: Use when implementation work is finished and needs an independent review pass before it lands — a working diff about to become a PR, a branch ready to merge, or an open PR whose forge review comments need folding in
---

# Secondary Review

## Overview

An independent review pass run by two populations of reviewers that differ in **what context they are given**, not just what they look for.

**Core principle:** a reviewer who knows what the change was *supposed* to do grades it against that intent and stops looking. A reviewer who knows nothing judges the code on its own terms. Running both, and reconciling where they disagree, catches what either alone misses.

## When to Use

- Implementation is complete and tests pass; before opening a PR or merging
- A PR is open and has forge review comments (Copilot, CodeRabbit, human) to reconcile
- After a large refactor, when you want a second opinion you didn't author

Prefer `superpowers:requesting-code-review` for a single task inside a plan. Use this when the whole change is done and a missed defect costs more than the fan-out.

**Not for:** work in progress, or when you want code *changed* — use `/simplify`.

## The Two Lenses

| | Blind | Sighted |
|---|---|---|
| **Gets** | The diff, and the surrounding code needed to understand it | The diff, plus issue, PR description, specs, project docs |
| **Asks** | "Is this code correct and well-made?" | "Is this the right change, and is it complete?" |
| **Catches** | Bugs, broken invariants, DRY violations, bad patterns | Missed requirements, scope creep, stale docs, wrong problem solved |

**Specs yes, plans no.** The sighted reviewer gets specs and requirements, never implementation plans.

## Roster

| # | Agent | Lens | Aspect |
|---|---|---|---|
| B1 | correctness | Blind | Logic errors, edge cases, DRY, patterns |
| B2 | failure-modes | Blind | Swallowed errors, silent failures |
| B3 | test-quality | Blind | Real assertions vs mocks and tautologies |
| B4 | type-design | Blind | Invariants, illegal states representable |
| B5 | comment-drift | Blind | Comments that no longer match the code |
| S1 | intent | Sighted | Solves the stated problem? Scope creep? |
| S2 | coverage | Sighted | Acceptance criteria actually tested? |
| S3 | doc-consistency | Sighted | Docs and specs this change just made wrong |
| C | forge | — | Existing PR review comments |

B2–B5 deliberately do not reuse `pr-review-toolkit`'s equivalent agents: those fetch PR context by design, which defeats the blind lens.

## Scope and Sizing

```bash
BASE=$(git merge-base origin/main HEAD)
HEAD=$(git rev-parse HEAD)
git diff --stat $BASE..$HEAD | tail -1
```

For **uncommitted** work, either commit first, or set `[HEAD_SHA]` to the literal string `(working tree)` in the templates — reviewers then use `git diff $BASE` with no second revision.

| Tier | Threshold (both conditions) | Roster |
|---|---|---|
| Forge-only | Reconciling existing comments, no fresh review wanted | C, B1 |
| Focused | ≤ 5 files **and** ≤ 200 changed lines | B1, S1 |
| Standard | ≤ 20 files **and** ≤ 800 changed lines | B1, B2, B3, S1, S2 |
| Broad | Anything larger | B1–B5, S1–S3 |

Take the first tier whose conditions both hold. Add regardless of tier:

- New or modified public types → **B4**
- Diff is substantially comments, docstrings, or markdown → **B5**
- An open PR exists → **C**

Dispatch every selected agent in one message so they run concurrently.

## Dispatch

Blind agents use [blind-reviewer.md](blind-reviewer.md); sighted agents use [sighted-reviewer.md](sighted-reviewer.md).

**The blind prompt is the template verbatim with four substitutions: `[ASPECT_NAME]`, `[ASPECT_BRIEF]`, `[BASE_SHA]`, `[HEAD_SHA]`. Nothing is added, no section is inserted, no sentence is rewritten.** The sighted prompt is the template with its eight slots filled.

Agent C needs no template. Run `gh pr view --comments` (or the forge equivalent) and return one line per comment as `file:line — claim`, with no judgement attached.

## Confidence Filter

Reviewers self-score, but **you re-score every finding** before it reaches the user — their scales are not calibrated against each other.

| Score | Meaning |
|---|---|
| 0 | False positive under light scrutiny |
| 25 | Might be real; could not verify |
| 50 | Verified real, but a nitpick or rare in practice |
| 75 | Verified, will be hit in practice, current approach insufficient |
| 100 | Confirmed by direct evidence |

Drop below 75. Reviewers are already told to skip compiler-caught, untouched-line, vague, and explicitly-silenced issues; drop any that slip through, plus behaviour changes that are plainly the point of the change.

## Synthesis

Disagreements do not fall out of the reports — you produce them. Before writing the output, take each blind finding and re-check it yourself against the intent context. If the context explains it away, that is a disagreement, not a dismissal. Do the same in reverse for sighted findings with no corresponding code defect.

## Output Contract

Group by agreement, not by agent.

1. **Confirmed** — flagged by two or more agents, or scored 100. File:line, what's wrong, why it matters.
2. **Disagreements** — from the synthesis step above, with both positions stated. Highest value: a blind finding the context waves away usually means context is doing work the code should do itself; a sighted finding with no code defect behind it usually means a requirement nobody implemented.
3. **Single-source** — surviving findings from one agent, ranked.
4. **Forge overlap** — which existing PR comments the reviewers corroborated, and which they contradicted.
5. **Verdict** — ready to merge: yes / no / with fixes, in one sentence.

Do not post to the forge unless asked. Do not apply fixes as part of the review.

Hand findings to `superpowers:receiving-code-review` — verify before implementing, push back where a reviewer is wrong.

## Common Mistakes

| Mistake | Consequence |
|---|---|
| Pasting intent context into a blind prompt "for context" | Collapses two lenses into one; you paid for eight agents and got four |
| Giving the sighted reviewer the implementation plan | Findings become "deviates from plan" rather than "is wrong" |
| Including a simplifier or fixer in the roster | A reviewer that edits invalidates every other reviewer's diff |

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

Forge comments are not an agent. Run `gh pr view --comments` (or the forge equivalent) yourself and reduce it to one line per comment as `file:line — claim`, with no judgement attached. Mark each one `forge-bot` or `forge-human`. Rejecting a human comment has to be said out loud; rejecting a bot comment does not.

**Escalation, at most one extra agent.** A deep dive is a second, dedicated pass on an aspect the blind reviewer already covers — depth, not coverage:

- New or modified public types → **type-design**
- Diff is substantially comments, docstrings, or markdown → **comment-drift**

If both trigger, take the one the diff is more about. Never dispatch both.

Reviewers run on Sonnet. The scoring pass below is doing real work. Do not skip it.

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

## Scoring

Every finding carries three independent scores. Reviewers self-score all three; **you re-score all three** before anything reaches the user, because the two reviewers' scales are not calibrated against each other.

**Confidence — is this real?** This axis, and only this axis, drops findings.

| Score | Meaning |
|---|---|
| 0 | False positive under light scrutiny |
| 25 | Might be real; could not verify |
| 50 | Verified real, but rare in practice |
| 75 | Verified, will be hit in practice, current approach insufficient |
| 100 | Confirmed by direct evidence |

Drop below 75. Re-score against the code, not against the reviewer's reasoning — a Sonnet reviewer that argues its way to 75 has still only argued. A finding you cannot reproduce from the diff yourself is a 25. Reviewers are already told to skip compiler-caught, vague, and explicitly-silenced issues; drop any that slip through, plus behaviour changes that are plainly the point of the change.

**Severity — how much damage does it do?**

| Score | Meaning |
|---|---|
| 0 | Cosmetic; nobody is misled |
| 25 | A reader is misled; no runtime consequence — a stale docstring lives here |
| 50 | Wrong behaviour on an uncommon path, or a genuine coverage gap |
| 75 | Wrong behaviour a user will hit, or a failure that stays silent |
| 100 | Data loss, a security hole, or a broken documented contract |

**Effort — how much work is the fix?**

| Score | Meaning |
|---|---|
| 0 | One line in one file: a reword, a guard, a rename |
| 25 | One function plus its test |
| 50 | Several functions or a few files, contained inside one component |
| 75 | Crosses a component boundary, or changes an interface other code depends on |
| 100 | Multi-file refactor across domains, with no single obvious approach |

Severity and effort are descriptive. Neither one drops a finding, and low severity is never a reason to bury something that costs a one-line fix. A stale docstring scores confidence 100, severity 25, effort 0, and gets fixed.

One drop rule beyond confidence: **severity below 25 with effort above 75.** A repo-wide refactor bought for a cosmetic gain is noise.

## Scope

Every finding is tagged `in-diff` or `pre-existing`.

A `pre-existing` finding is admissible when this change is what makes it matter — the diff makes the old code wrong, newly reachable, or newly inconsistent with its neighbours. A latent defect the diff never disturbs stays out, however real it is.

Tag these clearly. A `pre-existing` finding asks the author to fix code they did not write, which is a different conversation from fixing code they did.

## Synthesis

Disagreements do not fall out of the reports — you produce them. Before writing the output, take each blind finding and re-check it yourself against the intent context. If the context explains it away, that is a disagreement, not a dismissal. Do the same in reverse for sighted findings with no corresponding code defect.

A disagreement is not its own section. It rides on the finding, with both positions stated. Two of them are worth extra attention: a blind finding the context waves away usually means context is doing work the code should do itself; a sighted finding with no code defect behind it usually means a requirement nobody implemented.

## Output Contract

Group by what the reader would do about each finding. Sections run in effort order; inside each one, order by severity descending.

Every finding carries its three scores, its scope tag, and its sources — `blind`, `sighted`, `forge-bot`, `forge-human`, more than one where they corroborate.

1. **Fix now** — effort ≤ 25. File:line, what's wrong, why it matters. Cheap findings of every severity collect here. The section is long by design.
2. **Scoped work** — effort 26–75. Same format. Each one needs a real change, and none needs a conversation first.
3. **Needs discussion** — effort > 75. Each one proposes a handover document instead of a fix; see below.
4. **Dismissed** — human forge comments you are rejecting, with the reason. Nothing else goes here: a bot comment that fails re-scoring disappears silently, like any other unreal finding.
5. **Verdict** — ready to merge: yes / no / with fixes, in one sentence.

Do not post to the forge unless asked. Do not apply fixes as part of the review.

Hand findings to `superpowers:receiving-code-review` — verify before implementing, push back where a reviewer is wrong.

## Handover Documents

Above effort 75, a fix is a project. Propose a handover document and stop there — writing it is a separate request, and the review has no mandate to design anything.

State what the document would contain:

- The finding, in enough detail that a reader who never saw the diff can follow it
- What it costs to leave alone
- What it touches — files, components, callers, anything downstream
- The desired end state, described as behaviour

**No solution.** The point of the document is to open a discussion that discovers one. A review that arrives with the answer attached has closed the discussion it asked for.

## Common Mistakes

| Mistake | Consequence |
|---|---|
| Pasting intent context into a blind prompt "for context" | Collapses two lenses into one; you paid for two reviewers and got one |
| Giving the sighted reviewer the implementation plan | Findings become "deviates from plan" rather than "is wrong" |
| Including a simplifier or fixer in the roster | A reviewer that edits invalidates the other reviewer's diff |
| Splitting an aspect out into its own agent "to be thorough" | The aspect is already in the blind prompt; you buy a duplicate diff read and duplicate findings |
| Reviewing a >1000-line diff that the gate called incoherent | Findings scatter across unrelated changes and the sighted lens has no intent to review against |
| Dropping a finding because its severity is low | Severity does not gate. A severity-25 defect with a one-line fix is the cheapest win in the report |
| Scoring severity and effort as one number | The two are independent. Collapsing them hides exactly the cheap-and-real findings this skill exists to surface |
| Proposing a fix alongside a handover document | The document exists to open a discussion. An attached solution closes it before anyone joins |
| Reporting a pre-existing defect the diff never disturbs | Turns a review of one change into an audit of the repository |

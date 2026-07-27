---
name: diataxis
description: >
  Review, audit, or improve documentation using the Diátaxis framework — the
  four-quadrant system (Tutorial, How-to, Reference, Explanation) that gives
  every piece of documentation a clear purpose and audience. Use this skill
  whenever the user wants anything to do with documentation quality or
  structure: "our docs are a mess", "users can't find anything", "help me fix
  my documentation", "I want to improve my docs", "review our docs", "audit
  the docs", "check docs against diataxis", "analyze documentation structure",
  "evaluate our docs", "which type of docs should I write here?", "help me
  write better documentation", or any similar intent. Also use when the user
  is about to write new documentation and wants to know what kind to write or
  how to structure it. If a path is provided, scope the review to that
  location.
argument-hint: "[path/to/docs]"
context: fork
agent: general-purpose
---

# Diátaxis Documentation Review

Diátaxis is a systematic framework for technical documentation. It organises documentation into four distinct types, each serving a different user need. This skill reviews a codebase's documentation for adherence to the framework and produces an actionable report.

---

## The Compass

Use this two-question decision table to classify any piece of documentation:

| If the content...   | ...and serves the user's...  | ...then it belongs to... |
|---------------------|------------------------------|--------------------------|
| informs **action**  | **acquisition** of skill     | Tutorial                 |
| informs **action**  | **application** of skill     | How-to guide             |
| informs **cognition** | **application** of skill   | Reference                |
| informs **cognition** | **acquisition** of skill   | Explanation              |

Two questions to ask of any content:

1. **Action or cognition?** — Is this about doing, or about knowing/understanding?
2. **Acquisition or application?** — Is the user learning/studying, or working/getting something done?

---

## Quick Reference: The Four Types

### Tutorial (learning-oriented)

**Purpose:** A guided lesson in which the user learns by doing. Success means the learner gains competence and confidence.

**Key markers:**

- Concrete, sequential steps toward a meaningful goal
- First-person plural ("Let's…", "We'll now…")
- The teacher takes full responsibility for the learner's success
- Covers all actions, concepts, and tools the learner will need

**Top anti-patterns:**

- Explaining concepts instead of guiding action ("In REST APIs, resources are…")
- Offering choices or branches ("you could also try…")
- Incomplete journey — learner doesn't reach a satisfying conclusion
- Assuming prior knowledge or skipping setup steps

---

### How-to Guide (goal-oriented)

**Purpose:** Directions that help a competent user accomplish a specific real-world task or solve a problem.

**Key markers:**

- Written from the user's perspective, not the tool's
- Addresses a human goal or problem, not a feature or operation
- Allows for real-world complexity (branching, judgement calls)
- Assumes the user knows what they want to do

**Top anti-patterns:**

- Teaching or explaining (that's a tutorial or explanation)
- Goals defined by tool features rather than user needs ("How to use the Deploy button")
- Too narrow to be useful for any real variation of the task
- Mixing in reference material for completeness

---

### Reference (information-oriented)

**Purpose:** Authoritative, neutral description of the machinery. The user consults it while working, not reads it through.

**Key markers:**

- Austere, factual, structured by the product's own structure
- No instruction, no opinion, no narrative
- Consistent patterns across all entries
- Docstrings, API docs, CLI help text are almost always reference

**Top anti-patterns:**

- Embedding how-to steps ("To create a client, call `Client()`…")
- Adding opinions or recommendations ("It's best to…")
- Expanding into explanation of design rationale
- Inconsistent structure across similar items

---

### Explanation (understanding-oriented)

**Purpose:** Discursive treatment of a topic that builds the reader's mental model. Read away from the product, not during work.

**Key markers:**

- Higher, wider perspective — "about" a topic
- Connects things together; answers "why" and "how does this fit?"
- Admits perspective, alternatives, history, trade-offs
- Often named: Background, Concepts, Architecture, Discussion

**Top anti-patterns:**

- Becoming procedural (that's a how-to)
- Becoming a reference for a specific item
- No clear topic boundary — sprawling without scope
- Scattered through other sections rather than standing on its own

---

## Documentation Locations

| Type        | Typical locations                                                                 |
|-------------|-----------------------------------------------------------------------------------|
| Tutorial    | `docs/getting-started/`, `docs/tutorial/`, quickstart READMEs, `docs/walkthrough/` |
| How-to      | `docs/how-to/`, `docs/guides/`, `CONTRIBUTING.md`, recipe sections               |
| Reference   | `docs/api/`, `docs/reference/`, auto-generated docs, `src/**` docstrings, JSDoc  |
| Explanation | `docs/concepts/`, `docs/architecture/`, `docs/background/`, `docs/design/`       |

Cross-cutting: `README.md` often mixes all four. `CHANGELOG.md` is neither — exclude it. `LICENSE` — exclude.

---

## Workflow

### Step 1 — Discover and map documentation

Glob for documentation files across the codebase. If the user provided a path argument, scope all searches to that path. Scoping matters: if the user asked about a specific folder, reviewing everything else produces out-of-scope feedback that dilutes the report and wastes the user's attention.

**Explicit doc files:** `**/*.md`, `**/*.rst`, `**/*.txt` in:

- `README*`, `docs/`, `documentation/`, `doc/`, `wiki/`, `.github/`, `CONTRIBUTING*`

**Inline docs:** Sample representative source files in `src/`, `lib/`, `packages/` for docstrings, JSDoc, Javadoc, etc. Do not read every source file — sample 5–15 representative files per language. Sampling works because patterns in documentation are highly consistent within a codebase: if 5 representative files all embed how-to steps in docstrings, the rest almost certainly do too.

Build a mental map: file path → likely quadrant based on path/name heuristics before reading content. This lets you form hypotheses early and notice when content contradicts its location — a file in `docs/reference/` that reads like a tutorial is a stronger signal than one that merely has structural issues.

---

### Step 2 — Spawn parallel sub-agents (for large codebases)

For codebases with more than ~20 doc files, spawn up to 3 sub-agents in parallel using the Agent tool. Parallel sub-agents reduce total wall-clock time and — more importantly — each agent works with a focused context rather than sharing one large context. A dedicated agent for inline docs can read source files deeply without that work crowding out the analysis of standalone docs.

The three-way split maps to genuinely different analysis modes, not arbitrary divisions:

- **Agent A** — Analyse standalone doc files: tutorials, how-to guides, explanation candidates. Read and classify each.
- **Agent B** — Analyse source code for embedded reference docs. Sample representative files; check if docstrings stay within reference bounds or stray into how-to or explanation.
- **Agent C** (if needed) — Analyse READMEs and top-level files that commonly mix content types. READMEs deserve their own pass because they nearly always span all four quadrants in ways that deserve careful untangling.

Each agent applies the compass to classify content and flags issues.

For small codebases (fewer than ~20 doc files), read files directly without spawning sub-agents.

---

### Step 3 — Classify and assess adherence

Assign each major piece a type: **Tutorial / How-to / Reference / Explanation / Mixed / Unclear**

For each, check against the key principles for that type:

- Does the content stay within its quadrant?
- Are the anti-patterns present?
- Is the content placed where users would look for its type?

Flag specific violations with file paths and line references where possible. Line references transform vague feedback into actionable tasks: "this file mixes tutorial and reference" is hard to act on, but "lines 45–72 embed a narrative usage walkthrough into what should be an API reference entry" tells the developer exactly what to fix and how.

Special cases:

- Module-level docstrings explaining design rationale → Explanation leaking into Reference
- Class docstrings walking through a usage pattern → How-to leaking into Reference (extract to a how-to guide)
- README sections that mix four types → flag as mixed and suggest splitting

---

### Step 4 — Identify gaps

Tally which quadrants are:

- **Present and well-represented**
- **Present but sparse** (exists but thin)
- **Absent** (nothing for this quadrant exists)

Gap analysis is often more impactful than critique of what exists. A user who can't find what they need because it doesn't exist has the worst experience of all — they leave empty-handed. A perfectly structured tutorial doesn't help the experienced user who needed a how-to guide. Name each gap in terms of the specific user need it leaves unmet.

Common gap patterns to flag:

- No tutorial: newcomers have no entry point
- No how-to guides: competent users can't find task guidance
- Docstrings exist but no higher-level reference index
- No explanation: users can't build a mental model of core abstractions
- Reference-heavy codebase with no learning path

---

### Step 5 — Write the report

Produce a three-section report. This structure serves a deliberate purpose: the person receiving the report needs to know what to protect (no regressions), what to fix (priority actions), and what to build (future investment). Blending these three produces a wall of undifferentiated feedback that's hard to act on.

**1. What adheres well**
Cite specific files or sections. Explain what they do right in Diátaxis terms (not just "this is good").

**2. What needs improvement**
For each issue, cite the file/location, name the specific problem in Diátaxis terms, and give a concrete suggestion:

- "Reorganise as…"
- "Split into separate Tutorial and How-to…"
- "Move the rationale paragraphs to a Concepts page…"
- "Add links to how-to guides rather than embedding steps here…"

**3. Significant gaps**
Name missing quadrants and the user needs they leave unmet. Be specific: "There is no tutorial, so a newcomer to this library has no guided entry point." Not just "tutorials are missing."

---

## After the Report — Offer Next Steps

After delivering the report, offer to help the user act on it. A report without a path forward leaves them with diagnosis but no treatment. Tailor the offer to what you found:

- If there are mixed or misclassified documents: "I can help rewrite [file] — would you like me to restructure it as a proper [Tutorial/How-to/Reference/Explanation]?"
- If a quadrant is absent: "I can draft a [tutorial/how-to guide/explanation] for [topic] to fill the gap — want me to start one?"
- If the directory structure is the main issue: "I can suggest a reorganised `docs/` folder layout that separates the four types clearly."
- If there are many small issues: "Want me to prioritise the top 3 highest-impact fixes to tackle first?"

Don't volunteer to do all of this unprompted — pick the most natural next step given the report, and offer it.

---

## Output Format Decision

- **Minor issues only** (mostly adherent, a few anti-patterns): Deliver the report **inline** in the conversation.
- **Significant restructuring needed** (missing quadrants, pervasive mixing, major reorganisation required): **Write the report to `DIATAXIS_REVIEW.md`** in the project root, then note the file path inline.

The user can always override: "give me the report inline" or "write it to a file."

---

## Resources

- **`references/diataxis-framework.md`** — Full framework detail for all four types: extended principles, common conflations, docstring guidance.
- **Raw source** — If you need more depth, the `.rst` source files are in the same directory as this skill under `diataxis-documentation-framework/` — consult them only if the reference file above is insufficient: `tutorials.rst`, `how-to-guides.rst`, `reference.rst`, `explanation.rst`, `compass.rst`, `quality.rst`, `tutorials-how-to.rst`, `reference-explanation.rst`.

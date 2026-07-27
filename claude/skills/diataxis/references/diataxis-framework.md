# Diátaxis Framework — Full Reference

This document provides in-depth guidance on all four documentation types in the Diátaxis framework. Use this when the compact descriptions in `SKILL.md` are insufficient to resolve a classification question or assess a specific case.

**Raw source files** (if still more depth is needed): the `.rst` source files are in the same directory as this skill under `diataxis-documentation-framework/` — consult them only if this reference file is insufficient: `tutorials.rst`, `how-to-guides.rst`, `reference.rst`, `explanation.rst`, `compass.rst`, `quality.rst`, `tutorials-how-to.rst`, `reference-explanation.rst`.

---

## Table of Contents

- [The Compass (Full)](#the-compass-full)
- [Tutorials — In Depth](#tutorials--in-depth)
- [How-to Guides — In Depth](#how-to-guides--in-depth)
- [Reference — In Depth](#reference--in-depth)
- [Explanation — In Depth](#explanation--in-depth)
- [Common Conflations](#common-conflations)
  - [Tutorials ↔ How-to guides](#tutorials--how-to-guides-most-frequent)
  - [Reference ↔ Explanation](#reference--explanation)
- [Docstrings and Inline Docs — Classification Guide](#docstrings-and-inline-docs--classification-guide)

---

## The Compass (Full)

The compass provides a truth-table for documentation. Apply it to individual sentences, paragraphs, or entire documents.

| If the content...     | ...and serves the user's...  | ...then it belongs to... |
|-----------------------|------------------------------|--------------------------|
| informs **action**    | **acquisition** of skill     | Tutorial                 |
| informs **action**    | **application** of skill     | How-to guide             |
| informs **cognition** | **application** of skill     | Reference                |
| informs **cognition** | **acquisition** of skill     | Explanation              |

**Terms:**

- *Action*: practical steps, doing, operating
- *Cognition*: theoretical or propositional knowledge, understanding
- *Acquisition*: study, learning, building new competence
- *Application*: work, getting something done, exercising existing competence

The compass is most useful when you feel uneasy about a piece of content — when it seems to be doing two things at once, or when you're unsure which type to assign.

---

## Tutorials — In Depth

### What a tutorial is

A tutorial is a lesson: a practical activity in which the student learns by doing something meaningful, guided by the teacher. The teacher (the tutorial author) bears nearly all the responsibility. The student's only obligation is to follow along.

The student *does* things, but what they *learn* is broader: facts, names of things, how tools relate to each other, workflows, concepts. The doing is the vehicle; the learning is the outcome.

### The tutorial as a contract

A tutorial creates a contract:

- The teacher decides what is to be learned, what actions will achieve this, and is responsible for the learner's success.
- The learner only needs to be attentive and follow directions.

Violating this contract — by requiring prior knowledge, by leaving the learner without a clear path, by letting the tutorial break — is a failure of the tutorial.

### Principles for good tutorials

**Make it concrete.** Abstract explanations have no place here. Everything must be grounded in specific actions with specific tools producing specific results.

**Ensure results early and often.** The learner needs to see that things are working. Frequent moments of visible success build confidence.

**Take small steps.** Each step should be clear and achievable. Steps that are too large lead to confusion when something goes wrong.

**Don't offer choices.** The learner is not yet competent to choose. Branches, options, and alternatives belong in how-to guides. A tutorial has one path.

**Don't explain.** Explanation is a different document type. In a tutorial, note what something is called or what it does, but do not explain *why* or explore the concept. Link away if needed.

**The journey must be complete.** The learner must arrive somewhere satisfying. An incomplete tutorial leaves the learner stranded.

**Use first-person plural.** "Let's create a project.", "We'll now configure…", "Notice that we have…" — this reinforces the teacher-student relationship and makes the action feel guided.

**Ensure reliability.** If the tutorial breaks (because the product changed), it fails entirely. Tutorials require more maintenance than other documentation types.

### Tutorial anti-patterns

| Anti-pattern | Why it's a problem |
|---|---|
| Explaining concepts mid-tutorial | Interrupts the learning journey; cognition, not action |
| Offering choices ("you could also…") | Learner isn't competent to choose yet |
| Missing setup steps | Breaks the learner's path before it starts |
| Incomplete ending | Learner has done things but arrived nowhere |
| Prerequisites that aren't actually prerequisites | Creates confusion about who the tutorial is for |
| Second-person imperative tone only ("Do this. Now do this.") | Missing the teacher relationship; feels robotic |

---

## How-to Guides — In Depth

### What a how-to guide is

A how-to guide is directions for getting something done — a specific task or problem that a real user actually needs to accomplish. It serves the *already-competent* user who is *at work*, not at study.

The critical distinction from tutorials: a tutorial serves learning; a how-to guide serves work. Same format (steps), completely different purpose.

### Written from the user's perspective, not the product's

The most common failure in how-to guides is writing from the machine's perspective rather than the user's:

**Poor (machine-perspective):** "Using the Deploy button"
**Good (user-perspective):** "How to deploy a new version without downtime"

The user doesn't care about the Deploy button per se. They care about deploying safely. The button is incidental.

How-to guides are defined by human goals and problems, not by features. A rich set of how-to guides signals a product that can actually help people get real things done.

### Allow for real-world complexity

A how-to guide must be adaptable. Real-world problems are rarely identical to the one the author had in mind. Good how-to guides:

- Acknowledge variations and edge cases
- Give the user enough understanding to adapt, not just blindly follow steps
- May branch or fork (unlike tutorials, which have one path)
- Trust the user's judgement for the parts that depend on context

### Assume competence

The reader of a how-to guide is already competent in the domain. Don't explain basic concepts. Don't over-explain what each action does. Trust that they can follow standard interface conventions.

### How-to guide anti-patterns

| Anti-pattern | Why it's a problem |
|---|---|
| Defined by feature, not user need | The guide isn't about what anyone actually needs to do |
| Teaching or explaining | That's a tutorial or explanation |
| Too narrow to adapt | Only useful for exactly one scenario; useless for any real variation |
| Adding reference material for completeness | Dilutes the task focus; link instead |
| Procedural but not goal-oriented | Steps with no purpose the user cares about |

---

## Reference — In Depth

### What reference is

Reference material is neutral, authoritative description of the product's machinery. The user *consults* it — scans it, looks things up — rather than reads it through. It provides certainty: firm ground to stand on while working.

Reference is led by the product's structure, not by user needs. If the product has 40 API endpoints, the reference has (at least) 40 entries, one per endpoint, in a consistent format.

### Austere description

The guiding word is *austere*. Reference does not:

- Explain why things are designed the way they are
- Recommend approaches or best practices
- Walk through use cases
- Tell a story

It describes. Accurately. Completely. Consistently.

The hardest part of writing reference is resisting the urge to explain. Description feels inadequate; we instinctively want to add context. Resist it. Link to how-to guides and explanation instead.

### Docstrings and inline documentation

Docstrings are almost always reference. They describe what a function, class, or module does, what arguments it takes, what it returns, what errors it raises.

**Exceptions:**

- **Module-level docstrings that explain design rationale** → This is Explanation leaking into a Reference location. Either keep it brief and link to an explanation document, or move the rationale to a concepts/architecture page.
- **Class/function docstrings that walk through a usage example as narrative** → This is a how-to guide embedded in reference. Extract it to a how-to guide and link to it from the docstring. A code example is fine; a narrative "here's how you'd use this in practice" paragraph is not.

### Reference anti-patterns

| Anti-pattern | Why it's a problem |
|---|---|
| Mixing in how-to steps | Pollutes the description with instruction |
| Adding opinions ("It's best to…", "You should prefer…") | Reference must be neutral |
| Explaining design rationale | That's explanation |
| Inconsistent structure across similar items | Destroys the "know where to find it" value of reference |
| Narrative prose instead of structured entries | Reference is consulted, not read; structure enables scanning |

---

## Explanation — In Depth

### What explanation is

Explanation is discursive, understanding-oriented treatment of a topic. It takes a higher, wider view than the other three types. Its purpose is not to help the user do something, but to deepen their understanding of *why things are the way they are*, *how they fit together*, and *what tradeoffs were made*.

The key concept is *reflection*: explanation occurs after and around the practical work, and brings something new — shines light on the subject from a different angle.

Explanation answers: "Can you tell me about…?"

### Characteristics of explanation

- **Broader perspective** — covers a topic, not a specific task or component
- **Admits perspective and opinion** — unlike reference, explanation can say "the designers chose X over Y because…"
- **Historical and contextual** — can discuss why things evolved as they did
- **Connects things** — helps the reader see how concepts relate, not just what they are
- **Can be read away from the product** — it's the only doc type that makes sense to read in the bath

Explanation is often not explicitly recognised. It tends to get scattered in small pieces through other sections — a paragraph here, a "background" sidebar there. Giving it its own home (Concepts, Architecture, Background) makes a significant difference.

### Bounding explanation topics

Explanation has no natural endpoint the way tutorials (finish the exercise) and reference (describe the whole API) do. The author must draw lines and be satisfied. Use a "why" question as a prompt: "Why does this system use event sourcing?" becomes the scope of an explanation document.

### Explanation names

Your explanation docs don't need to be called "Explanation." Common alternatives that signal the right intent:

- Concepts
- Background
- Architecture
- Design
- Discussion
- Topics

### Explanation anti-patterns

| Anti-pattern | Why it's a problem |
|---|---|
| Becoming procedural ("to understand X, do Y, then Z…") | That's a how-to guide |
| Becoming reference for a specific item | Explanation is about a topic; reference is about a component |
| No clear topic boundary — sprawling without scope | Hard to know when it ends; hard to find what you need |
| Scattered as footnotes in other sections | Users can't find it; it can't do its job of building understanding |
| Avoiding perspective and opinion | Explanation is allowed — encouraged — to say "this approach was chosen because…" |

---

## Common Conflations

### Tutorials ↔ How-to guides (most frequent)

The most common mistake in software documentation. Both involve steps; both are practical. The difference is everything:

| | Tutorial | How-to guide |
|---|---|---|
| User is… | at study | at work |
| Goal is… | learning | accomplishing a task |
| User need is… | guided experience | task completion |
| Assumes competence? | No — the teacher bears responsibility | Yes — the user knows what they want |
| Branching? | No — one path | Yes — adapts to real situations |
| Tone | "Let's…" / "We…" | "To do X, do Y" |

**Symptom of conflation:** A "tutorial" that says "you may also want to…" or "alternatively…" — that's a how-to guide, not a tutorial.

### Reference ↔ Explanation

Both are about knowing rather than doing. The difference:

| | Reference | Explanation |
|---|---|---|
| Structure led by… | the product | the topic |
| Admits opinion? | No — neutral | Yes — perspective allowed |
| User activity | Working — consulting for certainty | Studying — building understanding |
| Example | API endpoint documentation | "Why the system uses eventual consistency" |

**Symptom of conflation:** A reference entry that has a paragraph explaining the design philosophy of a function. That paragraph is explanation; it should be linked, not embedded.

---

## Docstrings and Inline Docs — Classification Guide

| Content | Correct type | Notes |
|---|---|---|
| Function signature, parameters, return type, exceptions | Reference | Core reference content |
| A short usage example in a docstring | Reference | Examples are fine in reference |
| "It's best to call this with…" advice | Explanation (or how-to) | Should be in a guide, not a docstring |
| A narrative walk-through of a use case | How-to guide | Extract and link from docstring |
| Module-level docstring: "this module implements X" | Reference | Fine — brief description of the module |
| Module-level docstring: "we chose this design because…" | Explanation | Should live in architecture/concepts docs |
| Class docstring: steps to initialise and use | How-to guide | Extract to how-to; docstring should just describe the class |
| README: "what this is" + "how to install" + "API overview" + "contributing" | Mixed | Typical README — flag the mixing; suggest split or clear sectioning |

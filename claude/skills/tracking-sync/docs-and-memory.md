# Docs and memory streams

You are read-only. Return proposed edits as text. Write nothing.

## Docs

You have one or more documents and the landed-work list. Return each finding
as `file:line | class | proposed replacement or "delete"`.

| Class | A line qualifies when |
| --- | --- |
| WRONG | The landed work made it false: a renamed command, a removed flag, a moved file, a changed default. Verify against the tree before reporting. |
| HISTORY | It narrates the past. Markers: "previously", "used to", "no longer", "as of PR #N", "now supports", "was changed to", "originally". Propose the present-tense statement, or deletion when nothing present-tense remains. |
| DEAD-REF | It points at a path, symbol, issue or URL anchor that no longer resolves. |

A historical reason that constrains present behaviour is not HISTORY: a compat
shim, an upstream workaround, a format kept for old data. Leave it.

Files the profile lists as historical artefacts are skipped entirely.

Report only these three classes. Style, tone and structure are out of scope.

If the landed work added behaviour a reader of a document would expect to
find there, add one final row for it: `GAP | <what is undocumented>`. Propose no text
for it.

## Memory

You have the memory directory and the landed-work list. Read the index and
every memory file. Return one row per file that needs action:
`file | verdict | reason | replacement text if REWRITE`.

| Verdict | A memory qualifies when |
| --- | --- |
| STALE | Nothing in the tree or the open issues still supports it. A file, flag or function it names is gone. |
| RECORDED | The repository now states the same fact, in an instruction file, a doc or the code. Cite where. |
| COMPLETED | It records finished work: a merged PR, a closed epic, a review outcome. Git history holds that. |
| REWRITE | The fact is still useful and part of it drifted. Give the corrected text. |

STALE, RECORDED and COMPLETED are deletions.

Then check the index both ways: an index line whose file is missing, and a
memory file with no index line.

Feedback memories record how the user wants work done. Landed code rarely
falsifies one. Mark a feedback memory only when it names something that no
longer exists.

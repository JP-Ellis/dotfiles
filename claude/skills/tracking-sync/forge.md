# Forge commands

The profile's **Forge** section names the CLI. Wrap every forge call in
`timeout 120`. Both CLIs read the repository from the `origin` remote of the
current directory.

Every step works from the same three artefacts, whichever forge built them:

| Artefact | Holds |
| --- | --- |
| The **issue dump** in the scratchpad | Every issue, open and closed, with its state and body. |
| The **window lists** | PRs merged, issues filed and issues closed since the last run. |
| The **forge index**, `<common>/tracking-sync/forge-index.txt` | One line per issue and PR as of the last applied run: `issue 41 open`, `pr 57 closed`. Step 5 rewrites it. |

## GitHub: `gh`

`gh` filters by date and prints JSON, so the window lists come straight from
search and the forge index is not needed.

```sh
# Issue dump
gh issue list --state all --limit 1000 \
  --json number,title,state,stateReason,labels,body > <scratchpad>/issues.json

# Window lists
gh pr list --state merged --limit 50 --search "merged:>=<date>" \
  --json number,title,mergedAt,body,headRefName,headRefOid,baseRefName
gh issue list --state all --limit 100 --search "created:>=<date>" \
  --json number,title,state,createdAt
gh issue list --state closed --limit 100 --search "closed:>=<date>" \
  --json number,title,closedAt,stateReason

# Cleanup
gh pr list --state open --limit 200 --json number,headRefName,author
gh pr list --state merged --head <bare branch name> \
  --json number,headRefOid,baseRefName,mergedAt
gh api 'repos/{owner}/{repo}/branches' --paginate \
  --jq '.[] | select(.protected) | .name'

# Writes
gh issue comment <n> --body-file <file>
gh issue close <n> --comment "<evidence>"        # --reason "not planned" for a trivial or obsolete close
gh issue edit <n> --title "<title>"
gh issue edit <n> --body-file <file>
gh issue create --title "<title>" --body-file <file>
```

## Forgejo: `fj`

`fj` prints text for people. It has no JSON output, no date filter and no
branch commands, so the lists are built from numbers.

### Issue dump and index

`fj issue search` prints `#<n>: <title> (by <user>)` and omits the state, so
list each state separately:

```sh
for s in open closed; do
  timeout 120 fj issue search --state "$s" --all |
    sed -n "s/^#\([0-9]*\): .*/issue \1 $s/p"
done > <scratchpad>/forge-index.txt
for s in open closed; do
  timeout 120 fj pr search --state "$s" --all |
    sed -n "s/^#\([0-9]*\): .*/pr \1 $s/p"
done >> <scratchpad>/forge-index.txt
```

Then fetch each issue's body, about a fifth of a second apiece:

```sh
grep '^issue ' <scratchpad>/forge-index.txt | while read -r _ n s; do
  printf '\n===== #%s [%s]\n' "$n" "$s"
  timeout 60 fj issue view "$n"
done > <scratchpad>/issues.txt
```

When piped, `fj issue view <n>` prints four parts in order: the title line,
`By <user> — Open|Closed`, the labels one per line, then a blank line and the
body with a `>` quote marker before every line. An issue with no labels has no label lines.
`fj issue view <n> comments` prints the comments; fetch them only for an issue
under audit.

Labels also filter a search:

```sh
fj repo labels view                               # the labels this repository defines
fj issue search --state open --all --labels epic  # comma-separate to require several
```

`--labels` ignores a name the repository does not define and returns every
issue. Check the name against `fj repo labels view` first.

### Window lists

Compare the new index against the saved `<common>/tracking-sync/forge-index.txt`:

- an `issue` line that is new was **filed** in the window;
- an `issue` line that went from `open` to `closed` was **closed** in it;
- a `pr` line that is now `closed` and was `open` or absent was merged or
  abandoned in it. `fj pr view <n>` tells which.

`fj pr view <n>` prints the title, `By <user> — Open|Merged|Closed`, the line
``From `<head>` into `<base>` `` and the body. `fj pr view <n> commits -o`
lists its commits.

On a first run there is no saved index. Take the PR numbers that the window's
commit subjects cite as `(#N)`, plus the twenty highest-numbered closed PRs
and issues, and say the window was approximated.

### Cleanup

Forgejo publishes each PR's head commit as a git ref, which answers "which PR
has this tip" in one call:

```sh
git ls-remote origin 'refs/pull/*/head'      # <sha> refs/pull/<n>/head
```

- **Merged PR at this tip (test 2):** find the PR numbers whose SHA equals the
  branch tip, then `fj pr view <n>`. The test passes when it prints `Merged`
  and `into` names the default branch.
- **Open PRs:** `fj pr view <n>` for each `pr <n> open` line in the index
  gives the head branch and the author.
- **Protected branches:** `fj` cannot list them. The server refuses to delete
  one. Treat that refusal as final and report it.

### Writes

```sh
fj issue comment <n> --body-file <file>
fj issue close <n> --with-msg "<evidence>"
fj issue edit <n> title "<title>"
fj issue edit <n> body "$(cat <file>)"
fj issue create "<title>" --body-file <file>
```

Forgejo has no close reason. Put "not planned" and the reason in the closing
comment.

Ticking a checklist box is a body edit: fetch the body with
`fj issue view <n>`, strip the leading `>` marker and its space from each line, change the
box, and write it back. Diff the result against the fetched body before
writing, since the edit replaces the whole text.

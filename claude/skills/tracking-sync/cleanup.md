# Cleanup: branches and worktrees

An abandoned branch or worktree asserts that work is still in flight. The
dispatcher gathers this evidence itself in Step 1, after `git fetch --prune`.

`<default>` is the default branch's bare name and `<tip>` is the ref Step 1
defines: `origin/<default>`, or `<default>` in a repository with no remote.

Run the inventory in the main repository and in each nested repository from
the profile. A nested repository with no remote has no remote branches and no
PRs, so only its local rows apply.

## Inventory

Parse plumbing output. Hooks and aliases reshape `git branch` and `git status`
summaries.

```sh
git worktree list --porcelain
git for-each-ref refs/heads \
  --format='%(refname:short) %(objectname) %(upstream:short) %(upstream:track)'
git for-each-ref refs/remotes/origin --format='%(refname:short) %(objectname)'
git stash list
```

From the forge, with the cleanup commands in [forge.md](forge.md): the open
PRs with their head branches and authors, and the protected branches.

`[gone]` in the fourth column marks a branch whose upstream was deleted.

For each worktree, also run `git -C <path> status --porcelain --ignored`.

## Has the branch landed?

Test local branches by name (`fix/x`) and remote branches by ref
(`origin/fix/x`). A remote branch whose local counterpart sits at the same
commit shares its result. Run all three tests on every branch and record each
result.

First check whether the branch has commits of its own:

```sh
git merge-base --is-ancestor <branch> <tip>
```

Exit 0 means the tip is already in the default branch's history. Tests 1 and 3
pass trivially for such a branch, so only test 2 counts for it. Without a
merged PR it is an **empty branch**: newly created, or fast-forwarded long ago.

1. **Patch-equivalent.** `git cherry <tip> <branch>` prints at least one line
   and every line starts with `-`. This covers a rebase merge and a
   cherry-pick.

2. **Merged PR at this tip.** A PR from this branch merged into the default
   branch, and its head SHA is the branch tip:

   [forge.md](forge.md) gives the lookup for each forge. Compare against
   `git rev-parse <branch>`.

   The test passes only when the PR's base is `<default>` and its head SHA
   equals the tip. A PR merged into another branch is a stack layer and proves
   nothing. A different SHA means the branch moved after the merge, and tests
   1 and 3 decide.

3. **Merge adds nothing.** Merging the branch into the default branch leaves
   the tree unchanged. This covers a squash merge of several commits:

   ```sh
   test "$(git merge-tree --write-tree <tip> <branch>)" = "$(git rev-parse '<tip>^{tree}')"
   ```

   A conflict makes `git merge-tree` exit non-zero. That proves nothing either
   way; tests 1 and 2 decide.

A branch has **landed** when any counting test passes. A branch that passes
none carries unmerged work.

## What may be proposed

| Item | Propose removal when | Otherwise |
| --- | --- | --- |
| Worktree | Its branch has landed, `status` shows no modified or untracked file, and every ignored file in it is build output or a dependency cache. | Flag it with what blocks removal, naming any other ignored file. |
| The worktree this session runs in | Never. | Flag it when its branch has landed. |
| Worktree whose directory is gone | Always, as `git worktree prune`. | |
| Local branch | It has landed and no open PR uses it. A worktree may hold it only when that worktree is proposed for removal in the same run. | Flag it. An unlanded branch with a `[gone]` upstream is flagged with its unmerged commit count. |
| Empty branch | Never. | Flag it. |
| Remote branch | It has landed, no open PR uses it, it is not protected, and `git log <tip>..<ref> --format=%ae` prints only the user's address (`git config user.email`). | Flag it. A branch with any other author belongs to a bot or another person and is never proposed. |
| Primary checkout on a landed branch | It is clean. Propose `git switch <default>` and `git merge --ff-only <tip>`. | Flag it. |
| Local default branch behind `<tip>` | The primary checkout is on it and clean. Propose `git merge --ff-only <tip>`, to run before Step 5 writes any file edit. | Flag it: the file edits would be written against an old tree. |
| Stash | Never. List the stashes. | |

The default branch and protected branches are never removal candidates.

A branch with an open PR is in flight. Leave it out of the proposal entirely.

## Removing, on approval

Re-run the item's tests and `status` immediately before each removal. Remove a
worktree before the branch it holds.

```sh
git worktree remove <path>
git branch -d <branch>     # only when `git merge-base --is-ancestor <branch> <tip>` exits 0
git branch -D <branch>     # every other landed branch: git cannot see a rebase or squash merge
git push origin --delete <bare branch name>   # only with the user's explicit yes to remote deletions
```

Stashes belong to the repository, so removing a worktree never justifies
dropping one.

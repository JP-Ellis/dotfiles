--- Reword a commit through `git rebase -i`, with the todo's `pick` for that
--- commit swapped to `reword`. The message opens in Neogit's commit editor.
---
--- Neogit's own rebase reword commits `amend! <sha>` and folds it in with
--- `--autosquash`. Commit-msg hooks then run on the summary `amend! <sha>`:
--- committed strips the prefix and rejects the bare hash for having no type.
--- A rebase reword runs the hooks on the message that is kept.
local M = {}

---@param commit string rev of the commit to reword
function M.reword(commit)
  local git = require("neogit.lib.git")
  local client = require("neogit.client")
  local event = require("neogit.lib.event")
  local notification = require("neogit.lib.notification")

  local short = git.rev_parse.abbreviate_commit(commit)
  local env = client.get_envs_git_editor()
  env.GIT_SEQUENCE_EDITOR = "nvim -c '%s/^pick \\(" .. short .. ".*\\)/reword \\1/' -c 'wq'"

  local result = git.cli.rebase.interactive.autostash.commit(commit).env(env).call({ long = true, pty = true })
  if result:failure() then
    notification.error("Reword failed. Fix the message and continue the rebase, or abort it")
    event.send("Rebase", { commit = commit, status = "conflict" })
  else
    notification.info("Commit Updated")
    event.send("Rebase", { commit = commit, status = "ok" })
  end
end

--- Install M.reword as the Rebase popup's reword. Runs after neogit.setup().
function M.setup()
  require("neogit.lib.git.rebase").reword = M.reword
end

return M

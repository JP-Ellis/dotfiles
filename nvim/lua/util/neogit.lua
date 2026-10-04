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

--- Open the forge's pull request page for the current branch, built from the
--- `git_services` template of the push remote.
---
--- Neogit's own action reads the upstream remote, which is `.` for a branch
--- tracking a local branch: `git remote get-url .` returns nothing and the
--- action errors silently. A pull request comes from the pushed branch anyway.
function M.open_pull_request()
  local config = require("neogit.config")
  local git = require("neogit.lib.git")
  local notification = require("neogit.lib.notification")
  local util = require("neogit.lib.util")

  local remote = git.branch.pushRemote() or git.branch.pushDefault() or git.branch.upstream_remote()
  if remote == "." then
    local remotes = git.remote.list()
    remote = (#remotes == 1 and remotes[1]) or (vim.tbl_contains(remotes, "origin") and "origin") or nil
  end
  local url = remote and git.remote.get_url(remote)[1]
  if not url then
    notification.warn("No push remote to open a pull request on")
    return
  end

  for host, service in pairs(config.values.git_services) do
    if url:match(util.pattern_escape(host)) and service.pull_request ~= "" then
      local values = git.remote.parse(url)
      values.branch_name = git.branch.current()
      local uri = util.format(service.pull_request, values)
      notification.info(("Opening %q in your browser."):format(uri))
      vim.ui.open(uri)
      return
    end
  end
  notification.warn(("No pull request URL template for %s"):format(url))
end

--- Install the overrides into Neogit's popups. Runs after neogit.setup().
function M.setup()
  require("neogit.lib.git.rebase").reword = M.reword
  require("neogit.popups.branch.actions").open_pull_request = M.open_pull_request
end

return M

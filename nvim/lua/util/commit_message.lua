--- A history of commit messages typed in gitcommit buffers.
---
--- Neogit's <m-p> ring walks `git log`, so it only reaches messages that became
--- commits. Every write of a commit buffer lands here instead, which keeps the
--- drafts abandoned with <c-c><c-k> as well as the ones that were committed.
local M = {}

local HISTORY = vim.fs.joinpath(vim.fn.stdpath("state"), "commit-messages.json")
local LIMIT = 100

---@class util.commit_message.Entry
---@field message string
---@field time integer
---@field repo string

--- Read the history, newest entry first.
---@return util.commit_message.Entry[]
local function read()
  local ok, lines = pcall(vim.fn.readfile, HISTORY)
  if not ok or #lines == 0 then
    return {}
  end

  local decoded, entries = pcall(vim.json.decode, table.concat(lines, "\n"))
  if not decoded or type(entries) ~= "table" then
    return {}
  end
  return entries
end

--- The comment character git strips from this buffer's message.
---@param buf integer
---@return string
local function comment_char(buf)
  if vim.b[buf].commit_comment_char then
    return vim.b[buf].commit_comment_char
  end

  local dir = vim.fs.dirname(vim.api.nvim_buf_get_name(buf))
  local out = vim.system({ "git", "config", "--get", "core.commentChar" }, { cwd = dir, text = true }):wait()
  local char = vim.trim(out.stdout or ""):sub(1, 1)
  -- `auto` leaves the choice to git, which starts from `#`.
  if char == "" or char == "a" then
    char = "#"
  end

  vim.b[buf].commit_comment_char = char
  return char
end

--- The message a buffer holds: its lines up to the first comment, with the
--- surrounding blank lines dropped.
---@param buf integer
---@return string[] lines
---@return integer count number of buffer lines the message occupies
local function message_lines(buf)
  local char = comment_char(buf)
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

  local count = #lines
  for i, line in ipairs(lines) do
    if line:sub(1, 1) == char then
      count = i - 1
      break
    end
  end

  local first, last = 1, count
  while first <= last and vim.trim(lines[first]) == "" do
    first = first + 1
  end
  while last >= first and vim.trim(lines[last]) == "" do
    last = last - 1
  end

  return vim.list_slice(lines, first, last), count
end

--- Append a buffer's message to the history, moving a repeat to the front.
---@param buf integer
function M.record(buf)
  local lines = message_lines(buf)
  if #lines == 0 then
    return
  end

  local message = table.concat(lines, "\n")
  local entries = vim.tbl_filter(function(entry)
    return entry.message ~= message
  end, read())

  local path = vim.api.nvim_buf_get_name(buf)
  table.insert(entries, 1, {
    message = message,
    time = os.time(),
    repo = vim.fs.dirname(vim.fs.dirname(path)),
  })

  pcall(vim.fn.writefile, { vim.json.encode(vim.list_slice(entries, 1, LIMIT)) }, HISTORY)
end

--- Swap the buffer's message for another, leaving the comment block below it.
---@param buf integer
---@param message string
local function replace(buf, message)
  local _, count = message_lines(buf)
  local lines = vim.split(message, "\n")
  vim.api.nvim_buf_set_lines(buf, 0, count, false, vim.list_extend(lines, { "" }))

  local win = vim.fn.bufwinid(buf)
  if win ~= -1 then
    vim.api.nvim_win_set_cursor(win, { 1, 0 })
  end
end

--- Pick a past message and put it in the current commit buffer.
function M.pick()
  local buf = vim.api.nvim_get_current_buf()
  local entries = read()
  if #entries == 0 then
    return Snacks.notify.warn("No commit messages recorded yet")
  end

  local items = {}
  for i, entry in ipairs(entries) do
    local subject = vim.split(entry.message, "\n")[1]
    local repo = vim.fn.fnamemodify(entry.repo or "", ":t")
    items[i] = {
      idx = i,
      text = table.concat({ subject, repo, os.date("%Y-%m-%d %H:%M", entry.time) }, " "),
      subject = subject,
      repo = repo,
      date = os.date("%Y-%m-%d %H:%M", entry.time),
      message = entry.message,
      preview = { text = entry.message, ft = "gitcommit" },
    }
  end

  Snacks.picker.pick({
    source = "commit_messages",
    title = "Commit Messages",
    items = items,
    preview = "preview",
    format = function(item)
      return {
        { item.date .. " ", "SnacksPickerComment" },
        { item.repo ~= "" and (item.repo .. " ") or "", "SnacksPickerDir" },
        { item.subject, "SnacksPickerLabel" },
      }
    end,
    confirm = function(picker, item)
      picker:close()
      if item then
        replace(buf, item.message)
      end
    end,
  })
end

return M

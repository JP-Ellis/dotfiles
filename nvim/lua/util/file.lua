--- Operations on the file backing the current buffer.
local M = {}

--- Path of the current buffer's file, or nil when the buffer has no file.
---@return string?
local function current_file()
  local path = vim.api.nvim_buf_get_name(0)
  if path == "" then
    Snacks.notify.error("Buffer is not backed by a file")
    return nil
  end
  return vim.fs.normalize(vim.fn.fnamemodify(path, ":p"))
end

--- Prompt for a destination path, seeded with the current file's path.
--- Paths are entered and resolved relative to the cwd.
---@param prompt string
---@param on_confirm fun(to: string)
local function prompt_destination(prompt, on_confirm)
  local from = current_file()
  if not from then
    return
  end

  local cwd = vim.fs.normalize(vim.fn.getcwd(0))
  local default = vim.fs.relpath(cwd, from) or from

  vim.ui.input({ prompt = prompt, default = default, completion = "file" }, function(value)
    if not value or value == "" or value == default then
      return
    end
    on_confirm(vim.fs.normalize(vim.fs.abspath(value)))
  end)
end

--- Write the buffer to a new file and continue editing that file.
function M.save_as()
  prompt_destination("Save As: ", function(to)
    vim.fn.mkdir(vim.fs.dirname(to), "p")
    vim.cmd.saveas(vim.fn.fnameescape(to))
  end)
end

--- Copy the current file to a new path and open the copy.
function M.copy()
  local from = current_file()
  if not from then
    return
  end

  prompt_destination("Copy To: ", function(to)
    vim.fn.mkdir(vim.fs.dirname(to), "p")
    local ok, err = vim.uv.fs_copyfile(from, to, { excl = true })
    if not ok then
      return Snacks.notify.error("Failed to copy file: " .. err)
    end
    vim.cmd.edit(vim.fn.fnameescape(to))
    Snacks.notify("Copied to `" .. to .. "`")
  end)
end

--- Delete the current file and close its buffer.
function M.delete()
  local from = current_file()
  if not from then
    return
  end

  -- vim.ui.input rather than vim.fn.confirm: the latter opens a modal that
  -- noice cannot render, leaving the prompt invisible.
  vim.ui.input({ prompt = "Delete " .. vim.fn.fnamemodify(from, ":~:.") .. "? [y/N] " }, function(value)
    if not value or value:lower() ~= "y" then
      return
    end
    if vim.fn.delete(from) ~= 0 then
      return Snacks.notify.error("Failed to delete file: `" .. from .. "`")
    end
    Snacks.bufdelete({ force = true })
    Snacks.notify("Deleted `" .. from .. "`")
  end)
end

--- Yank the current file's path to the system clipboard.
---@param opts? { relative?: boolean } relative to the project root
function M.yank_path(opts)
  local from = current_file()
  if not from then
    return
  end

  local path = from
  if opts and opts.relative then
    path = vim.fs.relpath(vim.fs.normalize(LazyVim.root()), from) or from
  end

  vim.fn.setreg("+", path)
  Snacks.notify("Yanked `" .. path .. "`")
end

return M

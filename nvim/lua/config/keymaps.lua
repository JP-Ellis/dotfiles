-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local file = require("util.file")
local map = vim.keymap.set

-- MARK: File

-- LazyVim's <leader>f group covers finding files but not acting on the current
-- one. These fill that half in, following Doom Emacs' SPC f bindings.
-- stylua: ignore start
map("n", "<leader>fs", "<cmd>update<cr>", { desc = "Save File" })
map("n", "<leader>fS", file.save_as, { desc = "Save File As" })
map("n", "<leader>fR", function() Snacks.rename.rename_file() end, { desc = "Rename/Move File" })
map("n", "<leader>fC", file.copy, { desc = "Copy File" })
map("n", "<leader>fD", file.delete, { desc = "Delete File" })
map("n", "<leader>fy", function() file.yank_path() end, { desc = "Yank File Path" })
map("n", "<leader>fY", function() file.yank_path({ relative = true }) end, { desc = "Yank File Path (Root Dir)" })
-- stylua: ignore end

-- MARK: UI

-- LazyVim's <leader>ud toggles diagnostics wholesale. This drops only the
-- end-of-line messages, per buffer, and pairs with the markdown autocmd in
-- config/autocmds.lua.
Snacks.toggle({
  name = "Diagnostic Virtual Text",
  get = function()
    return vim.b.diagnostic_virtual_text ~= false
  end,
  set = function(state)
    vim.b.diagnostic_virtual_text = state
    vim.diagnostic.show(nil, 0)
  end,
}):map("<leader>uv")

-- MARK: Open

-- Doom Emacs gathers "applications" under SPC o. These are the ones LazyVim
-- sets as plain keymaps; the rest of the group is assembled from plugin specs
-- in plugins/open.lua. <leader>gg and <leader>gG take over lazygit's keys for
-- Neogit, which is the only git UI in use here.
local function unmap(lhs)
  pcall(vim.keymap.del, "n", lhs)
end

unmap("<leader>ft")
unmap("<leader>fT")
unmap("<leader>l")

-- stylua: ignore start
map("n", "<leader>ot", function() Snacks.terminal(nil, { cwd = LazyVim.root() }) end, { desc = "Terminal (Root Dir)" })
map("n", "<leader>oT", function() Snacks.terminal() end, { desc = "Terminal (cwd)" })
map("n", "<leader>ol", "<cmd>Lazy<cr>", { desc = "Lazy" })
map("n", "<leader>og", "<cmd>Neogit<cr>", { desc = "Neogit (Root Dir)" })
map("n", "<leader>oG", "<cmd>Neogit cwd=%:p:h<cr>", { desc = "Neogit (cwd)" })
map("n", "<leader>gg", "<cmd>Neogit<cr>", { desc = "Neogit (Root Dir)" })
map("n", "<leader>gG", "<cmd>Neogit cwd=%:p:h<cr>", { desc = "Neogit (cwd)" })
-- stylua: ignore end

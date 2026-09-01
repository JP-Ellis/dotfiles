-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Prose files draw a warning per line from markdownlint. Start them with the
-- end-of-line messages hidden; <leader>uv brings them back.
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("markdown_virtual_text", { clear = true }),
  pattern = { "markdown", "markdown.mdx" },
  callback = function(event)
    vim.b[event.buf].diagnostic_virtual_text = false
  end,
})

-- Every write of a commit buffer, including the write Neogit does on abort,
-- goes to a message history. <m-h> picks one back out; Neogit's own <m-p> ring
-- reaches only messages that became commits.
vim.api.nvim_create_autocmd("BufWritePost", {
  group = vim.api.nvim_create_augroup("commit_message_history", { clear = true }),
  pattern = "COMMIT_EDITMSG",
  callback = function(event)
    require("util.commit_message").record(event.buf)
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("commit_message_pick", { clear = true }),
  pattern = "gitcommit",
  callback = function(event)
    local pick = function()
      require("util.commit_message").pick()
    end
    vim.keymap.set("n", "<m-h>", pick, { buffer = event.buf, desc = "Commit Message History" })
    vim.keymap.set("i", "<m-h>", function()
      vim.cmd.stopinsert()
      pick()
    end, { buffer = event.buf, desc = "Commit Message History" })
  end,
})

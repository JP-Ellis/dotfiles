-- The <leader>o "open" group, after Doom Emacs' SPC o. Entries whose keys come
-- from a plugin spec are retired here with `false`; the ones LazyVim sets as
-- plain keymaps are handled in config/keymaps.lua.
return {
  {
    "folke/snacks.nvim",
    keys = {
      { "<leader>e", false },
      { "<leader>E", false },
      { "<leader>oe", "<leader>fe", desc = "Explorer (Root Dir)", remap = true },
      { "<leader>oE", "<leader>fE", desc = "Explorer (cwd)", remap = true },
    },
  },
  {
    "mason-org/mason.nvim",
    keys = {
      { "<leader>cm", false },
      { "<leader>om", "<cmd>Mason<cr>", desc = "Mason" },
    },
  },
  {
    -- Overseer's own <leader>ot collides with the terminal.
    "stevearc/overseer.nvim",
    optional = true,
    keys = {
      { "<leader>ot", false },
      { "<leader>oa", "<cmd>OverseerTaskAction<cr>", desc = "Task Action" },
    },
  },
  {
    "folke/which-key.nvim",
    optional = true,
    opts = {
      spec = {
        { "<leader>o", group = "open" },
      },
    },
  },
}

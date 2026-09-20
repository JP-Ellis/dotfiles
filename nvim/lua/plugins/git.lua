return {
  {
    "NeogitOrg/neogit",
    dependencies = {
      "sindrets/diffview.nvim",
      "folke/snacks.nvim",
    },
    -- Keys live in config/keymaps.lua: LazyVim's lazygit maps overwrite lazy's
    -- key stubs at VeryLazy, so <leader>gg has to be claimed after that.
    cmd = "Neogit",
    config = function(_, opts)
      require("neogit").setup(opts)
      -- Neogit's rebase reword goes through an `amend! <sha>` commit, whose
      -- summary the commit-msg hook rejects for having no type. util.neogit
      -- swaps in a reword that runs the hook on the message that is kept.
      require("util.neogit").setup()
    end,
    opts = {
      graph_style = "unicode",
      kind = "tab",
      commit_editor = {
        kind = "split",
        staged_diff_split_kind = "vsplit",
        spell_check = true,
      },
      mappings = {
        popup = {
          ["p"] = "PushPopup",
          ["P"] = false,
          ["F"] = "PullPopup",
        },
      },
      integrations = {
        diffview = true,
        snacks = true,
        telescope = false,
        fzf_lua = false,
        mini_pick = false,
      },
    },
  },
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory", "DiffviewToggleFiles" },
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diffview Open" },
      { "<leader>gD", "<cmd>DiffviewClose<cr>", desc = "Diffview Close" },
      { "<leader>gv", "<cmd>DiffviewFileHistory %<cr>", desc = "Diffview File History" },
      { "<leader>gV", "<cmd>DiffviewFileHistory<cr>", desc = "Diffview Branch History" },
    },
    opts = {
      enhanced_diff_hl = true,
      view = {
        merge_tool = {
          layout = "diff3_mixed",
          disable_diagnostics = true,
        },
      },
    },
  },
}

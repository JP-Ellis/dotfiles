return {
  {
    "NeogitOrg/neogit",
    dependencies = {
      "sindrets/diffview.nvim",
      "folke/snacks.nvim",
    },
    cmd = "Neogit",
    keys = {
      { "<leader>gm", "<cmd>Neogit<cr>", desc = "Neogit (magit)" },
      { "<leader>gM", "<cmd>Neogit cwd=%:p:h<cr>", desc = "Neogit (cwd)" },
    },
    opts = {
      graph_style = "unicode",
      kind = "tab",
      commit_editor = {
        kind = "split",
        staged_diff_split_kind = "vsplit",
        spell_check = true,
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

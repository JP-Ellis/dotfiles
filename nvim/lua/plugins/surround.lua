return {
  {
    -- which-key only auto-triggers on `g` and `z` among single letters, so
    -- without this `s` falls to `timeoutlen` (300ms) and a pause before the
    -- second key runs bare `s` instead. The trigger shows the popup and waits.
    "folke/which-key.nvim",
    opts = {
      triggers = {
        { "<auto>", mode = "nxso" },
        { "s", mode = { "n", "x" } },
      },
    },
  },
  {
    "nvim-mini/mini.surround",
    -- mini.surround's own `s` prefix. LazyVim's extra would move these to `gs`,
    -- and an operator prefix such as `ys` races `timeoutlen`: a pause between
    -- `y` and `s` runs `y` as a plain yank instead.
    opts = {
      mappings = {
        add = "sa",
        delete = "sd",
        replace = "sr",
        find = "sf",
        find_left = "sF",
        highlight = "sh",
        update_n_lines = "sn",
      },
    },
    keys = {
      -- vim-surround aliases. These share the `timeoutlen` race above.
      { "ys", "sa", remap = true, desc = "Add Surrounding" },
      { "ds", "sd", remap = true, desc = "Delete Surrounding" },
      { "cs", "sr", remap = true, desc = "Replace Surrounding" },
    },
  },
}

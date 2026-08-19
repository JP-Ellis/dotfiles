return {
  "lambdalisue/suda.vim",
  -- `keys` alone would defer loading, which leaves the smart-edit autocmd below
  -- unregistered until the first keypress.
  lazy = false,
  -- stylua: ignore
  keys = {
    { "<leader>fu", function() require("util.file").sudo_this_file() end, desc = "Sudo This File" },
    { "<leader>fU", function() require("util.file").sudo_find_file() end, desc = "Sudo Find File" },
  },
  init = function()
    -- Upgrade any unwritable file to a `suda://` buffer on open, whatever route
    -- it arrives by. Read before plugin/suda.vim runs, so it must be set here.
    vim.g.suda_smart_edit = true
  end,
}

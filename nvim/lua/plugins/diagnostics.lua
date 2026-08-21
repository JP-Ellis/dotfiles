return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      -- Make virtual text a per-buffer decision. `b:diagnostic_virtual_text`
      -- set to false hides it for that buffer; any other value keeps LazyVim's
      -- styled virtual text. Signs, underlines and `]d`/`[d` are unaffected.
      local virtual_text = opts.diagnostics.virtual_text
      opts.diagnostics.virtual_text = function(_, bufnr)
        return vim.b[bufnr].diagnostic_virtual_text ~= false and virtual_text
      end
    end,
  },
}

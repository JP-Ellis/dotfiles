return {
  -- The treesitter indent query treats an unterminated `"""` as the start of
  -- a nested block, so the first docstring line lands one level too deep.
  -- Vim's bundled indent/python.vim handles docstrings correctly. Re-evaluate
  -- once the indent module rewrite lands:
  -- https://github.com/nvim-treesitter/nvim-treesitter/issues/7840
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { indent = { disable = { "python" } } },
  },
  -- The mason `mypy` package ships the `dmypy` binary.
  {
    "mason-org/mason.nvim",
    opts = { ensure_installed = { "mypy" } },
  },
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        -- dmypy keeps a daemon per project, so re-checks on save are
        -- incremental. It resolves `python3` from PATH, which venv-selector
        -- points at the active virtualenv.
        python = { "dmypy" },
      },
    },
  },
}

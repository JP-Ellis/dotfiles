return {
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

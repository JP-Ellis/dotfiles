return {
  {
    "Shatur/neovim-ayu",
    lazy = false,
    priority = 1000,
    main = "ayu",
    opts = {
      mirage = false,
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "ayu-dark",
    },
  },
}

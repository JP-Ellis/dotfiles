return {
  "saghen/blink.cmp",
  opts = {
    keymap = {
      -- <Tab> accepts the highlighted (or first) completion and <CR> only
      -- ever inserts a newline. A literal tab is still available on <S-Tab>
      -- outside of a snippet.
      preset = "super-tab",
    },
  },
}

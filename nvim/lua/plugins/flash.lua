return {
  "folke/flash.nvim",
  -- Replace LazyVim's defaults outright: jumps live under `ss`/`S` so the
  -- single `s` prefix belongs to mini.surround (`sa`, `sd`, `sr`, ...).
  -- stylua: ignore
  keys = function()
    return {
      { "ss", mode = { "n", "x" }, function() require("flash").jump() end, desc = "Flash" },
      { "S", mode = { "n", "x" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "Ss", mode = "o", function() require("flash").jump() end, desc = "Flash" },
      { "St", mode = "o", function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
    }
  end,
}

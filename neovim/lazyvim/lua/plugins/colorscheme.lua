-- Solarized Dark colorscheme — matches the kitty Solarized Dark theme.
-- maxmx03/solarized.nvim uses the authentic Ethan Schoonover Solarized palette.
return {
  {
    "maxmx03/solarized.nvim",
    lazy = false,
    priority = 1000,
    opts = {}, -- defaults = classic Solarized
    init = function()
      vim.o.background = "dark"
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "solarized",
    },
  },
}

return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      style = "night",
      on_colors = function(colors)
        -- Dusklight palette overrides
        colors.bg = "#060820"
        colors.bg_dark = "#04132d"
        colors.bg_float = "#04132d"
        colors.bg_popup = "#04132d"
        colors.bg_sidebar = "#04132d"
        colors.bg_statusline = "#04132d"
        colors.fg = "#99dfff"
        colors.fg_dark = "#c5c5c5"
        colors.fg_gutter = "#2f2f2f"
        colors.orange = "#ff8000"
        colors.blue = "#93ebeb"
        colors.cyan = "#62d0df"
        colors.green = "#acf7d2"
        colors.magenta = "#cf7cff"
        colors.purple = "#cf7cff"
        colors.red = "#ffb5b5"
        colors.yellow = "#fff09e"
        colors.comment = "#777777"
        colors.dark3 = "#777777"
        colors.terminal_black = "#2f2f2f"
      end,
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight",
    },
  },
}

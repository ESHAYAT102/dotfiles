return {
  {
    "bjarneo/aether.nvim",
    branch = "v3",
    name = "aether",
    priority = 1000,
    opts = {
      colors = {
        bg = "#281f1a",
        dark_bg = "#1f1814",
        darker_bg = "#171210",
        lighter_bg = "#21262c",

        fg = "#d0cbb2",
        dark_fg = "#9c9886",
        light_fg = "#d7d3be",
        bright_fg = "#dcd8c5",
        muted = "#63676c",

        red = "#8c7666",
        yellow = "#9a927a",
        orange = "#9d8b7d",
        green = "#967150",
        cyan = "#83a2a3",
        blue = "#9ba4bb",
        magenta = "#7d819c",
        brown = "#5e534b",

        bright_red = "#b39a85",
        bright_yellow = "#c0b898",
        bright_green = "#74543A",
        bright_cyan = "#a5c9ca",
        bright_blue = "#c0c9e7",
        bright_magenta = "#a1a4c7",

        accent = "#9ba4bb",
        cursor = "#dcd8c5",
        foreground = "#d0cbb2",
        background = "#281f1a",
        selection = "#21262c",
        selection_foreground = "#dcd8c5",
        selection_background = "#21262c",
      },
    },
    config = function(_, opts)
      require("aether").setup(opts)
      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = function()
          vim.api.nvim_set_hl(0, "Terminal", { bg = opts.colors.bg })
        end,
      })
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "aether",
    },
  },
}

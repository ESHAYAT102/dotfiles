return {
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      opts.sections.lualine_z = {
        function()
          local time = os.date("%I:%M %p"):gsub("^0", "")
          return " " .. time
        end,
      }
    end,
  },
}

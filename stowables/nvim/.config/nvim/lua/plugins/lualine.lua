return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  opts = function(_, opts)
    opts.options.theme = "onedark"

    -- Replace the clock in section_z with 12-hour format
    opts.sections = opts.sections or {}
    opts.sections.lualine_z = {
      function()
        return os.date("%I:%M %p")
      end,
    }
  end,
}

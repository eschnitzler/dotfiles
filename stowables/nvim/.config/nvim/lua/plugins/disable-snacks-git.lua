-- Disable snacks picker git keymaps that conflict with diffview
return {
  {
    "folke/snacks.nvim",
    optional = true,
    keys = {
      -- Only disable gD - keep gd for snacks lightweight picker
      { "<leader>gD", false },
    },
  },
}

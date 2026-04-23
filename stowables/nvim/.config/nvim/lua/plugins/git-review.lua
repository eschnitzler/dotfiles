return {
  -- Tab picker for telescope
  {
    "LukasPietzschmann/telescope-tabs",
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function()
      require("telescope").load_extension("telescope-tabs")
      require("telescope-tabs").setup({})
    end,
    keys = {
      { "<leader><tab><tab>", "<cmd>lua require('telescope-tabs').list_tabs()<cr>", desc = "Pick Tab" },
    },
  },

  -- Beautiful diff viewing - side-by-side like GitHub
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles", "DiffviewFileHistory" },
    keys = {
      { "<leader>gD", "<cmd>DiffviewOpen origin/master...HEAD<cr>", desc = "Diff vs Master" },
      { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "File History" },
      { "<leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "Branch History" },
      { "<leader>gc", "<cmd>DiffviewClose<cr>", desc = "Close Diffview" },
    },
    opts = {
      enhanced_diff_hl = true,
      view = {
        default = {
          layout = "diff2_horizontal", -- Side-by-side (use g<C-x> to cycle layouts)
        },
      },
      file_panel = {
        listing_style = "tree",
        tree_options = {
          flatten_dirs = true,
        },
        win_config = {
          position = "left",
          width = 35,
        },
      },
    },
  },

  -- GitHub PR review in Neovim
  {
    "pwntester/octo.nvim",
    cmd = "Octo",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    keys = {
      { "<leader>gp", "<cmd>Octo pr list<cr>", desc = "List PRs" },
      { "<leader>gP", "<cmd>Octo pr create<cr>", desc = "Create PR" },
      { "<leader>gr", "<cmd>Octo review start<cr>", desc = "Start Review" },
      { "<leader>gR", "<cmd>Octo review submit<cr>", desc = "Submit Review" },
    },
    opts = {
      default_merge_method = "squash",
      picker = "telescope",
      use_local_fs = true, -- Use local files for better editing
      file_panel = {
        size = 15,
        use_icons = true,
      },
    },
  },

  -- Enhance gitsigns with inline blame
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      current_line_blame = true,
      current_line_blame_opts = {
        delay = 300,
      },
    },
  },
}

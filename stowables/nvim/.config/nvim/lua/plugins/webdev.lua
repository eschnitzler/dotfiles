return {
  -- Auto-close and rename HTML tags
  {
    "windwp/nvim-ts-autotag",
    event = "InsertEnter",
    opts = {
      filetypes = {
        "html",
        "htmldjango",
        "javascript",
        "javascriptreact",
        "typescript",
        "typescriptreact",
        "xml",
      },
    },
  },

  -- CSS color preview
  {
    "NvChad/nvim-colorizer.lua",
    event = "BufReadPre",
    opts = {
      filetypes = {
        "css",
        "scss",
        "html",
        "htmldjango",
        "javascript",
        "javascriptreact",
        "typescript",
        "typescriptreact",
        "lua",
      },
      user_default_options = {
        RGB = true,
        RRGGBB = true,
        names = true,
        RRGGBBAA = true,
        rgb_fn = true,
        hsl_fn = true,
        css = true,
        css_fn = true,
        mode = "background",
        tailwind = true,
      },
    },
  },
}

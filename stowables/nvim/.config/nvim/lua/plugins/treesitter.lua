return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    ensure_installed = {
      "bash",
      "html",
      "htmldjango",
      "css",
      "scss",
      "javascript",
      "typescript",
      "tsx",
      "json",
      "jsonc",
      "lua",
      "markdown",
      "markdown_inline",
      "python",
      "query",
      "regex",
      "vim",
      "yaml",
      "toml",
      "dockerfile",
      "git_config",
      "gitignore",
      "sql",
    },
    highlight = {
      enable = true,
      -- Disable treesitter for htmldjango, use vim regex instead
      disable = { "htmldjango" },
    },
    indent = {
      enable = true,
      -- Disable treesitter indent for htmldjango, use cindent instead
      disable = { "htmldjango" },
    },
  },
}

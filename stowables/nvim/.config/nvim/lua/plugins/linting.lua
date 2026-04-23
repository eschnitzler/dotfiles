return {
  "mfussenegger/nvim-lint",
  optional = true,
  opts = {
    linters_by_ft = {
      python = { "ruff" },
      htmldjango = { "djlint" },
      javascript = { "eslint" },
      javascriptreact = { "eslint" },
      typescript = { "eslint" },
      typescriptreact = { "eslint" },
      css = { "stylelint" },
      scss = { "stylelint" },
    },
    linters = {
      djlint = {
        cmd = "djlint",
        stdin = true,
        args = { "-" },
        stream = "stdout",
        ignore_exitcode = true,
        -- Reads config from pyproject.toml or .djlintrc in project root
        parser = require("lint.parser").from_pattern(
          "([^:]+):(%d+):(%d+): ([^ ]+) (.*)",
          { "file", "lnum", "col", "code", "message" },
          nil,
          {
            source = "djlint",
            severity = vim.diagnostic.severity.WARN,
          }
        ),
      },
    },
  },
}

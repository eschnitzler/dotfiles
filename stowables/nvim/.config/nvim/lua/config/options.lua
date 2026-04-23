-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.g.lazyvim_python_lsp = "basedpyright"

-- Inside devenv, $SHELL is forced to bash. Override to fish for :terminal.
-- Also set shellcmdflag so :! commands work with fish syntax.
if vim.env.DEVENV_ROOT then
  vim.o.shell = "fish"
  vim.o.shellcmdflag = "-c"
end

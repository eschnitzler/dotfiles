-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
map = vim.keymap.set

map("i", "jk", "<ESC>")

map("n", "<leader>fa", function()
  require("snacks.picker").files({
    args = { "--hidden", "--no-ignore", "--exclude", ".git" },
    prompt = "All Files",
  })
end, { desc = "Search ALL files including .venv" })

map("n", "<leader>sf", function()
  require("snacks.picker").grep({
    args = { "--hidden", "--no-ignore", "--glob", "!.git/*" },
    prompt = "Grep All",
  })
end, { desc = "Grep in ALL files including .venv" })

map("n", "<leader>o", "<cmd>Outline<cr>", { desc = "Toggle Outline" })

-- Sidekick fullscreen toggle
local sidekick_fullscreen = false
local sidekick_saved_config = nil

local function find_sidekick_window()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.b[buf].sidekick_cli then
      return win
    end
  end
  return nil
end

map("n", "<leader>af", function()
  local win = find_sidekick_window()
  if not win then
    -- Open sidekick first, then go fullscreen
    vim.cmd("Sidekick cli show")
    vim.defer_fn(function()
      local w = find_sidekick_window()
      if w then
        local buf = vim.api.nvim_win_get_buf(w)
        sidekick_saved_config = vim.api.nvim_win_get_config(w)
        vim.api.nvim_win_close(w, false)
        vim.defer_fn(function()
          vim.api.nvim_open_win(buf, true, {
            relative = "editor",
            row = 0,
            col = 0,
            width = vim.o.columns,
            height = vim.o.lines - 3,
            style = "minimal",
            border = "none",
          })
          sidekick_fullscreen = true
        end, 50)
      end
    end, 100)
    return
  end

  if sidekick_fullscreen then
    vim.api.nvim_win_close(win, false)
    vim.defer_fn(function()
      vim.cmd("Sidekick cli show")
      sidekick_fullscreen = false
      sidekick_saved_config = nil
    end, 50)
  else
    local buf = vim.api.nvim_win_get_buf(win)
    sidekick_saved_config = vim.api.nvim_win_get_config(win)
    vim.api.nvim_win_close(win, false)
    vim.defer_fn(function()
      vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        row = 0,
        col = 0,
        width = vim.o.columns,
        height = vim.o.lines - 3,
        style = "minimal",
        border = "none",
      })
      sidekick_fullscreen = true
    end, 50)
  end
end, { desc = "Toggle Sidekick Fullscreen" })

-- Tab management
map("n", "<leader><tab>n", "<cmd>tabnew<cr>", { desc = "New Tab" })

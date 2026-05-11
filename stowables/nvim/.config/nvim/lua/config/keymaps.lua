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

-- OpenCode
local function find_opencode_win()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].buftype == "terminal" and vim.api.nvim_buf_get_name(buf):find("opencode") then
      return win
    end
  end
end

map("n", "<leader>ao", function()
  require("opencode").toggle()
  local win = find_opencode_win()
  if win then
    vim.api.nvim_set_current_win(win)
    vim.cmd("startinsert")
  end
end, { desc = "Toggle OpenCode" })

map("n", "<leader>af", function()
  local win = find_opencode_win()
  if not win then
    require("opencode").toggle()
    win = find_opencode_win()
    if not win then return end
  end

  local is_maximized = vim.api.nvim_win_get_width(win) > vim.o.columns * 0.8
  if is_maximized then
    -- Restore equal sizing
    vim.cmd("wincmd =")
  else
    -- Maximize opencode
    vim.api.nvim_set_current_win(win)
    vim.o.winminwidth = 0
    vim.cmd("wincmd | | wincmd _")
    vim.cmd("startinsert")
  end
end, { desc = "Toggle OpenCode Fullscreen" })
map({ "n", "x" }, "<leader>aa", function() require("opencode").ask("@this: ", { submit = true }) end, { desc = "Ask OpenCode" })
map({ "n", "x" }, "<leader>aA", function() require("opencode").ask() end, { desc = "Ask OpenCode (blank)" })
map({ "n", "x" }, "<leader>as", function() require("opencode").select() end, { desc = "OpenCode select action" })
map({ "n", "x" }, "<leader>ar", function() return require("opencode").operator("@this ") end, { expr = true, desc = "Send range to OpenCode" })
map("n", "<leader>al", function() return require("opencode").operator("@this ") .. "_" end, { expr = true, desc = "Send line to OpenCode" })

-- Tab management
map("n", "<leader><tab>n", "<cmd>tabnew<cr>", { desc = "New Tab" })

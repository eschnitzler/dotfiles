return {
  "nickjvandyke/opencode.nvim",
  dependencies = {
    {
      "folke/snacks.nvim",
      optional = true,
      opts = {
        input = {},
        picker = {
          actions = {
            opencode_send = function(...)
              return require("opencode").snacks_picker_send(...)
            end,
          },
          win = {
            input = {
              keys = {
                ["<a-a>"] = { "opencode_send", mode = { "n", "i" } },
              },
            },
          },
        },
      },
    },
  },
  config = function()
    ---@type opencode.Opts
    vim.g.opencode_opts = {
      events = {
        permissions = {
          edits = { enabled = false },
        },
      },
    }
    vim.o.autoread = true

    -- Let <C-h>/<C-l> navigate out of the opencode terminal
    vim.api.nvim_create_autocmd("TermOpen", {
      callback = function(ev)
        local name = vim.api.nvim_buf_get_name(ev.buf)
        if not name:find("opencode") then return end
        local buf = ev.buf
        -- Window navigation
        vim.keymap.set("t", "<C-h>", "<cmd>wincmd h<cr>", { buffer = buf, desc = "Go to left window" })
        vim.keymap.set("t", "<C-j>", "<cmd>wincmd j<cr>", { buffer = buf, desc = "Go to below window" })
        vim.keymap.set("t", "<C-k>", "<cmd>wincmd k<cr>", { buffer = buf, desc = "Go to above window" })
        vim.keymap.set("t", "<C-l>", "<cmd>wincmd l<cr>", { buffer = buf, desc = "Go to right window" })
        -- Scroll within opencode
        vim.keymap.set("t", "<C-u>", function() require("opencode").command("session.half.page.up") end, { buffer = buf, desc = "Scroll opencode up" })
        vim.keymap.set("t", "<C-d>", function() require("opencode").command("session.half.page.down") end, { buffer = buf, desc = "Scroll opencode down" })
      end,
    })
  end,
}

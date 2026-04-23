-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Ensure htmldjango files get proper syntax highlighting and settings
vim.api.nvim_create_autocmd("FileType", {
    pattern = "htmldjango",
    callback = function()
        -- Explicitly set syntax to htmldjango
        vim.cmd("set syntax=htmldjango")

        vim.bo.commentstring = "{# %s #}"
        vim.bo.shiftwidth = 2
        vim.bo.tabstop = 2
        vim.bo.softtabstop = 2
        vim.bo.expandtab = true

        -- Use cindent for better HTML indentation
        vim.bo.cindent = true
        vim.bo.indentexpr = ""
        vim.bo.autoindent = true
        vim.bo.smartindent = false

        -- Set indentkeys to work with HTML tags and Django blocks
        vim.bo.indentkeys = "0{,0},0),0],:,0#,!^F,o,O,e,*<Return>,<>>,<<>,/,0=~end"

        -- Better match pairs for Django templates
        vim.b.match_words = "{% *if:{% *elif:{% *else:{% *endif %},"
            .. "{% *for:{% *empty:{% *endfor %},"
            .. "{% *block:{% *endblock %},"
            .. "{% *comment:{% *endcomment %},"
            .. "{% *filter:{% *endfilter %},"
            .. "{% *spaceless:{% *endspaceless %},"
            .. "{% *with:{% *endwith %},"
            .. "{% *autoescape:{% *endautoescape %},"
            .. "{% *verbatim:{% *endverbatim %},"
            .. "<:>,<tag>:</tag>"
    end,
})

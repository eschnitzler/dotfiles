return {
    {
        "navarasu/onedark.nvim",
        lazy = false,
        priority = 1000,
        opts = {
            style = "deep", -- dark, darker, cool, deep, warm, warmer
            transparent = true,
            lualine = {
                transparent = true,
            },
            highlights = {
                -- Comments in subtle gray
                ["Comment"] = { fg = "#7a8191", italic = true },
                ["@comment"] = { fg = "#7a8191", italic = true },

                -- Teal type hints
                ["LspInlayHint"] = { fg = "#4f5e8c", italic = true },

                -- Django template highlighting (vim syntax groups)
                ["djangoVarBlock"] = { fg = "#61afef" }, -- {{ }}
                ["djangoTagBlock"] = { fg = "#c678dd" }, -- {% %}
                ["djangoStatement"] = { fg = "#c678dd", bold = true }, -- if, for, etc
                ["djangoFilter"] = { fg = "#e5c07b" }, -- |filter
                ["djangoArgument"] = { fg = "#98c379" }, -- arguments
                ["djangoComment"] = { fg = "#7a8191", italic = true }, -- {# #}

                -- HTML highlighting
                ["htmlTag"] = { fg = "#e06c75" }, -- < >
                ["htmlEndTag"] = { fg = "#e06c75" }, -- </
                ["htmlTagName"] = { fg = "#e06c75", bold = true }, -- div, p, etc
                ["htmlArg"] = { fg = "#d19a66" }, -- class, id, etc
                ["htmlString"] = { fg = "#98c379" }, -- attribute values
                ["htmlSpecialChar"] = { fg = "#e5c07b" }, -- &nbsp; etc
                ["htmlLink"] = { fg = "#61afef", underline = true },
            },
        },
    },
    {
        "LazyVim/LazyVim",
        opts = {
            colorscheme = "onedark",
        },
    },
}

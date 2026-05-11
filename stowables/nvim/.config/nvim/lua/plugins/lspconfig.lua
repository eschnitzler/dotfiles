return {
    "neovim/nvim-lspconfig",
    ---@class pluginlspopts
    opts = function(_, opts)
        vim.lsp.config("hx_requests_lsp", {
            cmd = { "hx-requests-lsp", "--stdio" },
            filetypes = { "html", "htmldjango", "python" },
            root_markers = { "manage.py", ".git" },
        })

        return vim.tbl_deep_extend("force", opts or {}, {
            servers = {
                -- Django Template LSP
                djlsp = {
                    filetypes = { "htmldjango" },
                    init_options = {
                        django_settings_module = "app.settings",
                    },
                },
                hx_requests_lsp = {},
                -- Python LSP (disable basedpyright from lazyvim python extra)
                basedpyright = { enabled = false },
                ty = {
                    settings = {
                        ty = {
                            diagnosticMode = "openFilesOnly",
                        },
                    },
                },
                -- HTML/Django templates (emmet for autocomplete)
                emmet_ls = {
                    filetypes = {
                        "html",
                        "css",
                        "scss",
                        "javascript",
                        "javascriptreact",
                        "typescript",
                        "typescriptreact",
                    },
                },
                -- HTML language server
                html = {
                    filetypes = { "html" },
                },
                -- CSS language server
                cssls = {
                    settings = {
                        css = {
                            validate = true,
                            lint = {
                                unknownAtRules = "ignore",
                            },
                        },
                        scss = {
                            validate = true,
                            lint = {
                                unknownAtRules = "ignore",
                            },
                        },
                    },
                },
                -- Tailwind CSS
                tailwindcss = {
                    filetypes = {
                        "html",
                        "css",
                        "scss",
                        "javascript",
                        "javascriptreact",
                        "typescript",
                        "typescriptreact",
                    },
                    settings = {
                        tailwindCSS = {
                            experimental = {
                                classRegex = {
                                    { "class[:]\\s*['\"]([^'\"]*)['\"]" },
                                    { "class[:]\\s*['\"]([^'\"]*)['\"]" },
                                },
                            },
                        },
                    },
                },
                -- TypeScript/JavaScript
                ts_ls = {},
                -- ESLint for JS/TS
                eslint = {
                    settings = {
                        workingDirectories = { mode = "auto" },
                    },
                },
            },
            inlay_hints = {
                enabled = false,
            },
        })
    end,
}

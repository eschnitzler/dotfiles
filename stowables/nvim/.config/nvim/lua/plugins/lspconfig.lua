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
                    cmd = { vim.fn.stdpath("config") .. "/scripts/djlsp-docker-wrapper.py" },
                    filetypes = { "htmldjango" },
                    init_options = {
                        django_settings_module = "app.settings",
                        django_compose_file = "docker-compose.yml",
                        django_compose_service = "web",
                    },
                },
                hx_requests_lsp = {},
                -- Python LSP
                basedpyright = {
                    settings = {
                        basedpyright = {
                            analysis = {
                                typeCheckingMode = "off",
                                autoSearchPaths = true,
                                useLibraryCodeForTypes = true,
                                diagnosticMode = "openFilesOnly",
                            },
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

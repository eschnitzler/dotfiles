return {
  "windwp/nvim-autopairs",
  event = "InsertEnter",
  opts = {
    disable_filetype = { "TelescopePrompt", "vim" },
    enable_check_bracket_line = true,
    check_ts = true,
  },
  config = function(_, opts)
    local npairs = require("nvim-autopairs")
    npairs.setup(opts)

    -- Add Django template tag rules
    local Rule = require("nvim-autopairs.rule")
    local cond = require("nvim-autopairs.conds")

    -- Django template tags: {% %}
    npairs.add_rules({
      Rule("{%", "%}", "htmldjango")
        :with_pair(cond.not_after_regex("%%"))
        :with_move(function(opts_inner)
          return opts_inner.char == "}"
        end),
    })

    -- Django variables: {{ }}
    npairs.add_rules({
      Rule("{{", "}}", "htmldjango")
        :with_pair(cond.not_after_regex("}}"))
        :with_move(function(opts_inner)
          return opts_inner.char == "}"
        end),
    })

    -- Django comments: {# #}
    npairs.add_rules({
      Rule("{#", "#}", "htmldjango")
        :with_pair(cond.not_after_regex("#"))
        :with_move(function(opts_inner)
          return opts_inner.char == "}"
        end),
    })
  end,
}

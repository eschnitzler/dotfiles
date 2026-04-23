return {
  "L3MON4D3/LuaSnip",
  opts = function(_, opts)
    -- Load custom snippets from snippets directory
    require("luasnip.loaders.from_lua").lazy_load({ paths = { "./snippets" } })
    return opts
  end,
}

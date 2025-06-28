return {
  "danymat/neogen",
  dependencies = "nvim-treesitter/nvim-treesitter",
  cmd = "Neogen",
  keys = {
    {
      "<leader>nf",
      function()
        require("neogen").generate({})
      end,
      desc = "Generate Annotations",
    },
  },
  ---@param _ LazyPlugin
  ---@param opts table
  opts = function(_, opts)
    local snippet_engine = nil

    if vim.snippet ~= nil then
      snippet_engine = "nvim"
    else
      local util = require("lazyvim.util")
      if util.has("luasnip") then
        snippet_engine = "luasnip"
      elseif util.has("snippy") then
        snippet_engine = "snippy"
      elseif vim.g.loaded_vsnip then
        snippet_engine = "vsnip"
      end
    end

    opts.snippet_engine = snippet_engine
  end,
}

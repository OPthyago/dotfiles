return {
  "JoosepAlviste/nvim-ts-context-commentstring",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  lazy = true,
  config = function()
    require("ts_context_commentstring").setup({})
  end,
}

return {
  "stevearc/conform.nvim",
  event = "VeryLazy",
  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
      javascript = { { "prettierd", "prettier" } },
      typescript = { { "prettierd", "prettier" } },
      -- Adicione outros formatadores aqui
    },
    -- uncomment this to enable formatting on save
    -- format_on_save = { timeout_ms = 500, lsp_fallback = true },
  },
}

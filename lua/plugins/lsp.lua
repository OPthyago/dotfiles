return {
  --MASON
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "luacheck",
        "shellcheck",
        "shfmt",
        "tailwindcss-language-server",
        "typescript-language-server",
        "css-lsp",
        "angular-language-server",
      })
    end,
  },
  --LSP Servers
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = { enabled = true },
      -- ↓↓↓ Função para desativar formatação/lint automático ↓↓↓
      on_attach = function(client, bufnr)
        -- Desativa formatação automática para TODOS os LSPs
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false

        -- (Opcional) Desativa diagnósticos (linting) em tempo real
        -- client.server_capabilities.diagnosticProvider = false
      end,
      ---@type lspconfig.options
      servers = {
        cssls = {},
        tailwindcss = {
          root_dir = function(...)
            return require("lspconfig.util").root_pattern(".git")(...)
          end,
        },
        tsserver = {
          root_dir = function(...)
            return require("lspconfig.util").root_pattern(".git")(...)
          end,
          single_file_support = false,
          -- ↓↓↓ Configurações específicas do tsserver para desativar linting ↓↓↓
          on_attach = function(client, bufnr)
            -- Garante que as capacidades de formatação estão desligadas
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentRangeFormattingProvider = false

            -- Desativa diagnósticos (mensagens de erro) do tsserver
            -- vim.lsp.handlers["textDocument/publishDiagnostics"] = function() end
          end,
          settings = {
            typescript = {
              inlayHints = {
                includeInlayParameterNameHints = "literal",
                -- ... (restante das configurações)
              },
            },
            javascript = {
              inlayHints = {
                includeInlayParameterNameHints = "all",
                -- ... (restante das configurações)
              },
            },
          },
        },
        html = {},
        lua_ls = {
          -- ... (configurações existentes)
        },
      },
      setup = {},
    },
  },
  {
    "nvim-cmp",
    dependencies = { "hrsh7th/cmp-emoji" },
    opts = function(_, opts)
      table.insert(opts.sources, { name = "emoji" })
    end,
  },
}

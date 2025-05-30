return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      "nvim-neotest/neotest-jest",
      "marilari88/neotest-vitest",
      "nvim-neotest/nvim-nio",
    },
    opts = {
      adapters = {
        ["neotest-jest"] = {
          jestCommand = function()
            local file = vim.fn.expand("%:p")
            local cmd = "npm test --"
            if file:find("/packages/") then
              cmd = "pnpm test --"
            end
            return cmd
          end,
          jestConfigFile = function()
            local file = vim.fn.expand("%:p")
            local root = require("lazyvim.util").root.get()

            if file:find("/packages/") then
              local packageRoot = file:match("(.-/packages/[^/]+/)")
              return packageRoot .. "jest.config.ts"
            end

            local configFiles = {
              "jest.config.ts",
              "jest.config.js",
              "vite.config.ts",
            }

            for _, configFile in ipairs(configFiles) do
              local found = vim.fn.glob(root .. "/" .. configFile, true)
              if found ~= "" then
                return found
              end
            end

            return root .. "/jest.config.ts"
          end,
          env = {
            NODE_OPTIONS = "--experimental-vm-modules",
            NODE_PATH = "node_modules",
          },
          cwd = require("lazyvim.util").root.get,
          discover_root = require("lazyvim.util").root.get,
        },
        ["neotest-vitest"] = {
          viteConfigFile = function()
            local root = require("lazyvim.util").root.get()
            return vim.fn.glob(root .. "/vite.config.ts") ~= "" and root .. "/vite.config.ts"
          end,
        },
      },
      status = { virtual_text = true },
      output = {
        open_on_run = true,
        timeout = 5000,
      },
      quickfix = {
        open = function()
          if require("lazyvim.util").has("trouble.nvim") then
            require("trouble").open({ mode = "quickfix", focus = false })
          else
            vim.cmd("copen")
          end
        end,
      },
    },
    config = function(_, opts)
      local adapters = {}
      for name, config in pairs(opts.adapters) do
        local adapter = require(name)
        if type(config) == "table" and adapter.setup then
          adapter.setup(config)
        end
        table.insert(adapters, adapter)
      end
      opts.adapters = adapters

      local neotest_ns = vim.api.nvim_create_namespace("neotest")
      vim.diagnostic.config({
        virtual_text = {
          format = function(diagnostic)
            return diagnostic.message:gsub("\n", " "):gsub("\t", " "):gsub("%s+", " "):gsub("^%s+", "")
          end,
        },
      }, neotest_ns)

      require("neotest").setup(opts)

      vim.api.nvim_create_user_command("NeotestDebug", function()
        local root = require("lazyvim.util").root.get()
        print("Root directory:", root)
        print("Jest config:", opts.adapters[1].jestConfigFile())
        print("Jest command:", opts.adapters[1].jestCommand())
      end, {})
    end,
    keys = {
      {
        "<leader>tt",
        function()
          require("neotest").run.run(vim.fn.expand("%"))
        end,
        desc = "Testes: Executar Arquivo",
      },
      {
        "<leader>tr",
        function()
          require("neotest").run.run()
        end,
        desc = "Testes: Executar Teste Mais Próximo",
      },
      {
        "<leader>tT",
        function()
          require("neotest").run.run(vim.loop.cwd())
        end,
        desc = "Testes: Executar Todos",
      },
      {
        "<leader>tl",
        function()
          require("neotest").run.run_last()
        end,
        desc = "Testes: Repetir Último",
      },
      {
        "<leader>ts",
        function()
          require("neotest").summary.toggle()
        end,
        desc = "Testes: Alternar Resumo",
      },
      {
        "<leader>to",
        function()
          require("neotest").output.open({ enter = true, auto_close = true })
        end,
        desc = "Testes: Mostrar Output",
      },
      {
        "<leader>tO",
        function()
          require("neotest").output_panel.toggle()
        end,
        desc = "Testes: Painel de Output",
      },
      {
        "<leader>tS",
        function()
          require("neotest").run.stop()
        end,
        desc = "Testes: Parar Execução",
      },
      {
        "<leader>tc",
        function()
          require("neotest").run.run({
            strategy = "integrated",
            extra_args = { "--coverage" },
          })
        end,
        desc = "Testes: Executar com Coverage",
      },
      {
        "<leader>tw",
        function()
          require("neotest").run.run({ extra_args = { "--watch" } })
        end,
        desc = "Testes: Executar com Watch",
      },
    },
  },
}

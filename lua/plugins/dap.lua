local js_based_languages = {
  "typescript",
  "javascript",
  "typescriptreact",
  "javascriptreact",
  "vue",
}

return {
  { "nvim-neotest/nvim-nio" },
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text",
      {
        "microsoft/vscode-js-debug",
        build = "npm install --legacy-peer-deps --no-save && npx gulp vsDebugServerBundle && mv dist out",
        version = "1.*",
      },
      {
        "mxsdev/nvim-dap-vscode-js",
        config = function()
          require("dap-vscode-js").setup({
            debugger_path = vim.fn.stdpath("data") .. "/lazy/vscode-js-debug",
            adapters = {
              "pwa-node",
              "pwa-chrome",
              {
                type = "pwa-chrome",
                port = 9222,
              },
            },
          })
        end,
      },
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")
      local Config = require("lazyvim.config")

      -- Define o nível de log para DEBUG para obter mais informações
      dap.set_log_level("DEBUG")

      -- Inicializa o dap-ui com a configuração padrão
      dapui.setup()

      -- Configuração de ícones para o DAP
      vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })
      for name, sign in pairs(Config.icons.dap) do
        sign = type(sign) == "table" and sign or { sign }
        vim.fn.sign_define("Dap" .. name, {
          text = sign[1],
          texthl = sign[2] or "DiagnosticInfo",
          linehl = sign[3],
          numhl = sign[3],
        })
      end

      -- Configuração do adaptador para Chrome
      dap.adapters["pwa-chrome"] = {
        type = "server",
        host = "localhost",
        port = 9222,
        executable = {
          command = "chrome", -- verifique se o comando "chrome" está no PATH; em alguns sistemas pode ser "google-chrome" ou "chromium"
          args = {
            "--remote-debugging-port=9222",
            "--user-data-dir=${workspaceFolder}/.vscode/chrome",
          },
        },
      }

      -- Mapeia "node-terminal" para "pwa-node" (que já está configurado com porta)
      if not dap.adapters["node-terminal"] then
        dap.adapters["node-terminal"] = dap.adapters["pwa-node"]
      end

      -- Configurações para linguagens baseadas em JS
      for _, language in ipairs(js_based_languages) do
        dap.configurations[language] = {
          {
            type = "pwa-node",
            request = "launch",
            name = "Launch File",
            program = "${file}",
            cwd = "${workspaceFolder}",
            sourceMaps = true,
            skipFiles = { "<node_internals>/**" },
          },
          {
            type = "pwa-node",
            request = "attach",
            name = "Attach to Process",
            processId = require("dap.utils").pick_process,
            cwd = "${workspaceFolder}",
            sourceMaps = true,
          },
          {
            type = "pwa-chrome",
            request = "launch",
            name = "Launch Chrome",
            url = "http://localhost:3000",
            webRoot = "${workspaceFolder}",
            port = 9222,
            userDataDir = "${workspaceFolder}/.vscode/chrome",
            sourceMaps = true,
          },
        }
      end

      -- Se existir um arquivo .vscode/launch.json, carrega-o
      if vim.fn.filereadable(".vscode/launch.json") then
        require("dap.ext.vscode").load_launchjs(nil, {
          ["pwa-node"] = js_based_languages,
          ["pwa-chrome"] = js_based_languages,
          ["node-terminal"] = js_based_languages,
        })
      end

      -- Keymap para iniciar a depuração
      vim.keymap.set("n", "<leader>da", function()
        vim.notify("Iniciando sessão de debug...", vim.log.levels.INFO)
        dap.continue()
      end, { desc = "Start Debugging" })

      -- Keymap para abrir/fechar a interface do DAP UI
      vim.keymap.set("n", "<leader>du", function()
        dapui.toggle()
      end, { desc = "Toggle Debug UI" })

      -- Keymap para abrir/fechar o REPL do DAP
      vim.keymap.set("n", "<leader>dr", function()
        dap.repl.toggle()
      end, { desc = "Toggle Debug REPL" })

      -- Keymap para abrir o arquivo de log do DAP para inspeção
      vim.keymap.set("n", "<leader>dl", function()
        local log_file = vim.fn.stdpath("data") .. "/dap.log"
        vim.cmd("edit " .. log_file)
      end, { desc = "Open DAP Log" })
    end,
  },
}

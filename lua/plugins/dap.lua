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
              { type = "pwa-node", port = 9223 },
              { type = "pwa-chrome", port = 9222 },
            },
          })
        end,
      },
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")
      local Config = require("lazyvim.config")

      dap.set_log_level("DEBUG")
      dapui.setup()

      -- Configuração de ícones
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

      -- Configurações para linguagens baseadas em JS
      for _, language in ipairs(js_based_languages) do
        dap.configurations[language] = {
          {
            type = "pwa-node",
            request = "launch",
            name = "Debug Current Test",
            runtimeExecutable = "node",
            runtimeArgs = {
              "--experimental-vm-modules",
              "--no-warnings",
              "${workspaceFolder}/node_modules/.bin/jest",
              "${file}",
              "--runInBand",
              "--watch",
            },
            cwd = "${workspaceFolder}",
            console = "integratedTerminal",
            internalConsoleOptions = "neverOpen",
            skipFiles = { "<node_internals>/**" },
            sourceMaps = true,
            env = {
              NODE_OPTIONS = "--experimental-vm-modules --no-warnings",
              TS_JEST_DISABLE_VER_CHECKER = "true",
            },
            resolveSourceMapLocations = {
              "${workspaceFolder}/**",
              "!**/node_modules/**",
            },
          },
          {
            type = "pwa-node",
            request = "launch",
            name = "Run All Tests",
            runtimeExecutable = "node",
            runtimeArgs = {
              "--experimental-vm-modules",
              "--no-warnings",
              "${workspaceFolder}/node_modules/.bin/jest",
              "--runInBand",
              "--watchAll",
            },
            cwd = "${workspaceFolder}",
            console = "integratedTerminal",
            internalConsoleOptions = "neverOpen",
            skipFiles = { "<node_internals>/**" },
            sourceMaps = true,
            env = {
              NODE_OPTIONS = "--experimental-vm-modules --no-warnings",
              TS_JEST_DISABLE_VER_CHECKER = "true",
            },
          },
          {
            type = "pwa-chrome",
            request = "launch",
            name = "Launch Chrome",
            url = "http://localhost:3000",
            webRoot = "${workspaceFolder}",
            userDataDir = "${workspaceFolder}/.vscode/chrome",
            sourceMaps = true,
          },
        }
      end

      -- Carregar launch.json
      if vim.fn.filereadable(".vscode/launch.json") then
        require("dap.ext.vscode").load_launchjs(nil, {
          ["pwa-node"] = js_based_languages,
          ["pva-chrome"] = js_based_languages,
        })
      end

      -- Keymaps
      vim.keymap.set("n", "<leader>da", function()
        vim.notify("Iniciando sessão de debug...", vim.log.levels.INFO)
        dap.continue()
      end, { desc = "Start Debugging" })

      vim.keymap.set("n", "<leader>du", function()
        dapui.toggle()
      end, { desc = "Toggle Debug UI" })

      vim.keymap.set("n", "<leader>dr", function()
        dap.repl.toggle()
      end, { desc = "Toggle Debug REPL" })

      vim.keymap.set("n", "<leader>dl", function()
        local log_file = vim.fn.stdpath("data") .. "/dap.log"
        vim.cmd("edit " .. log_file)
      end, { desc = "Open DAP Log" })
      -- Breakpoints
      vim.keymap.set("n", "<leader>db", function()
        require("dap").toggle_breakpoint()
      end, { desc = "Toggle Breakpoint" })

      vim.keymap.set("n", "<leader>dB", function()
        require("dap").set_breakpoint(vim.fn.input("Condition: "))
      end, { desc = "Conditional Breakpoint" })

      vim.keymap.set("n", "<leader>dlp", function()
        require("dap").set_breakpoint(nil, nil, vim.fn.input("Log message: "))
      end, { desc = "Logpoint" })
    end,
  },
}

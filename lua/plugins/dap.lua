return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "rcarriga/nvim-dap-ui",
    {
      "williamboman/mason.nvim",
      opts = function(_, opts)
        opts.ensure_installed = opts.ensure_installed or {}
        table.insert(opts.ensure_installed, "js-debug-adapter")
      end,
    },
  },
  keys = {
    {
      vim.keymap.set("n", "<leader>da", function()
        vim.notify("Starting debug session...", vim.log.levels.INFO)
        require("dap").continue()
      end, { desc = "Start Debugging" }),
    },
    {
      vim.keymap.set("n", "<leader>du", function()
        require("dapui").toggle()
      end, { desc = "Toggle Debug UI" }),
    },
    {
      vim.keymap.set("n", "<leader>dr", function()
        require("dap").repl.toggle()
      end, { desc = "Toggle Debug REPL" }),
    },
    {
      vim.keymap.set("n", "<leader>dl", function()
        local log_file = vim.fn.stdpath("data") .. "/dap.log"
        vim.cmd("edit " .. log_file)
      end, { desc = "Open DAP Log" }),
    },
    {
      vim.keymap.set("n", "<leader>dc", require("dap").continue, { desc = "Continue" }),
    },
    {
      vim.keymap.set("n", "<leader>do", require("dap").step_over, { desc = "Step Over" }),
    },
    {

      vim.keymap.set("n", "<leader>di", require("dap").step_into, { desc = "Step Into" }),
    },
    {
      vim.keymap.set("n", "<leader>dlp", function()
        require("dap").set_breakpoint(nil, nil, vim.fn.input("Log message: "))
      end, { desc = "Logpoint" }),
    },
    {
      vim.keymap.set("n", "<leader>db", function()
        require("dap").toggle_breakpoint()
      end, { desc = "Toggle Breakpoint" }),
    },
    {
      vim.keymap.set("n", "<leader>dB", function()
        require("dap").set_breakpoint(vim.fn.input("Condition: "))
      end, { desc = "Conditional Breakpoint" }),
    },
  },
  config = function()
    local js_filetypes = { "typescript", "javascript", "typescriptreact", "javascriptreact" }
    local dap = require("dap")
    local dapui = require("dapui")
    local Config = require("lazyvim.config")
    local vscode = require("dap.ext.vscode")

    --Setting the log level
    --dap.set_log_level("TRACE") -- uncomment this line to enable comments

    --UI Setting
    vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })
    for name, sign in pairs(Config.icons.dap) do
      sign = type(sign) == "table" and sign or { sign }
      vim.fn.sign_define("Dap" .. name, {
        text = sign[1],
        texthl = sign[2] or "DiagnosticInfo",
      })
    end

    dapui.setup({
      layouts = {
        {
          elements = { "scopes", "breakpoints", "stacks", "watches" },
          size = 40,
          position = "left",
        },
        {
          elements = { "repl", "console" },
          size = 10,
          position = "bottom",
        },
      },
    })

    --Setting adapters
    if not dap.adapters["pwa-node"] then
      require("dap").adapters["pwa-node"] = {
        type = "server",
        host = "localhost",
        port = "${port}",
        executable = {
          command = "node",
          args = {
            LazyVim.get_pkg_path("js-debug-adapter", "/js-debug/src/dapDebugServer.js"),
            "${port}",
          },
        },
      }
    end

    if not dap.adapters["node"] then
      dap.adapters["node"] = function(cb, config)
        if config.type == "node" then
          config.type = "pwa-node"
        end
        local nativeAdapter = dap.adapters["pwa-node"]
        if type(nativeAdapter) == "function" then
          nativeAdapter(cb, config)
        else
          cb(nativeAdapter)
        end
      end
    end

    vscode.type_to_filetypes["node"] = js_filetypes
    vscode.type_to_filetypes["pwa-node"] = js_filetypes

    for _, language in ipairs(js_filetypes) do
      if not dap.configurations[language] then
        dap.configurations[language] = {
          {
            type = "pwa-node",
            request = "launch",
            name = "Launch file",
            program = "${file}",
            cwd = "${workspaceFolder}",
          },
          {
            type = "pwa-node",
            request = "attach",
            name = "Attach",
            processId = require("dap.utils").pick_process,
            cwd = "${workspaceFolder}",
          },
        }
      end
    end

    -- Listeners to open and close dapui
    dap.listeners.after.event_initialized["dapui_config"] = function()
      dapui.open({ reset = true })
    end
    dap.listeners.before.event_terminated["dapui_config"] = function()
      dapui.close()
    end
    dap.listeners.before.event_exited["dapui_config"] = function()
      dapui.close()
    end
  end,
}

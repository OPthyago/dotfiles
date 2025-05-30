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
      "<leader>dB",
      function()
        require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
      end,
      desc = "Breakpoint Condition",
    },
    {
      "<leader>db",
      function()
        require("dap").toggle_breakpoint()
      end,
      desc = "Toggle Breakpoint",
    },
    {
      "<leader>dc",
      function()
        require("dap").continue()
      end,
      desc = "Run/Continue",
    },
    {
      "<leader>da",
      function()
        local dap = require("dap")
        local opt = vim.fn.inputlist({
          "Select the configuration:",
          "1. Default (DAP)",
          "2. Custom Setting",
        })

        if opt == 1 then
          dap.continue()
          return
        elseif opt == 2 then
          -- Prompt the user to select a workspace folder, read the package.json file, and extract the scripts
          local folder = vim.fn.input("Workspace Folder: ", vim.loop.cwd(), "file")
          local package_json_path = folder .. "/package.json"
          if vim.fn.filereadable(package_json_path) == 0 then
            print("package.json not found in " .. folder)
            return
          end
          local content = table.concat(vim.fn.readfile(package_json_path), "\n")
          local ok, package_data = pcall(vim.fn.json_decode, content)
          if not ok then
            print("Failed to parse package.json")
            return
          end
          if not package_data.scripts then
            print("No scripts found in package.json")
            return
          end

          -- Filter out scripts related to build, deploy, or release by checking both the script name and its command
          local script_names = {}
          for script, cmd in pairs(package_data.scripts) do
            local lower_script = string.lower(script)
            local lower_cmd = string.lower(cmd)
            if
              not (
                lower_script:find("deploy")
                or lower_script:find("release")
                or lower_cmd:find("deploy")
                or lower_cmd:find("release")
              )
            then
              table.insert(script_names, script)
            end
          end

          if #script_names == 0 then
            print("No local run scripts found in package.json")
            return
          end

          table.sort(script_names)
          local choices = { "Choose a script:" }
          for i, script in ipairs(script_names) do
            table.insert(choices, string.format("%d. %s", i, script))
          end
          local script_choice = vim.fn.inputlist(choices)
          if script_choice < 1 or script_choice > #script_names then
            print("Invalid option")
            return
          end
          local selected_script = script_names[script_choice]

          -- Check if the script command contains "node --inspect". If not, add the flag via NODE_OPTIONS.
          local script_command = package_data.scripts[selected_script]
          local config_env = {}
          if not script_command:find("node%s+%-%-inspect") then
            config_env.NODE_OPTIONS = "--inspect"
          end

          local selected_config = {
            type = "pwa-node",
            request = "launch",
            name = "NPM Script: " .. selected_script,
            runtimeExecutable = "npm",
            runtimeArgs = { "run", selected_script },
            cwd = folder,
            console = "integratedTerminal",
            internalConsoleOptions = "neverOpen",
            env = config_env,
          }
          dap.run(selected_config)
          return
        else
          print("Invalid option")
          return
        end
      end,
      desc = "Start debugging (choose npm script)",
    },
    {
      "<leader>dC",
      function()
        require("dap").run_to_cursor()
      end,
      desc = "Run to Cursor",
    },
    {
      "<leader>dg",
      function()
        require("dap").goto_()
      end,
      desc = "Go to Line (No Execute)",
    },
    {
      "<leader>di",
      function()
        require("dap").step_into()
      end,
      desc = "Step Into",
    },
    {
      "<leader>dj",
      function()
        require("dap").down()
      end,
      desc = "Down",
    },
    {
      "<leader>dk",
      function()
        require("dap").up()
      end,
      desc = "Up",
    },
    {
      "<leader>dl",
      function()
        require("dap").run_last()
      end,
      desc = "Run Last",
    },
    {
      "<leader>do",
      function()
        require("dap").step_out()
      end,
      desc = "Step Out",
    },
    {
      "<leader>dO",
      function()
        require("dap").step_over()
      end,
      desc = "Step Over",
    },
    {
      "<leader>dP",
      function()
        require("dap").pause()
      end,
      desc = "Pause",
    },
    {
      "<leader>dr",
      function()
        require("dap").repl.toggle()
      end,
      desc = "Toggle REPL",
    },
    {
      "<leader>ds",
      function()
        require("dap").session()
      end,
      desc = "Session",
    },
    {
      "<leader>dt",
      function()
        require("dap").terminate()
      end,
      desc = "Terminate",
    },
    {
      "<leader>du",
      function()
        require("dapui").toggle()
      end,
      desc = "Toggle UI",
    },
  },
  config = function()
    local js_filetypes = { "typescript", "javascript", "typescriptreact", "javascriptreact" }
    local dap = require("dap")
    local dapui = require("dapui")
    local Config = require("lazyvim.config")
    local vscode = require("dap.ext.vscode")

    --Setting the log level
    dap.set_log_level("TRACE") -- uncomment this line to enable comments

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

      -- uncomment to enable jest testing directly in the DAP default
      --table.insert(dap.configurations[language], {
      --  type = "pwa-node",
      --  request = "launch",
      --  name = "Jest Tests",
      --  runtimeExecutable = "npm",
      --  runtimeArgs = { "run", "test", "--", "--watch" },
      --  cwd = "${workspaceFolder}",
      --  console = "integratedTerminal",
      --  internalConsoleOptions = "neverOpen",
      --})
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

    -- Keymaps
  end,
}

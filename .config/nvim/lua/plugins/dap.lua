-- ~/.config/nvim/lua/plugins/dap.lua
return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text",
      "nvim-telescope/telescope-dap.nvim",
      "jedrzejboczar/nvim-dap-cortex-debug",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")
      
      -- Setup DAP UI
      dapui.setup({
        controls = {
          element = "repl",
          enabled = true,
        },
        element_mappings = {},
        expand_lines = true,
        floating = {
          border = "single",
          mappings = {
            close = { "q", "<Esc>" },
          },
        },
        force_buffers = true,
        icons = { expanded = "", collapsed = "", current_frame = "" },
        mappings = {
          edit = "e",
          expand = { "<CR>", "<2-LeftMouse>" },
          open = "o",
          remove = "d",
          repl = "r",
          toggle = "t",
        },
        render = {
          max_type_length = nil,
          max_value_lines = 100,
        },
      })
      
      -- Setup virtual text
      require("nvim-dap-virtual-text").setup({
        enabled = true,
        enabled_commands = true,
        highlight_changed_variables = true,
        highlight_new_as_changed = false,
        show_stop_reason = true,
        commented = false,
        only_first_definition = true,
        all_references = false,
        clear_on_continue = false,
        display_callback = function(variable, buf, stackframe, node, options)
          if options.virt_text_pos == "inline" then
            return " = " .. variable.value
          else
            return variable.name .. " = " .. variable.value
          end
        end,
        virt_text_pos = vim.fn.has("nvim-0.10") == 1 and "inline" or "eol",
        all_frames = false,
        virt_lines = false,
        virt_text_win_col = nil,
      })
      
      -- Setup cortex-debug adapter
      require("dap-cortex-debug").setup({
        debug = false, -- Set to true for debug output
        -- Extension path is usually auto-detected
        extension_path = nil,
        lib_extension = nil,
        node_path = "node", -- Path to node.js executable
        dapui_rtt = true, -- Enable RTT output in DAP UI
      })
      
      -- Auto-open/close DAP UI
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
      
      -- Load VS Code launch.json configurations
      local function load_vscode_launch_json()
        local cwd = vim.fn.getcwd()
        local launch_json_path = cwd .. "/.vscode/launch.json"
        
        if vim.fn.filereadable(launch_json_path) == 1 then
          require("dap.ext.vscode").load_launchjs(launch_json_path, {
            ["cortex-debug"] = {"c", "cpp", "rust", "zig", "arm"},
          })
          print("Loaded launch.json from " .. launch_json_path)
        end
      end
      
      -- Load configurations on startup and when changing directories
      vim.api.nvim_create_autocmd({"VimEnter", "DirChanged"}, {
        callback = load_vscode_launch_json,
      })
      
      -- Manual command to reload launch.json
      vim.api.nvim_create_user_command("DapLoadLaunchJson", load_vscode_launch_json, {
        desc = "Load DAP configurations from .vscode/launch.json"
      })
      
      -- Configure signs
      vim.fn.sign_define("DapBreakpoint", {
        text = "●",
        texthl = "DapBreakpoint",
        linehl = "",
        numhl = ""
      })
      vim.fn.sign_define("DapBreakpointCondition", {
        text = "◆",
        texthl = "DapBreakpointCondition",
        linehl = "",
        numhl = ""
      })
      vim.fn.sign_define("DapLogPoint", {
        text = "◆",
        texthl = "DapLogPoint",
        linehl = "",
        numhl = ""
      })
      vim.fn.sign_define("DapStopped", {
        text = "→",
        texthl = "DapStopped",
        linehl = "DapStoppedLine",
        numhl = "DapStopped"
      })
      vim.fn.sign_define("DapBreakpointRejected", {
        text = "●",
        texthl = "DapBreakpointRejected",
        linehl = "",
        numhl = ""
      })
    end,
  },
  {
    -- Key mappings for DAP
    "AstroNvim/astrocore",
    opts = {
      mappings = {
        n = {
          -- Function key mappings (traditional debugger style)
          ["<F5>"] = { function() require("dap").continue() end, desc = "Debug: Continue" },
          ["<F10>"] = { function() require("dap").step_over() end, desc = "Debug: Step Over" },
          ["<F11>"] = { function() require("dap").step_into() end, desc = "Debug: Step Into" },
          ["<F12>"] = { function() require("dap").step_out() end, desc = "Debug: Step Out" },
          
          -- Leader key mappings
          ["<leader>db"] = { function() require("dap").toggle_breakpoint() end, desc = "Debug: Toggle Breakpoint" },
          ["<leader>dB"] = { 
            function() 
              require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: ")) 
            end, 
            desc = "Debug: Conditional Breakpoint" 
          },
          ["<leader>dc"] = { function() require("dap").continue() end, desc = "Debug: Continue" },
          ["<leader>dC"] = { function() require("dap").run_to_cursor() end, desc = "Debug: Run to Cursor" },
          ["<leader>dd"] = { function() require("dap").disconnect() end, desc = "Debug: Disconnect" },
          ["<leader>dg"] = { function() require("dap").session() end, desc = "Debug: Get Session" },
          ["<leader>di"] = { function() require("dap").step_into() end, desc = "Debug: Step Into" },
          ["<leader>do"] = { function() require("dap").step_over() end, desc = "Debug: Step Over" },
          ["<leader>du"] = { function() require("dap").step_out() end, desc = "Debug: Step Out" },
          ["<leader>dp"] = { function() require("dap").pause() end, desc = "Debug: Pause" },
          ["<leader>dr"] = { function() require("dap").repl.toggle() end, desc = "Debug: Toggle REPL" },
          ["<leader>ds"] = { function() require("dap").session() end, desc = "Debug: Session" },
          ["<leader>dt"] = { function() require("dap").terminate() end, desc = "Debug: Terminate" },
          ["<leader>dw"] = { function() require("dap.ui.widgets").hover() end, desc = "Debug: Widgets" },
          ["<leader>dl"] = { function() require("dap").run_last() end, desc = "Debug: Run Last" },
          ["<leader>dL"] = { ":DapLoadLaunchJson<CR>", desc = "Debug: Load launch.json" },
          
          -- DAP UI mappings
          ["<leader>du"] = { function() require("dapui").toggle() end, desc = "Debug: Toggle UI" },
          ["<leader>de"] = { function() require("dapui").eval() end, desc = "Debug: Evaluate" },
        },
        v = {
          ["<leader>de"] = { function() require("dapui").eval() end, desc = "Debug: Evaluate Selection" },
        },
      },
    },
  },
}


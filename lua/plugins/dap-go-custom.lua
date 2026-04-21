return {
  "mfussenegger/nvim-dap",
  opts = function()
    local dap = require("dap")

    -- Initialize the go configuration table if it doesn't exist
    dap.configurations.go = dap.configurations.go or {}

    -- Add the interactive configuration
    table.insert(dap.configurations.go, {
      type = "go",
      name = "Debug Binary (Prompt for Path & Args)",
      request = "launch",
      mode = "exec",
      -- Prompt 1: The Path to the binary
      program = function()
        return vim.fn.input("Path to binary: ", vim.fn.getcwd() .. "/", "file")
      end,
      -- Prompt 2: The Arguments
      args = function()
        local args_str = vim.fn.input("Arguments: ")
        return vim.split(args_str, " +") -- Splits by one or more spaces
      end,
      cwd = "${workspaceFolder}",
    })
  end,
}

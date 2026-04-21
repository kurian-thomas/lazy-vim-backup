return {
  "mfussenegger/nvim-dap-python",
  dependencies = "mfussenegger/nvim-dap",
  config = function()
    local dap = require("dap")

    -- Adapter: Points to the Mason-installed debugpy
    local debugpy_path = vim.fn.expand("~/.local/share/nvim/mason/packages/debugpy/venv/bin/python")
    require("dap-python").setup(debugpy_path)

    table.insert(dap.configurations.python, {
      type = "python",
      request = "launch",
      name = "Module: src.main (Smart .venv Search)",
      module = "src.main",
      args = function()
        local args_string = vim.fn.input("Arguments: ")
        return vim.split(args_string, " +") -- Handles one or more spaces
      end,
      console = "integratedTerminal",
      pythonPath = function()
        -- Search upwards for .venv from the current file's directory
        local venv = vim.fs.find({ ".venv" }, {
          upward = true,
          type = "directory",
          path = vim.fn.expand("%:p:h"),
        })[1]

        if venv and vim.fn.executable(venv .. "/bin/python") == 1 then
          return venv .. "/bin/python" -- Found the local venv
        end
        return "/usr/bin/python3"      -- Fallback
      end,
    })
  end,
}

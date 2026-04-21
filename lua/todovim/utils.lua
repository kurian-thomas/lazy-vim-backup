local state = require("todovim.state").state
local M = {}

function M.expand_path(path)
  if path:sub(1, 1) == "~" then return os.getenv("HOME") .. path:sub(2) end
  return path
end

function M.ensure_dir(path)
  local dir = vim.fn.fnamemodify(path, ":h")
  if vim.fn.isdirectory(dir) == 0 then vim.fn.mkdir(dir, "p") end
end

function M.save_buffer(buf)
  if buf and vim.api.nvim_buf_is_valid(buf) then
    vim.api.nvim_buf_call(buf, function() vim.cmd("silent! write") end)
  end
end

function M.get_progress_stats()
  local total = 0
  local done = 0

  for _, buf in ipairs(state.bufs) do
    if vim.api.nvim_buf_is_valid(buf) then
      local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
      for _, line in ipairs(lines) do
        if not line:match("^%s*#") then
          if line:match("%- %[ %]") then
            total = total + 1
          elseif line:match("%- %[x%]") then
            total = total + 1
            done = done + 1
          end
        end
      end
    end
  end

  if total == 0 then return 0 end
  return math.floor((done / total) * 100)
end

return M

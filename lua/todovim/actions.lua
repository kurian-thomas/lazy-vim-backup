local state = require("todovim.state").state
local utils = require("todovim.utils")
local config = require("todovim.config")
local ui = require("todovim.ui")

local M = {}

function M.navigate(direction)
  local cur = vim.api.nvim_get_current_win()
  local idx = 1
  for i, w in ipairs(state.wins) do if w == cur then idx = i end end

  local next_idx = (direction == "next") and (idx % 3) + 1 or ((idx - 2) % 3) + 1
  if state.wins[next_idx] and vim.api.nvim_win_is_valid(state.wins[next_idx]) then
    vim.api.nvim_set_current_win(state.wins[next_idx])
    ui.update_highlights()
  end
end

function M.archive_done_tasks()
  local done_buf = state.bufs[3]
  local lines = vim.api.nvim_buf_get_lines(done_buf, 0, -1, false)
  local content = {}
  for _, line in ipairs(lines) do if line ~= "" then table.insert(content, line) end end

  if #content == 0 then return end

  local path = utils.expand_path(config.current.archive_file)
  utils.ensure_dir(path)
  local file = io.open(path, "a")
  if file then
    file:write("\n# Archived " .. os.date("%Y-%m-%d") .. "\n")
    for _, l in ipairs(content) do file:write(l .. "\n") end
    file:close()
  end

  vim.api.nvim_buf_set_lines(done_buf, 0, -1, false, {})
  utils.save_buffer(done_buf)
  ui.render_header()
  vim.notify("Archived " .. #content, vim.log.levels.INFO)
end

function M.toggle_todo()
  local win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_win_get_buf(win)
  local line = vim.api.nvim_get_current_line()
  local new = line:match("%- %[ %]") and line:gsub("%- %[ %]", "- [x]")
      or line:match("%- %[x%]") and line:gsub("%- %[x%]", "- [ ]")
      or "- [ ] " .. line
  vim.api.nvim_set_current_line(new)
  utils.save_buffer(buf)
  ui.render_header()
end

function M.add_new_task()
  local win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_win_get_buf(win)
  local r = vim.api.nvim_win_get_cursor(win)[1]
  vim.api.nvim_buf_set_lines(buf, r, r, false, { "- [ ] " })
  vim.api.nvim_win_set_cursor(win, { r + 1, 6 })
  vim.cmd("startinsert")
  ui.render_header()
end

function M.delete_line()
  local win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_win_get_buf(win)
  vim.api.nvim_del_current_line()
  utils.save_buffer(buf)
  ui.render_header()
end

function M.move_line_circular(direction)
  local cur = vim.api.nvim_get_current_win()
  local idx = 1
  for i, w in ipairs(state.wins) do if w == cur then idx = i end end

  local line = vim.api.nvim_get_current_line()
  if line == "" then return end

  local target_idx = (direction == "next") and (idx % 3) + 1 or ((idx - 2) % 3) + 1
  if target_idx == 3 then
    line = line:gsub("%- %[ %]", "- [x]")
  elseif idx == 3 then
    line = line:gsub("%- %[x%]", "- [ ]")
  end

  vim.api.nvim_del_current_line()
  utils.save_buffer(state.bufs[idx])

  local t_buf = state.bufs[target_idx]
  vim.api.nvim_buf_set_lines(t_buf, -1, -1, false, { line })
  utils.save_buffer(t_buf)
  ui.render_header()
end

function M.move_line_vertical(direction)
  local win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_win_get_buf(win)
  local row = vim.api.nvim_win_get_cursor(win)[1]
  local max = vim.api.nvim_buf_line_count(buf)

  if direction == "up" and row > 1 then
    local current_line = vim.api.nvim_buf_get_lines(buf, row - 1, row, false)[1]
    local line_above = vim.api.nvim_buf_get_lines(buf, row - 2, row - 1, false)[1]
    vim.api.nvim_buf_set_lines(buf, row - 2, row, false, { current_line, line_above })
    vim.api.nvim_win_set_cursor(win, { row - 1, 0 })
  elseif direction == "down" and row < max then
    local current_line = vim.api.nvim_buf_get_lines(buf, row - 1, row, false)[1]
    local line_below = vim.api.nvim_buf_get_lines(buf, row, row + 1, false)[1]
    vim.api.nvim_buf_set_lines(buf, row - 1, row + 1, false, { line_below, current_line })
    vim.api.nvim_win_set_cursor(win, { row + 1, 0 })
  end
  utils.save_buffer(buf)
end

return M

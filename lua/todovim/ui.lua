local config = require("todovim.config")
local state = require("todovim.state").state
local utils = require("todovim.utils")

local M = {}

function M.set_syntax(buf)
  vim.api.nvim_buf_call(buf, function()
    vim.bo.filetype = "markdown"
    vim.cmd([[syntax match TodoUrgent /@urgent/ containedin=ALL]])
    vim.cmd([[syntax match TodoHigh /@high/ containedin=ALL]])
    vim.cmd([[syntax match TodoProject /#[a-zA-Z0-9_-]\+/ containedin=ALL]])
    vim.cmd([[highlight default link TodoUrgent ErrorMsg]])
    vim.cmd([[highlight default link TodoHigh WarningMsg]])
    vim.cmd([[highlight default link TodoProject Identifier]])
  end)
end

function M.update_highlights()
  local current_win = vim.api.nvim_get_current_win()
  for _, win in ipairs(state.wins) do
    if vim.api.nvim_win_is_valid(win) then
      if win == current_win then
        vim.api.nvim_set_option_value("winhighlight", "FloatBorder:FloatBorder", { win = win })
      else
        vim.api.nvim_set_option_value("winhighlight", "FloatBorder:Comment", { win = win })
      end
    end
  end
end

function M.get_win_config(index)
  local opts = config.current
  local screen_w = vim.o.columns
  local total_width_raw = math.floor(screen_w * opts.width)
  local win_width = math.floor(total_width_raw / 3)
  local exact_total_width = win_width * 3

  local total_height = math.floor(vim.o.lines * opts.height)
  local start_col = math.floor((screen_w - exact_total_width) / 2)
  local row = math.floor((vim.o.lines - total_height) / 2)
  local col = start_col + ((index - 1) * win_width)

  return {
    relative = "editor",
    width = win_width - 2,
    height = total_height,
    col = col,
    row = row,
    border = opts.border,
    style = "minimal",
    title = opts.titles[index] or "",
    title_pos = "center",
    zindex = 50
  }
end

function M.render_header()
  if not state.header_buf or not vim.api.nvim_buf_is_valid(state.header_buf) then return end

  local percent = utils.get_progress_stats()
  local bar_width = 15
  local filled = math.floor((percent / 100) * bar_width)
  local bar = string.rep("█", filled) .. string.rep("░", bar_width - filled)

  local keys =
  "Nav b/w Panels: C-S-←/→ | Move Item: C-S-←/→ | C-↑|↓ | Toggle Check: <Ent> | Add Emty Check: o | Del: C-d | Archive: <Ldr>a | Quit: q"
  local right_text = string.format("%s %3d%% ", bar, percent)

  local win_width = vim.api.nvim_win_get_width(state.header_win)
  local keys_width = vim.fn.strdisplaywidth(keys)
  local right_width = vim.fn.strdisplaywidth(right_text)

  local padding_len = win_width - keys_width - right_width
  if padding_len < 0 then padding_len = 1 end

  local line = keys .. string.rep(" ", padding_len) .. right_text
  vim.api.nvim_buf_set_lines(state.header_buf, 0, -1, false, { line })
end

function M.open_backdrop()
  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, false, {
    relative = "editor",
    width = vim.o.columns,
    height = vim.o.lines,
    col = 0,
    row = 0,
    style = "minimal",
    zindex = 1
  })
  vim.api.nvim_set_hl(0, "KanbanBackdrop", { bg = "#000000", default = true })
  vim.api.nvim_set_option_value("winhighlight", "Normal:KanbanBackdrop", { win = win })
  vim.api.nvim_set_option_value("winblend", 40, { win = win })
  state.backdrop_win = win
end

function M.open_header_window()
  local opts = config.current
  local screen_w = vim.o.columns
  local total_width_raw = math.floor(screen_w * opts.width)
  local win_width = math.floor(total_width_raw / 3)
  local exact_total_width = win_width * 3
  local start_col = math.floor((screen_w - exact_total_width) / 2)
  local row = math.floor((vim.o.lines - math.floor(vim.o.lines * opts.height)) / 2)

  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, false, {
    relative = "editor",
    width = exact_total_width - 2,
    height = 1,
    col = start_col,
    row = row - 3,
    style = "minimal",
    border = opts.border,
    zindex = 50
  })

  vim.api.nvim_set_option_value("winhighlight", "Normal:Normal,FloatBorder:Comment", { win = win })
  state.header_win = win
  state.header_buf = buf
end

function M.resize_windows()
  local opts = config.current

  -- Resize Backdrop
  if state.backdrop_win and vim.api.nvim_win_is_valid(state.backdrop_win) then
    vim.api.nvim_win_set_config(state.backdrop_win, { width = vim.o.columns, height = vim.o.lines })
  end

  -- Resize Header
  if state.header_win and vim.api.nvim_win_is_valid(state.header_win) then
    local screen_w = vim.o.columns
    local total_width_raw = math.floor(screen_w * opts.width)
    local win_width = math.floor(total_width_raw / 3)
    local exact_total_width = win_width * 3
    local start_col = math.floor((screen_w - exact_total_width) / 2)
    local row = math.floor((vim.o.lines - math.floor(vim.o.lines * opts.height)) / 2)

    vim.api.nvim_win_set_config(state.header_win, {
      width = exact_total_width - 2, height = 1, col = start_col, row = row - 3, relative = "editor"
    })
    M.render_header()
  end

  -- Resize Columns
  for i, win in ipairs(state.wins) do
    if vim.api.nvim_win_is_valid(win) then
      local conf = M.get_win_config(i)
      conf.style = nil
      conf.border = opts.border
      vim.api.nvim_win_set_config(win, conf)
    end
  end
end

return M

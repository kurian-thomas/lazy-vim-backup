local config = require("todovim.config")
local state_mod = require("todovim.state")
local state = state_mod.state
local utils = require("todovim.utils")
local ui = require("todovim.ui")
local actions = require("todovim.actions")

local M = {}

local function close_all_windows()
  if state.augroup then
    vim.api.nvim_del_augroup_by_id(state.augroup)
    state.augroup = nil
  end

  for _, buf in ipairs(state.bufs) do utils.save_buffer(buf) end
  for _, win in ipairs(state.wins) do
    if vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_close(win, true) end
  end
  if state.header_win and vim.api.nvim_win_is_valid(state.header_win) then
    vim.api.nvim_win_close(state.header_win, true)
  end
  if state.backdrop_win and vim.api.nvim_win_is_valid(state.backdrop_win) then
    vim.api.nvim_win_close(state.backdrop_win, true)
  end

  state_mod.reset()
end

local function toggle_floating_files(opts)
  if #state.wins > 0 and vim.api.nvim_win_is_valid(state.wins[1]) then
    close_all_windows(); return
  end

  -- Merge temp opts if provided (e.g. from command args), otherwise use global config
  local current_opts = config.current
  if opts and opts.target_file then
    -- Logic for specific target file override if needed
    -- For now we just stick to config.current or assume user updated config
  end

  ui.open_backdrop()
  ui.open_header_window()

  -- Auto resize
  state.augroup = vim.api.nvim_create_augroup("KanbanResize", { clear = true })
  vim.api.nvim_create_autocmd("VimResized", {
    group = state.augroup,
    callback = ui.resize_windows,
  })

  local files = current_opts.files
  for i = 1, 3 do
    local path = utils.expand_path(files[i] or "~/notes/scratch_" .. i .. ".md")
    utils.ensure_dir(path)
    local buf = vim.fn.bufnr(path, true)
    if buf == -1 then
      buf = vim.api.nvim_create_buf(false, false); vim.api.nvim_buf_set_name(buf, path)
    end
    if not vim.api.nvim_buf_is_loaded(buf) then vim.fn.bufload(buf) end
    vim.bo[buf].swapfile = false
    ui.set_syntax(buf)

    local win = vim.api.nvim_open_win(buf, true, ui.get_win_config(i))
    table.insert(state.wins, win)
    table.insert(state.bufs, buf)

    local map_opts = { noremap = true, silent = true, buffer = buf }
    vim.keymap.set('n', '<C-S-Right>', function() actions.navigate("next") end, map_opts)
    vim.keymap.set('n', '<C-S-Left>', function() actions.navigate("prev") end, map_opts)
    vim.keymap.set('n', '<C-Right>', function() actions.move_line_circular("next") end, map_opts)
    vim.keymap.set('n', '<C-Left>', function() actions.move_line_circular("prev") end, map_opts)
    vim.keymap.set('n', '<C-Up>', function() actions.move_line_vertical("up") end, map_opts)
    vim.keymap.set('n', '<C-Down>', function() actions.move_line_vertical("down") end, map_opts)
    vim.keymap.set('n', '<Enter>', actions.toggle_todo, map_opts)
    vim.keymap.set('n', 'o', actions.add_new_task, map_opts)
    vim.keymap.set('n', '<C-d>', actions.delete_line, map_opts)
    vim.keymap.set('n', '<leader>a', actions.archive_done_tasks, map_opts)
    vim.keymap.set('n', 'q', close_all_windows, map_opts)
  end

  vim.api.nvim_set_current_win(state.wins[2])
  ui.update_highlights()
  ui.render_header()
end

M.setup = function(opts)
  config.setup(opts)
  vim.api.nvim_create_user_command("Td", function() toggle_floating_files() end, {})
end

return M

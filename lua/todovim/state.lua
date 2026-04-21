local M = {}

M.state = {
  wins = {},
  bufs = {},
  header_win = nil,
  header_buf = nil,
  backdrop_win = nil,
  augroup = nil,
}

function M.reset()
  M.state.wins = {}
  M.state.bufs = {}
  M.state.header_win = nil
  M.state.backdrop_win = nil
  -- Note: We don't reset augroup here usually, handled in close logic
end

return M

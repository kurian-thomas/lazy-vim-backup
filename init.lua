-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- TODO Float
local todo_vim = require("todovim")
-- todo_float.setup({
-- target_file = "~/notes/todo.md",
-- border = "single",       -- single, rounded, etc.
-- width = 0.8,             -- width of window in % of screen size
-- height = 0.8,            -- height of window in % of screen size
-- position = "center",     -- topleft, topright, bottomleft, bottomright
-- })

todo_vim.setup({
  files = {
    "~/notes/todo.md",
    "~/notes/pending.md",
    "~/notes/done.md"
  },
  width = 0.9, -- Make it a bit wider to fit 3 columns comfortably
})

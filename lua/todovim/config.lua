local M = {}

M.defaults = {
  files = {
    "~/notes/todo.md",
    "~/notes/pending.md",
    "~/notes/done.md",
  },
  archive_file = "~/notes/archive.md",
  titles = { " TODO ", " WORK IN PROGRESS ", " DONE " },
  border = "single",
  width = 0.8,
  height = 0.8,
}

M.current = vim.deepcopy(M.defaults)

function M.setup(opts)
  M.current = vim.tbl_deep_extend("force", M.defaults, opts or {})
end

return M

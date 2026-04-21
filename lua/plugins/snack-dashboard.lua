local vimHeader = [[
███╗   ██╗ ██████╗ ██╗   ██╗ █████╗     ██╗   ██╗██╗███╗   ███╗
████╗  ██║██╔═══██╗██║   ██║██╔══██╗    ██║   ██║██║████╗ ████║
██╔██╗ ██║██║   ██║██║   ██║███████║    ██║   ██║██║██╔████╔██║
██║╚██╗██║██║   ██║╚██╗ ██╔╝██╔══██║    ╚██╗ ██╔╝██║██║╚██╔╝██║
██║ ╚████║╚██████╔╝ ╚████╔╝ ██║  ██║     ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝  ╚═══╝ ╚═════╝   ╚═══╝  ╚═╝  ╚═╝      ╚═══╝  ╚═╝╚═╝     ╚═╝
]]

local art = require("assests/ascii_art/dashboard_art").get()

local helperKeys = {
  { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
  { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
  { icon = " ", key = "p", desc = "Projects", action = ":lua Snacks.dashboard.pick('projects')" },
  { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
  { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
  { icon = " ", key = "c", desc = "Config", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
  { icon = " ", key = "s", desc = "Restore Session", section = "session" },
  { icon = " ", key = "x", desc = "Lazy Extras", action = ":LazyExtras" },
  { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy", enabled = package.loaded.lazy ~= nil },
  { icon = " ", key = "q", desc = "Quit", action = ":qa" },
}

return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    bigfile = { enabled = true },
    dashboard = {
      enabled = true,
      vertical = false,
      preset = {
        header = vimHeader,
        keys = helperKeys,
      },
      sections = {
        {
          pane = 1,
          text = art,
          padding = 5,
        },
        {
          pane = 2,
          section = "header",
        },
        {
          pane = 2,
          section = "keys",
          padding = 11,
        },
        { pane = 2, padding = 1 },
        {
          pane = 1,
          icon = " ",
          title = "Recent Files",
          section = "recent_files",
          indent = 2,
        },
        {
          pane = 2,
          icon = " ",
          title = "Projects",
          section = "projects",
          indent = 2
        },
      },
    },
  },
  keys = {
    { "<leader>.", function() Snacks.dashboard() end, desc = "Dashboard" },
  },
}

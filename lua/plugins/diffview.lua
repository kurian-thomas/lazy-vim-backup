return {
  "sindrets/diffview.nvim",
  keys = {
    -- Toggling the interface
    { "<leader>gm", "<cmd>DiffviewOpen<cr>",  desc = "Open Git Diff/Merge" },
    { "<leader>gx", "<cmd>DiffviewClose<cr>", desc = "Close Git Diff/Merge" },

    -- Conflict Resolution Commands
    { "<leader>ml", "<cmd>diffget //2<cr>",   desc = "Merge: Choose Ours (Left)" },
    { "<leader>mr", "<cmd>diffget //3<cr>",   desc = "Merge: Choose Theirs (Right)" },

    -- Navigation (Bypassing your '[' menu)
    { "<leader>mc", "]c",                     desc = "Next Conflict" },
    { "<leader>md", "[c",                     desc = "Previous Conflict" },
  },
  opts = {
    view = {
      merge_tool = {
        -- IntelliJ-like 3-pane layout
        layout = "diff3_mixed",
        disable_diagnostics = true,
      },
    },
    file_panel = {
      win_config = {
        position = "right",
        width = 35,
      },
    },
  },
}

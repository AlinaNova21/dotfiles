return {
  {
    "NickvanDyke/opencode.nvim",
    dependencies = {
      "folke/snacks.nvim",
    },
    ---@type opencode.Config
    opts = {
      -- Default configuration -- only copy any that you wish to change
      defaults = {
        -- which-key mappings
        ["<leader>o"] = { name = "+opencode" },
      },
      auto_reload = false, -- Automatically reload buffers changed by opencode
      auto_focus = true, -- Focus the terminal after sending text
      command = "opencode", -- Command to launch opencode
      expansions = { -- Prompt placeholder expansions
        ["@file"] = function()
          return "@" .. vim.fn.expand("%:.")
        end,
      },
      win = {
        position = "right",
        -- See https://github.com/folke/snacks.nvim/blob/main/docs/win.md for more window options
      },
      -- See https://github.com/folke/snacks.nvim/blob/main/docs/terminal.md for more terminal options
    },
    -- stylua: ignore
    keys = {
      -- Example keymaps
      { '<leader>ot', function() require('opencode').toggle() end, desc = 'Toggle opencode', },
      { '<leader>oa', function() require('opencode').ask() end, desc = 'Ask opencode', mode = { 'n', 'v' }, },
      -- Example commands
      { '<leader>on', function() require('opencode').command('/new') end, desc = 'New opencode session', },
      -- Example prompts
      { '<leader>oe', function() require('opencode').send('Explain this code') end, desc = 'Explain selected code', mode = 'v', },
      { '<leader>oc', function() require('opencode').send('Critique @file for correctness and readability') end, desc = 'Critique current file', },
    },
  },
}

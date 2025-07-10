return {
  "hrsh7th/nvim-cmp",
  dependencies = {
    "zbirenbaum/copilot-cmp",
    "hrsh7th/cmp-nvim-lsp",
    "L3MON4D3/LuaSnip",
    "saadparwaiz1/cmp_luasnip",
  },
  opts = function(_, opts)
    local cmp = require("cmp")

    -- disable autocompletion
    opts.completion = {
      autocomplete = false, -- Disable automatic popup
    }

    -- Insert Copilot source first (higher priority)
    opts.sources = opts.sources or {}
    table.insert(opts.sources, 1, { name = "copilot" })

    -- Custom key mappings
    opts.mapping = {
      ["<C-n>"] = cmp.mapping.select_next_item(), -- Navigate down in popup
      ["<C-p>"] = cmp.mapping.select_prev_item(), -- Navigate up in popup
      ["<CR>"] = cmp.mapping.confirm({ select = true }), -- Confirm selected completion
      ["<Esc>"] = cmp.mapping.abort(), -- Close completion menu
    }

    return opts
  end,
}

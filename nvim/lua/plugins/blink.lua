return {
  "saghen/blink.cmp",
  opts = {
    keymap = {
      preset = "default",
      ["<A-j>"] = { "select_next", "fallback" },
      ["<A-k>"] = { "select_prev", "fallback" },
      ["<Tab>"] = { "accept", "fallback" },
    },
  },
}

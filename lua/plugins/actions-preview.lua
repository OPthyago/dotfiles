return {
  "aznhe21/actions-preview.nvim",
  event = "LspAttach",
  opts = {
    backend = { "telescope", "builtin" },
    telescope = require("telescope.themes").get_cursor(),
  },
}

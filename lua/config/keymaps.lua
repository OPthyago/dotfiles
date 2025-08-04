-- lua/config/keymaps.lua

-- [[ Initial Settings ]]
vim.g.mapleader = " "
vim.g.maplocalleader = " "
local opts = { noremap = true, silent = true }

-- Disable the default spacebar behavior
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

-- [[ Vim Behavior Improvements ]]
-- Save and Quit
vim.keymap.set("n", "<C-s>", "<cmd> w <CR>", opts)
vim.keymap.set("n", "<C-q>", "<cmd> q <CR>", opts)
vim.keymap.set("n", "<leader>sn", "<cmd>noautocmd w <CR>", { desc = "[S]ave [N]o Autocmd" })

-- Delete to the "black hole register" (doesn't affect the clipboard)
vim.keymap.set("n", "x", '"_x', opts)

-- Keep selection when indenting in visual mode
vim.keymap.set("v", "<", "<gv", opts)
vim.keymap.set("v", ">", ">gv", opts)

-- Paste in visual mode without losing the yanked text
vim.keymap.set("v", "p", '"_dP', opts)

-- [[ Essential Navigation ]]
-- Center the screen when navigating
vim.keymap.set("n", "<C-d>", "<C-d>zz", opts)
vim.keymap.set("n", "<C-u>", "<C-u>zz", opts)
vim.keymap.set("n", "n", "nzzzv", opts)
vim.keymap.set("n", "N", "Nzzzv", opts)

-- Move 10 lines up/down
vim.keymap.set({ "n", "v" }, "<C-S-j>", "10j", opts)
vim.keymap.set({ "n", "v" }, "<C-S-k>", "10k", opts)

-- [[ Window, Tab, and Buffer Management ]]
-- Buffers
-- NOTE: <Tab> and <S-Tab> shortcuts were removed to avoid conflict with nvim-cmp.
vim.keymap.set("n", "<leader>l", ":bnext<CR>", { desc = "Next Buffer" })
vim.keymap.set("n", "<leader>h", ":bprevious<CR>", { desc = "Previous Buffer" })
vim.keymap.set("n", "<leader>x", ":bdelete!<CR>", { desc = "Close Buffer" })
vim.keymap.set("n", "<leader>b", "<cmd> enew <CR>", { desc = "New Buffer" })

-- Windows (Splits)
vim.keymap.set("n", "<leader>v", "<C-w>v", { desc = "Split Vertically" })
vim.keymap.set("n", "<leader>s", "<C-w>s", { desc = "Split Horizontally" }) -- Changed from 'h' to 's' to avoid navigation conflict
vim.keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make Splits Equal" })
vim.keymap.set("n", "<leader>sx", ":close<CR>", { desc = "Close Split" }) -- Changed from 'xs' to 'sx'

-- Tabs
vim.keymap.set("n", "<leader>to", ":tabnew<CR>", { desc = "[T]ab [O]pen" })
vim.keymap.set("n", "<leader>tx", ":tabclose<CR>", { desc = "[T]ab [C]lose" })
vim.keymap.set("n", "<leader>tn", ":tabn<CR>", { desc = "[T]ab [N]ext" })
vim.keymap.set("n", "<leader>tp", ":tabp<CR>", { desc = "[T]ab [P]revious" })

-- [[ Plugin Commands ]]
-- Diagnostics (LSP)
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous Diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next Diagnostic" })
vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, { desc = "Show Diagnostic" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "List Diagnostics" })

-- Git Worktree (Telescope)
vim.keymap.set(
  "n",
  "<leader>gwl",
  "<CMD>lua require('telescope').extensions.git_worktree.git_worktrees()<CR>",
  { desc = "[G]it [W]orktree [L]ist" }
)
vim.keymap.set(
  "n",
  "<leader>gwc",
  "<CMD>lua require('telescope').extensions.git_worktree.create_git_worktree()<CR>",
  { desc = "[G]it [W]orktree [C]reate" }
)
vim.keymap.set(
  "n",
  "<leader>gwd",
  "<CMD>lua require('telescope').extensions.git_worktree.delete_git_worktree()<CR>",
  { desc = "[G]it [W]orktree [D]elete" }
)

-- LSP Symbols (Telescope)
vim.keymap.set(
  "n",
  "<leader>sls",
  require("telescope.builtin").lsp_document_symbols,
  { desc = "[S]earch [L]SP [S]ymbols" }
)
vim.keymap.set(
  "n",
  "<leader>slS",
  require("telescope.builtin").lsp_workspace_symbols,
  { desc = "[S]earch [L]SP [S]ymbols (Workspace)" }
)

-- Session (persistence.nvim)
vim.keymap.set("n", "<leader>qs", function()
  require("persistence").save()
  vim.cmd("qa!")
end, { desc = "[Q]uit and [S]ave Session" })
vim.keymap.set("n", "<leader>ql", function()
  require("persistence").load()
end, { desc = "[Q]uit and [L]oad Last Session" })
vim.keymap.set("n", "<leader>qd", function()
  require("persistence").stop()
  vim.cmd("qa!")
end, { desc = "[Q]uit and [D]on't Save Session" })

-- Formatting and Linting (conform.nvim, nvim-lint)
vim.keymap.set({ "n", "v" }, "<leader>lf", function()
  require("conform").format({ async = true, lsp_fallback = true })
end, { desc = "[L]int & [F]ormat Buffer" })
vim.keymap.set("n", "<leader>ll", function()
  require("lint").try_lint()
end, { desc = "[L]int Current Buffer" })

-- [[ Custom Functions and Modes ]]
-- Terminal
local function toggle_bottom_terminal()
  local current_tab = 0
  local terminal_win = nil
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(current_tab)) do
    if vim.api.nvim_buf_get_option(vim.api.nvim_win_get_buf(win), "buftype") == "terminal" then
      terminal_win = win
      break
    end
  end
  if terminal_win then
    vim.api.nvim_win_close(terminal_win, false)
  else
    vim.cmd("botright new | resize 10 | terminal")
  end
end
vim.keymap.set("n", "<leader>bt", toggle_bottom_terminal, { desc = "Toggle [B]ottom [T]erminal" })

-- Interactive Window Resize Mode
vim.keymap.set("n", "<leader>rs", function()
  vim.notify("🚀 Resize Mode Activated", vim.log.levels.INFO, { title = "Windows" })

  local function end_resize_mode()
    vim.notify(" Resize Mode Deactivated", vim.log.levels.INFO, { title = "Windows" })
    -- Remove temporary keymaps from the current buffer
    vim.keymap.del("n", "k", { buffer = true })
    vim.keymap.del("n", "j", { buffer = true })
    vim.keymap.del("n", "h", { buffer = true })
    vim.keymap.del("n", "l", { buffer = true })
    vim.keymap.del("n", "<Esc>", { buffer = true })
    vim.keymap.del("n", "<CR>", { buffer = true })
  end

  -- Map h,j,k,l keys to resize the window (current buffer only)
  vim.keymap.set("n", "k", ":resize -1<CR>", { silent = true, buffer = true })
  vim.keymap.set("n", "j", ":resize +1<CR>", { silent = true, buffer = true })
  vim.keymap.set("n", "h", ":vertical resize -1<CR>", { silent = true, buffer = true })
  vim.keymap.set("n", "l", ":vertical resize +1<CR>", { silent = true, buffer = true })

  -- Map Esc and Enter to call the function that ends the mode
  vim.keymap.set("n", "<Esc>", end_resize_mode, { silent = true, buffer = true })
  vim.keymap.set("n", "<CR>", end_resize_mode, { silent = true, buffer = true })
end, { desc = "[S]plit [R]esize Mode" })

-- Diffview
vim.keymap.set("n", "<leader>gd", "<cmd>DiffviewOpen<CR>", { desc = "[G]it [D]iff View" })
vim.keymap.set("n", "<leader>gh", "<cmd>DiffviewFileHistory %<CR>", { desc = "[G]it File [H]istory" })

-- Comment
vim.keymap.set("n", "<leader>/", function()
  require("mini.comment").toggle_linewise_op()
end, { desc = "Toggle Comment", expr = true, noremap = true })

vim.keymap.set("v", "<leader>/", function()
  require("mini.comment").toggle_linewise_visual()
end, { desc = "Toggle Comment (Visual)", expr = true, noremap = true })

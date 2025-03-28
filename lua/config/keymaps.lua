-- Set leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Disable the spacebar key's default behavior in Normal and Visual modes
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

-- For conciseness
local opts = { noremap = true, silent = true }

-- Save file
vim.keymap.set("n", "<C-s>", "<cmd> w <CR>", opts)

-- Save file without auto-formatting
vim.keymap.set("n", "<leader>sn", "<cmd>noautocmd w <CR>", opts)

-- Quit file
vim.keymap.set("n", "<C-q>", "<cmd> q <CR>", opts)

-- Delete single character without copying into register
vim.keymap.set("n", "x", '"_x', opts)

-- Vertical scroll and center
vim.keymap.set("n", "<C-d>", "<C-d>zz", opts)
vim.keymap.set("n", "<C-u>", "<C-u>zz", opts)

-- Find and center
vim.keymap.set("n", "n", "nzzzv", opts)
vim.keymap.set("n", "N", "Nzzzv", opts)

-- Resize with arrows
vim.keymap.set("n", "<Up>", ":resize -2<CR>", opts)
vim.keymap.set("n", "<Down>", ":resize +2<CR>", opts)
vim.keymap.set("n", "<Left>", ":vertical resize -2<CR>", opts)
vim.keymap.set("n", "<Right>", ":vertical resize +2<CR>", opts)

-- Buffers
vim.keymap.set("n", "<Tab>", ":bnext<CR>", opts)
vim.keymap.set("n", "<S-Tab>", ":bprevious<CR>", opts)
vim.keymap.set("n", "<leader>x", ":bdelete!<CR>", opts) -- Close buffer
vim.keymap.set("n", "<leader>b", "<cmd> enew <CR>", opts) -- New buffer

-- Window management
vim.keymap.set("n", "<leader>v", "<C-w>v", opts) -- Split window vertically
vim.keymap.set("n", "<leader>h", "<C-w>s", opts) -- Split window horizontally
vim.keymap.set("n", "<leader>se", "<C-w>=", opts) -- Make split windows equal width & height
vim.keymap.set("n", "<leader>xs", ":close<CR>", opts) -- Close current split window

-- Navigate between splits (Tmux navigation)
vim.keymap.set("n", "<C-k>", ":TmuxNavigateUp<CR>", opts)
vim.keymap.set("n", "<C-j>", ":TmuxNavigateDown<CR>", opts)
vim.keymap.set("n", "<C-h>", ":TmuxNavigateLeft<CR>", opts)
vim.keymap.set("n", "<C-l>", ":TmuxNavigateRight<CR>", opts)

-- Tabs
vim.keymap.set("n", "<leader>to", ":tabnew<CR>", opts) -- Open new tab
vim.keymap.set("n", "<leader>tx", ":tabclose<CR>", opts) -- Close current tab
vim.keymap.set("n", "<leader>tn", ":tabn<CR>", opts) -- Go to next tab
vim.keymap.set("n", "<leader>tp", ":tabp<CR>", opts) -- Go to previous tab

-- Toggle line wrapping
vim.keymap.set("n", "<leader>lw", "<cmd>set wrap!<CR>", opts)

-- Stay in indent mode
vim.keymap.set("v", "<", "<gv", opts)
vim.keymap.set("v", ">", ">gv", opts)

-- Keep last yanked when pasting
vim.keymap.set("v", "p", '"_dP', opts)

-- Diagnostic keymaps
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic message" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic message" })
vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, { desc = "Open floating diagnostic message" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostics list" })

-- Terminal keymaps
local function toggle_bottom_terminal()
  local current_tab = 0 -- current tabpage
  local terminal_win = nil

  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(current_tab)) do
    local buf = vim.api.nvim_win_get_buf(win)
    local buftype = vim.api.nvim_buf_get_option(buf, "buftype")
    if buftype == "terminal" then
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

vim.keymap.set("n", "<leader>bt", toggle_bottom_terminal, { desc = "Toggle bottom terminal" })

-- Git Worktree (using Telescope)
vim.keymap.set(
  "n",
  "<leader>gwl",
  "<CMD>lua require('telescope').extensions.git_worktree.git_worktrees()<CR>",
  { desc = "List git worktrees" }
)
vim.keymap.set(
  "n",
  "<leader>gwc",
  "<CMD>lua require('telescope').extensions.git_worktree.create_git_worktree()<CR>",
  { desc = "Create git worktree" }
)
vim.keymap.set(
  "n",
  "<leader>gwd",
  "<CMD>lua require('telescope').extensions.git_worktree.delete_git_worktree()<CR>",
  { desc = "Delete git worktree" }
)

-- Move 10 lines up and down
vim.keymap.set({ "n", "v" }, "<C-S-j>", "10j", { noremap = true, silent = true })
vim.keymap.set({ "n", "v" }, "<C-S-k>", "10k", { noremap = true, silent = true })

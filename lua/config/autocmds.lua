-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Cria um grupo de autocomandos para manter a organização
local lsp_on_save_group = vim.api.nvim_create_augroup("LspOnSaveActions", { clear = true })

-- Autocomando para organizar imports ao salvar arquivos JS/TS
vim.api.nvim_create_autocmd("BufWritePre", {
  group = lsp_on_save_group,
  pattern = { "*.ts", "*.tsx", "*.js", "*.jsx" },
  callback = function(args)
    local params = {
      command = "_typescript.organizeImports",
      arguments = { args.file },
      title = "",
    }
    -- O timeout de 1000ms (1s) é um tempo de espera razoável.
    -- O 'nil' no final é para a função de callback, que não precisamos aqui.
    vim.lsp.buf.execute_command(params, args.buf, 1000, nil)
    vim.notify("Imports organizados!", vim.log.levels.INFO, { title = "LSP" })
  end,
  desc = "Organiza os imports ao salvar (JS/TS)",
})

vim.keymap.set('n', '<leader>gs', vim.cmd.Git)

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "gitcommit" },
  callback = function()
    vim.cmd("setlocal spell")
    vim.cmd("setlocal colorcolumn=72")
	vim.cmd([[match Title /\%1l.\{,50}/]])  -- First 50 chars in 'Title' highlight
    vim.cmd([[2match ErrorMsg /\%1l.\%>50c.*/]])  -- Beyond 50 chars in 'ErrorMsg'
  end,
})

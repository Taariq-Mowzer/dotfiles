vim.cmd.colorscheme 'tokyonight-night'

vim.api.nvim_set_hl(0, "Normal", {guibg=NONE})
vim.api.nvim_set_hl(0, "NormalNC", {guibg=NONE})

vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.signcolumn = 'yes'

vim.api.nvim_set_hl(0, 'SignColumn', { bg = 'NONE' })

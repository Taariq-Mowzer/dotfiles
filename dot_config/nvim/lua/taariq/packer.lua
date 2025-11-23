-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  use {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {},
  }

  use ('nvim-treesitter/nvim-treesitter', {run = ':TSUpdate'})

  use ('tpope/vim-fugitive')

  use({'neovim/nvim-lspconfig'})
  use({'hrsh7th/nvim-cmp'})
  use({'hrsh7th/cmp-nvim-lsp'})
  use {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
  }
  use {
    'nvim-telescope/telescope.nvim', tag = '0.1.8',
     requires = { {'nvim-lua/plenary.nvim'} }
  }

  use {"windwp/nvim-autopairs"}

  use({
	"L3MON4D3/LuaSnip",
	-- follow latest release.
	tag = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
	-- install jsregexp (optional!:).
	run = "make install_jsregexp"
})

	use ({'lervag/vimtex', tag = 'v2.15'})
	use ({"micangl/cmp-vimtex", requires = {{'lervag/vimtex'}}})

	use 'mfussenegger/nvim-dap'

	use 'kshenoy/vim-signature'

end)


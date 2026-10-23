-- Install LSPs
require("mason").setup()
require("mason-lspconfig").setup({
	ensure_installed = {'lua_ls', 'basedpyright'},
	automatic_enable = false,
	root_dir = function(filename, bufnr)
    	return vim.fn.getcwd() -- Always returns Neovim's current working directory
  end
})

-- LSP maps
vim.api.nvim_set_keymap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", { noremap = true, silent = true })
-- Setup LSPs
vim.lsp.config('luals', {
  cmd = {'lua-language-server'},
  filetypes = {'lua'},
  root_markers = {'.luarc.json', '.luarc.jsonc'},
})

vim.lsp.enable('luals')
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "*.tac",
  command = "set filetype=python",
})
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "*.py.jinja",
  command = "set filetype=python",
})
vim.lsp.config('bpyright', {
	cmd = {'basedpyright-langserver', '--stdio'},
	filetypes = {'python'},
	root_markers = {'.git'},
	settings = {
		basedpyright = {
			analysis = {
				typeCheckingMode = "recommended",
				autoImportCompletions= false,
				--reportUnknownMemberType = "none",
			},
		}
	}
})

vim.lsp.enable('bpyright')

vim.lsp.config('clang', {
	cmd = {'clangd'},
	filetypes= {'c', 'cpp'},
})
vim.lsp.enable('clang')

-- zig
vim.lsp.config('zig', {
	cmd = {'zls'},
	filetypes = {'zig'},
	root_markers = {'.git'},
	settings = {
		--enable_build_on_save = true,

	}
})

vim.lsp.enable('zig')

-- bash
vim.lsp.config('bashls', {
  cmd = { 'bash-language-server', 'start' },
  filetypes = { 'sh', 'bash', 'zsh' },
  root_markers = { '.git' }, -- optional but recommended
})

vim.lsp.enable('bashls')

-- terraform
vim.lsp.config('terraformls', {
  cmd = { 'terraform-ls', 'serve' },

  filetypes = {
    'terraform',
    'terraform-vars',
    'hcl',
  },

  root_markers = {
    '.terraform',
    '.git',
  },
})
vim.lsp.enable('terraformls')

-- Diagnostic should have rounded borders
vim.o.winborder = 'rounded'

-- Remove signs on line bar. Instead just highlight the linenumber
vim.diagnostic.config({
	severity_sort=true,
	signs = {
		text = {
		[vim.diagnostic.severity.ERROR] = '',
		[vim.diagnostic.severity.WARN] = '',
		[vim.diagnostic.severity.HINT] = '',
		[vim.diagnostic.severity.INFO] = '',
		},
	linehl = {
	    --[vim.diagnostic.severity.ERROR] = 'ErrorMsg',
	},
	numhl = {
	    [vim.diagnostic.severity.ERROR] = 'DiagnosticSignError',
	    [vim.diagnostic.severity.WARN] = 'DiagnosticSignWarn',
	    [vim.diagnostic.severity.HINT] = 'DiagnosticSignHint',
	    [vim.diagnostic.severity.INFO] = 'DiagnosticSignInfo',
	},
    },
})

-- Keep hint coloring in the number column without underlining buffer text.
vim.api.nvim_set_hl(0, 'DiagnosticUnderlineHint', { undercurl = false, underline = false })

-- Autocomplete maps
vim.api.nvim_set_keymap(
  'n', '<leader>w', ':lua vim.diagnostic.open_float()<CR>',
  { noremap = true, silent = true}
)


local cmp = require('cmp')
local luasnip = require('luasnip')

cmp.setup({
  sources = {
    -- Add other sources if needed
    { name = 'nvim_lsp', keyword_length = 2},
    { name = 'vimtex', keyword_length = 2},
  },
  snippet = {
    expand = function(args)
     luasnip.lsp_expand(args.body)
    end,
  },
  window = {
	  completion = cmp.config.window.bordered(),
	  documentation= cmp.config.window.bordered(),
  },
  mapping = cmp.mapping.preset.insert({
	 ['<CR>'] = cmp.mapping(function(fallback)
        if luasnip.expandable() then
        	luasnip.expand()
			return
		elseif cmp.visible() then
            cmp.confirm({
                select = false,
            })
        end
        fallback()
    end),

    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.locally_jumpable(1) then
        luasnip.jump(1)
      else
        fallback()
      end
    end, { "i", "s" }),

    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.locally_jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }), 
   ["<C-e>"] = cmp.mapping.abort(),         -- Close completion menu
  }),
})

-- If you want `(` after select function or method item
local auto_pairs = require('nvim-autopairs')
auto_pairs.setup({
	disable_filetype = {"tex"}
})
local Rule = require('nvim-autopairs.rule')

local cmp_autopairs = require('nvim-autopairs.completion.cmp')
cmp.event:on(
'confirm_done',
	cmp_autopairs.on_confirm_done()
)

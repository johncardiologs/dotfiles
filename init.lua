vim.cmd([[
	filetype plugin indent on 
	set number

	call plug#begin()

	Plug 'navarasu/onedark.nvim'
	Plug 'feline-nvim/feline.nvim'
	Plug 'neoclide/coc.nvim', {'branch': 'release'}
	Plug 'nvim-lua/plenary.nvim'
	Plug 'ibhagwan/fzf-lua', {'branch': 'main'}
	Plug 'nvim-tree/nvim-web-devicons'
	Plug 'dyng/ctrlsf.vim'
	Plug 'tpope/vim-commentary'
	Plug 'nvim-lua/plenary.nvim'
	Plug 'ruifm/gitlinker.nvim'
	Plug 'christoomey/vim-system-copy'
	Plug 'lewis6991/gitsigns.nvim'
	Plug 'petertriho/nvim-scrollbar'
	Plug 'vim-test/vim-test'

	call plug#end()
]])

-- Some servers have issues with backup files, see #649
vim.opt.backup = false
vim.opt.writebackup = false

-- Having longer updatetime (default is 4000 ms = 4s) leads to noticeable
-- delays and poor user experience
vim.opt.updatetime = 300

-- Always show the signcolumn, otherwise it would shift the text each time
-- diagnostics appeared/became resolved
vim.opt.signcolumn = "yes"


local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

vim.api.nvim_set_keymap('n', '<c-P>',
    "<cmd>lua require('fzf-lua').files({ cmd='git ls-files' })<CR>",
    { noremap = true, silent = true })

vim.api.nvim_set_keymap('n', '<c-G>',
    "<cmd>lua require'fzf-lua'.live_grep({ cmd = 'git grep --line-number --column --color=always' })<CR>",
    { noremap = true, silent = true })


-- git linker
require"gitlinker".setup()
require('gitsigns').setup{
	current_line_blame = true,
	current_line_blame_opts = {
		virt_text_pos = 'right_align'
	},
	on_attach = function(bufnr)
    local gs = package.loaded.gitsigns

    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    -- Navigation
    map('n', ']c', function()
      if vim.wo.diff then return ']c' end
      vim.schedule(function() gs.next_hunk() end)
      return '<Ignore>'
    end, {expr=true})

    map('n', '[c', function()
      if vim.wo.diff then return '[c' end
      vim.schedule(function() gs.prev_hunk() end)
      return '<Ignore>'
    end, {expr=true})

    -- Actions
    map({'n', 'v'}, '<leader>hs', ':Gitsigns stage_hunk<CR>')
    map({'n', 'v'}, '<leader>hr', ':Gitsigns reset_hunk<CR>')
    map('n', '<leader>hS', gs.stage_buffer)
    map('n', '<leader>hu', gs.undo_stage_hunk)
    map('n', '<leader>hR', gs.reset_buffer)
    map('n', '<leader>hp', gs.preview_hunk)
    map('n', '<leader>hb', function() gs.blame_line{full=true} end)
    map('n', '<leader>tb', gs.toggle_current_line_blame)
    map('n', '<leader>hd', gs.diffthis)
    map('n', '<leader>hD', function() gs.diffthis('~') end)
    map('n', '<leader>td', gs.toggle_deleted)

    -- Text object
    map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
  end
}


-- Use Tab for trigger completion with characters ahead and navigate
-- NOTE: There's always a completion item selected by default, you may want to enable
-- no select by setting `"suggest.noselect": true` in your configuration file
-- NOTE: Use command ':verbose imap <tab>' to make sure Tab is not mapped by
-- other plugins before putting this into your config
vim.opt.background = "dark"

require('onedark').setup {
    style = 'deep'
}
require('onedark').load()
require('feline').setup()

-- Move to previous/next
require("scrollbar").setup()


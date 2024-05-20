vim.cmd([[
	filetype plugin indent on 
	set number

	call plug#begin()

	Plug 'navarasu/onedark.nvim'
	Plug 'feline-nvim/feline.nvim'
	Plug 'neoclide/coc.nvim', {'branch': 'release'}
	Plug 'nvim-lua/plenary.nvim'
	Plug 'ibhagwan/fzf-lua', {'branch': 'main'}
	Plug 'nvim-tree/nvim-tree.lua'
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

-- Nvim tree -------------

-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- optionally enable 24-bit colour
vim.opt.termguicolors = true

-- custom keybinds

vim.api.nvim_set_keymap("n", "<C-h>", ":NvimTreeToggle<cr>", {silent = true, noremap = true})

local function my_on_attach(bufnr)
	local api = require "nvim-tree.api"

	local function opts(desc)
	return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
	end


	local function edit_or_open()
	  local node = api.tree.get_node_under_cursor()

	  if node.nodes ~= nil then
	    -- expand or collapse folder
	    api.node.open.edit()
	  else
	    -- open file
	    api.node.open.edit()
	    -- Close the tree if file was opened
	    api.tree.close()
	  end
	end

	-- open as vsplit on current node
	local function vsplit_preview()
	  local node = api.tree.get_node_under_cursor()

	  if node.nodes ~= nil then
	    -- expand or collapse folder
	    api.node.open.edit()
	  else
	    -- open file as vsplit
	    api.node.open.vertical()
	  end

	  -- Finally refocus on tree if it was lost
	  api.tree.focus()
	end

	-- default mappings
	api.config.mappings.default_on_attach(bufnr)

	-- on_attach
	vim.keymap.set("n", "l", edit_or_open,          opts("Edit Or Open"))
	vim.keymap.set("n", "L", vsplit_preview,        opts("Vsplit Preview"))
	vim.keymap.set("n", "h", api.tree.close,        opts("Close"))
	vim.keymap.set("n", "H", api.tree.collapse_all, opts("Collapse All"))
end

-- setup with some options
require("nvim-tree").setup({
	on_attach = my_on_attach
})
--------------------

-- Some servers have issues with backup files, see #649
vim.opt.backup = false
vim.opt.writebackup = false

-- Having longer updatetime (default is 4000 ms = 4s) leads to noticeable
-- delays and poor user experience
vim.opt.updatetime = 300

-- Always show the signcolumn, otherwise it would shift the text each time
-- diagnostics appeared/became resolved
vim.opt.signcolumn = "yes"

-- Coc commands
local keyset = vim.keymap.set

-- Autocomplete
function _G.check_back_space()
	local col = vim.fn.col('.') - 1
	return col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') ~= nil
end


local opts = {silent = true, noremap = true, expr = true, replace_keycodes = false}
keyset("i", "<TAB>", 'coc#pum#visible() ? coc#pum#next(1) : v:lua.check_back_space() ? "<TAB>" : coc#refresh()', opts)
keyset("i", "<S-TAB>", [[coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"]], opts)
keyset("i", "<c-space>", "coc#refresh()", {silent = true, expr = true})

-- Make <CR> to accept selected completion item or notify coc.nvim to format
-- <C-g>u breaks current undo, please make your own choice
keyset("i", "<cr>", [[coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"]], opts)

-- Use <c-j> to trigger snippets
keyset("i", "<c-j>", "<Plug>(coc-snippets-expand-jump)")
-- Use <c-space> to trigger completion
keyset("i", "<c-space>", "coc#refresh()", {silent = true, expr = true})

-- Use `[g` and `]g` to navigate diagnostics
-- Use `:CocDiagnostics` to get all diagnostics of current buffer in location list
keyset("n", "[g", "<Plug>(coc-diagnostic-prev)", {silent = true})
keyset("n", "]g", "<Plug>(coc-diagnostic-next)", {silent = true})

-- GoTo code navigation
keyset("n", "gd", "<Plug>(coc-definition)", {silent = true})
keyset("n", "gy", "<Plug>(coc-type-definition)", {silent = true})
keyset("n", "gi", "<Plug>(coc-implementation)", {silent = true})
keyset("n", "gr", "<Plug>(coc-references)", {silent = true})

-- Custom keybinds
keyset('n', '<Esc>', ':noh<CR>')

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
      keyset(mode, l, r, opts)
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


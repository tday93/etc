--- Packer Bootstrapping
local fn = vim.fn
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  packer_bootstrap = fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
end

return require('packer').startup(function()
	use 'wbthomason/packer.nvim'

	--- common
  use 'sheerun/vimrc' -- Basic settings
  use 'sheerun/vim-polyglot' -- Basic Language packs
  use 'sjl/vitality.vim' -- tmux compatibility
  use 'christoomey/vim-tmux-navigator' -- tmux movement
  use 'tpope/vim-repeat' -- fixes repeating plugin maps
  use 'tpope/vim-sleuth' -- buffer options based on current file

  -- Extensions
  use 'wellle/targets.vim' -- extra text objects
  use 'tpope/vim-unimpaired' -- handy bracket mappings
  use 'andymass/vim-matchup' -- matching parens and more
  use 'tpope/vim-surround' -- adds additional surroundings

  --- Utility
	use 'tpope/vim-fugitive' -- Git commands
  use 'bronson/vim-trailing-whitespace' -- highlight trailing spaces
  use 'tomtom/tcomment_vim' -- easy commenting with gc
  use 'airblade/vim-rooter' -- Auto find root project directory
  vim.g.rooter_disable_map = 1
  vim.g.rooter_silent_chdir = 1

  --- Appearance
  use 'chriskempson/base16-vim'
  vim.cmd('colorscheme base16-material')
  use 'vim-airline/vim-airline' -- powerline
  use 'vim-airline/vim-airline-themes'
  vim.g.airline_theme = 'base16'
  vim.g.airline_left_sep = ''
  vim.g.airline_right_sep = ''
  vim.g.airline_section_z = ''

  --- Nerdtree
  use 'preservim/nerdtree'

  --- Treesitter
  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate'
  }

  --- LSP and Completion
  use {
    'williamboman/nvim-lsp-installer',
    'neovim/nvim-lspconfig',
  }

  local on_attach = function(client, bufnr)

  end

  local lsp_flags = {
    debounce_text_changes = 150,
  }


  require("nvim-lsp-installer").setup {}
  require('lspconfig')['sumneko_lua'].setup {
    on_attach = on_attach,
    flags = lsp_flags,
    settings = {
      Lua = {
	diagnostics = {
	  globals = {'vim'},
	},
      },
    },
  }

  require('lspconfig')['terraformls'].setup {
    on_attach = on_attach,
    flags = lsp_flags,
  }

  --- Autocompletion
  -- use {'ms-jpq/coq_nvim', branch = 'coq'}
  -- vim.g.coq_settings = {
  --   keymap = {
  --     recommended = false,
  --     jump_to_mark = '',
  --     pre_select = true,
  --   },
  --   auto_start = "shut-up"
  -- }
  -- use {'ms-jpq/coq.artifacts', branch = 'artifacts'}
  --

  --- Worldbuilding/Writing
  use {
    'nvim-telescope/telescope.nvim',
    requires = { {'nvim-lua/plenary.nvim'} }
  }

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if packer_bootstrap then
    require('packer').sync()
  end

end)

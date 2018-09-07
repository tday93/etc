set t_Co=256
" restore cursor to last position
if has("autocmd")
  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
endif

let mapleader = "\<Space>"
let maplocalleader = ","

let g:python_host_prog = '/usr/local/bin/python'
let g:python3_host_prog = '/usr/local/bin/python3'


let g:python_host_skip_check=1
let g:loaded_python2_provider=1
let g:targets_aiAI = 'aIAi'

" dont redraw screen while runnning macros
set lazyredraw


let g:flow#enable = 0

call plug#begin()

Plug 'vim-syntastic/syntastic'
let g:syntastic_text_checkers = ['proselint']
let g:syntastic_html_checkers = ['tidy']
let g:syntastic_javascript_checkers = ['jshint']
let g:syntastic_python_checkers = ['flake8']
let g:syntastic_quiet_messages = {'regex': 'E501' }
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

Plug 'sheerun/vimrc'
" extra text objects
Plug 'wellle/targets.vim'
" language packs
Plug 'sheerun/vim-polyglot'
" make vim play nice with tmux
Plug 'sjl/vitality.vim'
" fuzzy find
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': 'yes \| ./install' }
" auto generates ctags????
Plug 'grassdog/tagman.vim'
" Really nice prompt
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
let g:airline_theme='wombat'
let g:airline_left_sep=''
let g:airline_right_sep=''
let g:airline_section_z=''
Plug 'flazz/vim-colorschemes'
Plug 'justinmk/vim-dirvish'

" Press v over and over again to expand selection
Plug 'terryma/vim-expand-region'
vmap v <Plug>(expand_region_expand)
vmap <C-v> <Plug>(expand_region_shrink)

" Awesome autocompletion
" Plug 'Valloric/YouCompleteMe', { 'do': './install.sh --gocode-completer --tern-completer' }

" adds more surroundings
Plug 'tpope/vim-surround'
" comment things easily with 'gc'
Plug 'tomtom/tcomment_vim'
" readline key bindings??
Plug 'tpope/vim-rsi'
" auto structure ending
Plug 'tpope/vim-endwise'
" git wrapper
Plug 'tpope/vim-fugitive'
" fixes repeating plugin maps
Plug 'tpope/vim-repeat'
" sets buffer options based on current file
Plug 'tpope/vim-sleuth'
" handy bracket mappings
Plug 'tpope/vim-unimpaired'

" Allow to :Rename files
Plug 'danro/rename.vim'

" flow = static type checker for js
Plug 'flowtype/vim-flow'

" python completion
Plug 'davidhalter/jedi-vim'
let g:jedi#completions_enabled = 0

Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'zchee/deoplete-jedi'
Plug 'fszymanski/deoplete-emoji'
let g:deoplete#enable_at_startup = 1


" Automatically find root project directory
Plug 'airblade/vim-rooter'
let g:rooter_disable_map = 1
let g:rooter_silent_chdir = 1

" Expand / wrap hashes etc.
Plug 'AndrewRadev/splitjoin.vim'
nmap sj :SplitjoinSplit<cr>
nmap sk :SplitjoinJoin<cr>

Plug 'moll/vim-node', { 'for': 'javascript' }

" Navitate freely between tmux and vim
Plug 'christoomey/vim-tmux-navigator'

" Nice column aligning with <Enter>
Plug 'junegunn/vim-easy-align'
vmap <Enter> <Plug>(EasyAlign)
nmap <Leader>a <Plug>(EasyAlign)

" colored 89st column
highlight ColorColumn ctermbg=magenta
call matchadd('ColorColumn', '\%89v',100)
" ii / ai
Plug 'michaeljsmith/vim-indent-object'

" For more reliable indenting and performance
set foldmethod=indent
set fillchars="fold: "

" Nice file browsing with -
Plug 'eiginn/netrw'
let g:netrw_altfile = 1
Plug 'tpope/vim-vinegar'

" Set nice 80-characters limiter
" execute "set colorcolumn=" . join(range(81,335), ',')
" hi ColorColumn guibg=#262626 ctermbg=235

" Better search tools
Plug 'vim-scripts/IndexedSearch'
Plug 'vim-scripts/SmartCase'
" Plug 'vim-scripts/gitignore'

Plug 'junegunn/goyo.vim'

Plug 'chriskempson/base16-vim'

call plug#end()

set termguicolors

colorscheme base16-material

set relativenumber

autocmd VimEnter,BufNewFile,BufReadPost * silent! call HardMode()
nnoremap <leader>h <Esc>:call ToggleHardMode()<CR>

vmap <Leader>y "+y
vmap <Leader>d "+d
nmap <Leader>p "+p
nmap <Leader>P "+P
vmap <Leader>p "+p
vmap <Leader>P "+P
nmap <Leader><Leader> V
nmap <Leader>b :make<CR>
nnoremap <Leader><Tab> <C-^>
nnoremap <Leader>y :!annotate expand('%:p') " what?

nnoremap <Leader>o :FZF<CR>

vnoremap <silent> y y`]
vnoremap <silent> p p`]
nnoremap <silent> p p`]

nnoremap <CR> G
nnoremap <BS> gg
nnoremap <Leader>w :w<CR>
nnoremap <Leader>s :wq<CR>
nnoremap <Leader>v V
nnoremap <Leader>g gf

" Remove trailing whitespaces
nnoremap <silent> <Leader><Space> :let _s=@/<Bar>:%s/\s\+$//e<Bar>:let @/=_s<Bar>:nohl<CR>:w<CR>

nnoremap H 0
nnoremap L $

inoremap jk <Esc>

set timeout timeoutlen=500 ttimeoutlen=0

command! -bar Tags if !empty(tagfiles()) | call fzf#run({
\   'source': "sed '/^\\!/d;s/\t.*//' " . join(tagfiles()) . ' | uniq',
\   'sink':   'tag',
\ })

set t_Co=256
let mapleader = "\<Space>"
let maplocalleader = ","

let g:python_host_prog = '/bin/python'
let g:python3_host_prog = '/bin/python3'


let g:python_host_skip_check=1
let g:loaded_python2_provider=1
let g:targets_aiAI = 'aIAi'


let g:flow#enable = 0

call plug#begin()

Plug 'vim-syntastic/syntastic'
let g:syntastic_text_checkers = ['proselint']
let g:syntastic_html_checkers = ['tidy']
let g:syntastic_javascript_checkers = ['jshint']
let g:syntastic_python_checkers = ['python', 'flake8']
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

Plug 'sheerun/vimrc'
Plug 'wellle/targets.vim'
Plug 'sheerun/vim-polyglot'
Plug 'sjl/vitality.vim'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': 'yes \| ./install' }
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

" Lightning fast :Ag searcher
Plug 'rking/ag.vim'
Plug 'tpope/vim-surround'
Plug 'tomtom/tcomment_vim'
Plug 'tpope/vim-rsi'
Plug 'tpope/vim-endwise'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-sleuth'
Plug 'tpope/vim-unimpaired'

" Allow to :Rename files
Plug 'danro/rename.vim'

Plug 'flowtype/vim-flow'

" Automatically find root project directory
Plug 'airblade/vim-rooter'
let g:rooter_disable_map = 1
let g:rooter_silent_chdir = 1

" Expand / wrap hashes etc.
Plug 'AndrewRadev/splitjoin.vim'
nmap sj :SplitjoinSplit<cr>
nmap sk :SplitjoinJoin<cr>

Plug 'fatih/vim-go', { 'for': 'go' }
let g:go_fmt_command = "goimports"
Plug 'nsf/gocode', { 'rtp': 'vim', 'do': '~/.vim/plugged/gocode/vim/symlink.sh', 'for': 'go' }

Plug 'moll/vim-node', { 'for': 'javascript' }

" Navitate freely between tmux and vim
Plug 'christoomey/vim-tmux-navigator'

" Nice column aligning with <Enter>
Plug 'junegunn/vim-easy-align'
vmap <Enter> <Plug>(EasyAlign)
nmap <Leader>a <Plug>(EasyAlign)

" colored 81st column
highlight ColorColumn ctermbg=magenta
call matchadd('ColorColumn', '\%81v',100)
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

call plug#end()

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

silent! colorscheme wombat256i

command! -bar Tags if !empty(tagfiles()) | call fzf#run({
\   'source': "sed '/^\\!/d;s/\t.*//' " . join(tagfiles()) . ' | uniq',
\   'sink':   'tag',
\ })

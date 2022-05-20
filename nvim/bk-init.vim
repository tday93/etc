set t_Co=256
" restore cursor to last position
if has("autocmd")
  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
endif

let mapleader = "\<Space>"
let maplocalleader = ","

let g:python_host_prog = '/usr/bin/python'
let g:python3_host_prog = '/usr/bin/python3'


let g:python_host_skip_check=1
let g:loaded_python2_provider=1
let g:targets_aiAI = 'aIAi'

" dont redraw screen while runnning macros
set shiftwidth=2

call plug#begin()

" Session management
Plug 'tpope/vim-obsession'

" Terraform
Plug 'hashivim/vim-terraform'
Plug 'juliosueiras/vim-terraform-completion'

" basic vimrc
Plug 'sheerun/vimrc'
" language packs
Plug 'sheerun/vim-polyglot'

" extra text objects
Plug 'wellle/targets.vim'

" make vim play nice with tmux
Plug 'sjl/vitality.vim'

" fuzzy find
" Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': 'yes \| ./install' }

" Really nice prompt
" Plug 'vim-airline/vim-airline'
" Plug 'vim-airline/vim-airline-themes'
" let g:airline_theme='wombat'
" let g:airline_left_sep=''
" let g:airline_right_sep=''
" let g:airline_section_z=''

Plug 'justinmk/vim-dirvish'

" adds more surroundings
Plug 'tpope/vim-surround'

" comment things easily with 'gc'
Plug 'tomtom/tcomment_vim'

" git wrapper
Plug 'tpope/vim-fugitive'

" fixes repeating plugin maps
Plug 'tpope/vim-repeat'

" sets buffer options based on current file
Plug 'tpope/vim-sleuth'

" handy bracket mappings
Plug 'tpope/vim-unimpaired'

" Automatically find root project directory
Plug 'airblade/vim-rooter'
let g:rooter_disable_map = 1
let g:rooter_silent_chdir = 1

" Navitate freely between tmux and vim
Plug 'christoomey/vim-tmux-navigator'



" Better search tools
Plug 'vim-scripts/IndexedSearch'
Plug 'vim-scripts/SmartCase'

Plug 'chriskempson/base16-vim'


call plug#end()


" fix ansible yaml detection
au BufRead,BufNewFile */tasks/*.yml set filetype=yaml.ansible

set background=dark
let base16colorspace=256
colorscheme base16-material

set termguicolors

set relativenumber

" For more reliable indenting and performance
set foldmethod=indent
set fillchars="fold: "

" tabe completion for file names
set wildmode=longest,list,full
set wildmenu

vmap <Leader>y "+y
vmap <Leader>d "+d
nmap <Leader>p "+p
nmap <Leader>P "+P
vmap <Leader>p "+p
vmap <Leader>P "+P
nmap <Leader><Leader> V
nmap <Leader>b :make<CR>
nnoremap <Leader><Tab> 0w>>
nnoremap <Leader><S-Tab> 0w<<
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

" command! -bar Tags if !empty(tagfiles()) | call fzf#run({
" \   'source': "sed '/^\\!/d;s/\t.*//' " . join(tagfiles()) . ' | uniq',
" \   'sink':   'tag',
" \ })


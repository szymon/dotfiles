
filetype plugin on
syntax on

" Set commands {{{1
set nocompatible
set path+=**
set wildmenu
set expandtab
set softtabstop=4
set tabstop=4
set shiftwidth=4
set number
set autoindent
set autoindent
set smartindent
set scrolloff=5
set nohlsearch
set ruler
set mouse=a
set hidden

set exrc
set secure

set foldmethod=manual
set langmenu=en_US.UTF-8

" Make backspace usefull
set backspace=indent,eol,start


" Other options {{{1
if has('nvim')
    set clipboard=unnamedplus
else
    set clipboard=unnamed
endif

let mapleader=" "
language message en_US.UTF-8

" Colorscheme {{{1
set t_Co=256
colorscheme default

" (Re)maps {{{1

nnoremap <leader>, :w<cr>
nnoremap <leader><space> :noh<cr>
nnoremap <leader>cc gg"+yG<c-o>

noremap <silent> <expr> j (v:count == 0 ? 'gj' : 'j')
noremap <silent> <expr> k (v:count == 0 ? 'gk' : 'k')

vnoremap J :m '>+1<cr>gv=gv
vnoremap K :m '<-2<cr>gv=gv

nnoremap <Up> :resize -2<cr>
nnoremap <Down> :resize +2<cr>
nnoremap <Left> :vertical resize -2<cr>
nnoremap <Right> :vertical resize +2<cr>

xnoremap <leader>p "_dP

nnoremap Q <nop>

nnoremap <silent><C-h> :tabprev<cr>
nnoremap <silent><C-l> :tabnext<cr>


" emacs movement in cmd mode
cnoremap <C-A>		<Home>
cnoremap <C-B>		<Left>
cnoremap <C-D>		<Del>
cnoremap <C-E>		<End>
cnoremap <C-F>		<Right>
cnoremap <C-N>		<Down>
cnoremap <C-P>		<Up>
cnoremap <Esc><C-B>	<S-Left>
cnoremap <Esc><C-F>	<S-Right>

" Backup {{{1

if has('presistent_undo')
    set undofile
    set undolevels=3000
    set undoreload=10000
endif
set backupdir=~/.local/share/nvim/backup
set backup
set noswapfile

" Autocmd {{{1
autocmd FileType yaml setlocal ts=12 sts=2 sw=2 expandtab indentkeys-=<:>
autocmd FileType python setlocal ts=8 sts=4 sw=4 expandtab


" Hilight {{{1
highligh Visual gui=None term=reverse ctermfg=none ctermbg=232
highligh Folded gui=None term=reverse ctermfg=none ctermbg=232


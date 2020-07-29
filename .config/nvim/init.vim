
set nocompatible

set path+=**
set wildmenu

set termguicolors

" Yank and paste with the system clipboard
set clipboard=unnamed

filetype plugin on

" Tweaks for browsing
let g:netrw_banner=0
let g:netrw_browse_split=4
let g:netrw_altv=1
let g:netrw_liststyle=3
let g:netrw_list_hide=netrw_gitignore#Hide()
let g:netrw_list_hide.=',\(^\|\s\s\)\zs\.\S\+'

set langmenu=en_US.UTF-8
language message en_US.UTF-8

syntax on
set tabstop=4
set shiftwidth=4
set expandtab
set ai
set number
set relativenumber
set hlsearch
set ruler

" Colorscheme
set t_Co=256
colorscheme default
highlight Comment ctermfg=green

command! JsonFormat %!python -m json.tool

" Make backspace usefull
set backspace=indent,eol,start

noremap <silent> <expr> j (v:count == 0 ? 'gj' : 'j')
noremap <silent> <expr> k (v:count == 0 ? 'gk' : 'k')

nnoremap <Up> :resize -2<cr>
nnoremap <Down> :resize +2<cr>
nnoremap <Left> :vertical resize -2<cr>
nnoremap <Right> :vertical resize +2<cr>

nnoremap Q <nop>

nnoremap <C-h> <c-w>h
nnoremap <C-j> <c-w>j
nnoremap <C-k> <c-w>k
nnoremap <C-l> <c-w>l

xnoremap K :move '<-2<cr>gv-gv
xnoremap J :move '>+1<cr>gv-gv

set exrc
set secure

" %mode% %buffor_number% %spell?% %readonly?% %dirty?% %filename% <---> %file_format% %position% %position_p%

" set statusline=
" set statusline+=%#Cursor#%{(mode()=='n')?'\ \ NORMAL\ ':''}
" set statusline+=%#DiffChange#%{(mode()=='i')?'\ \ INSERT\ ':''}
" set statusline+=%#DiffDelete#%{(mode()=='R')?'\ \ RPLACE\ ':''}
" set statusline+=%#Cursor#%{(mode()=='v')?'\ \ VISUAL\ ':''}
" set statusline+=%#Cursor#%{(mode()=='V')?'\ \ VISUAL\ ':''}
" set statusline+=\ %n\           " buffer number
" set statusline+=%#Visual#       " colour
" set statusline+=%{&paste?'\ PASTE\ ':''}
" set statusline+=%{&spell?'\ SPELL\ ':''}
" set statusline+=%#CursorIM#     " colour
" set statusline+=%R                        " readonly flag
" set statusline+=%M                        " modified [+] flag
" set statusline+=%#Cursor#               " colour
" set statusline+=%#CursorLine#     " colour
" set statusline+=\ %t\                   " short file name
" set statusline+=%=                          " right align
" set statusline+=%#CursorLine#   " colour
" set statusline+=\ %Y\                   " file type
" set statusline+=%#CursorIM#     " colour
" set statusline+=\ %3l:%-2c\         " line + column
" set statusline+=%#Cursor#       " colour
" set statusline+=\ %3p%%\                " percentage

let g:currentmode={
    \ 'n'  : 'Normal',
    \ 'no' : 'Normal·Operator Pending',
    \ 'v'  : 'Visual',
    \ 'V'  : 'V·Line',
    \ '' : 'V·Blck',
    \ 's'  : 'Select',
    \ 'S'  : 'S·Line',
    \ '' : 'S·Block',
    \ 'i'  : 'Insert',
    \ 'R'  : 'Replace',
    \ 'Rv' : 'V·Replace',
    \ 'c'  : 'CMD   ',
    \ 'cv' : 'Vim Ex',
    \ 'ce' : 'Ex',
    \ 'r'  : 'Prompt',
    \ 'rm' : 'More',
    \ 'r?' : 'Confirm',
    \ '!'  : 'Shell',
    \ 't'  : 'Terminal'
    \}


" status bar colors
au InsertEnter * hi statusline guifg=black guibg=#d7afff ctermfg=black ctermbg=magenta
au InsertLeave * hi statusline guifg=black guibg=#8fbfdc ctermfg=black ctermbg=cyan
hi statusline guifg=black guibg=#8fbfdc ctermfg=black ctermbg=cyan


set noshowmode
set statusline=
set statusline+=\ %0*\ %{toupper(g:currentmode[mode()])}
set statusline+=%0*\ %n
set statusline+=\ %1*\ %<%t%m%h%w           " filename, modified, readonly, helpfile, preview
set statusline+=\ %3*|
set statusline+=%2*\ %{''.(&fenc!=''?&fenc:&enc).''}
set statusline+=\ (%{&ff})
set statusline+=%{&spell?'\ SPELL':''}
set statusline+=%=
set statusline+=%2*\ %Y
set statusline+=\ %3*|
set statusline+=%1*\ %02v:%02l\ (%3p%%)
set statusline+=\                           " keep extra space at the end

set laststatus=2


hi User1 ctermfg=007 ctermbg=239 guibg=#4e4e4e guifg=#adadad
hi User2 ctermfg=007 ctermbg=236 guibg=#303030 guifg=#adadad
hi User3 ctermfg=236 ctermbg=236 guibg=#303030 guifg=#303030
hi User4 ctermfg=239 ctermbg=239 guibg=#4e4e4e guifg=#4e4e4e

filetype off


"set rtp+=~/.vim/bundle/Vundle.vim
"call vundle#begin()
"Plugin 'VundleVim/Vundle.vim'
"Plugin 'airblade/vim-gitgutter'
"" Plugin 'rhysd/vim-clang-format'
"" Plugin 'rust-lang/rust.vim'
"Plugin 'ctrlpvim/ctrlp.vim'
"Plugin 'fzf'
"Plugin 'fzf.vim'
"call vundle#end()

" to download the vim-plug run: sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
call plug#begin(stdpath('data'))
Plug 'airblade/vim-gitgutter'
Plug 'rhysd/vim-clang-format'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'phanviet/vim-monokai-pro'

" Searching in files
if has('nvim')
    Plug 'Shougo/denite.nvim', { 'do': ':UpdateRemotePlugins' }
else
    Plug 'Shougo/denite.nvim'
    Plug 'roxma/nvim-yarp'
    Plug 'roxma/vim-hug-neovim-rpc'
endif

call plug#end()

" autocmd FileType c,cpp,cuda ClangFormatAutoEnable
filetype plugin indent on

set hidden

let mapleader=','

nnoremap <leader>, :w<cr>
nnoremap <leader><space> :noh<cr>


" Denite custom settings
autocmd FileType denite call s:denite_my_settings()
function! s:denite_my_settings() abort
  nnoremap <silent><buffer><expr> <CR>
  \ denite#do_map('do_action')
  nnoremap <silent><buffer><expr> d
  \ denite#do_map('do_action', 'delete')
  nnoremap <silent><buffer><expr> p
  \ denite#do_map('do_action', 'preview')
  nnoremap <silent><buffer><expr> q
  \ denite#do_map('quit')
  nnoremap <silent><buffer><expr> i
  \ denite#do_map('open_filter_buffer')
  nnoremap <silent><buffer><expr> <Space>
  \ denite#do_map('toggle_select').'j'
endfunction

call denite#custom#var('file/rec', 'command', ['rg', '--files', '--glob', '!.git'])
call denite#custom#var('grep', 'command', ['rg'])
call denite#custom#var('grep', 'default_opts', ['--hidden', '--vimgrep', '--heading', '-S'])

call denite#custom#var('grep', 'recursive_opts', [])
call denite#custom#var('grep', 'pattern_opt', ['--regexp'])
call denite#custom#var('grep', 'separator', ['--'])
call denite#custom#var('grep', 'final_opts', [])

let s:menus = {}
let s:menus.zsh = {
    \ 'description': 'Edit your import zsh configuration'
    \ }

let s:menus.vim = {
    \ 'description': 'Edit your vim configuration'
    \ }

let s:menus.zsh.file_candidates = [
    \ ['zshrc', '~/.config/zsh/.zshrc'],
    \ ['zshenv', '~/.zshenc'],
    \ ['zshrc-home', '~/.zshrc'],
    \ ]

let s:menus.vim.file_candidates = [
    \ ['vimrc-home', '~/.vimrc'],
    \ ['neovimrc', '~/.config/nvim/init.vim'],
    \ ]

call denite#custom#var('menu', 'menus', s:menus)

nmap ; :Denite buffer<cr>
nmap <leader>t :DeniteProjectDir file/rec<cr>
nnoremap <leader>g :<C-u>Denite grep:. -no-empty<cr>
nnoremap <leader>j :<C-u>DeniteCursorWord grep:.<cr>


nmap <silent> <c-p> :Files<cr>

colorscheme monokai_pro


" backups
if has('presistent_undo')
    set undofile
    set undolevels=3000
    set undoreload=10000
endif
set backupdir=~/.local/share/nvim/backup
set backup
set noswapfile



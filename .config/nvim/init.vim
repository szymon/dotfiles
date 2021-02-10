
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
set mouse=a

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

set exrc
set secure


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

" to download the vim-plug run: sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
call plug#begin(stdpath('data'))
Plug 'airblade/vim-gitgutter'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'phanviet/vim-monokai-pro'
Plug 'neoclide/coc.nvim', {'branch': 'release' }
Plug 'hashivim/vim-terraform'

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


set signcolumn=number

inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

" Make <CR> auto-select the first completion item and notify coc.nvim to
" format on enter, <cr> could be remapped by other vim plugin
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocAction('format')

" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')



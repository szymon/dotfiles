source ~/.vimrc

set mouse=a
set signcolumn=yes
set hidden
set nowrap

" Tweaks for browsing
let g:netrw_banner=0
let g:netrw_browse_split=4
let g:netrw_altv=1
let g:netrw_liststyle=3
let g:netrw_list_hide=netrw_gitignore#Hide()
let g:netrw_list_hide.=',\(^\|\s\s\)\zs\.\S\+'

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

filetype off

" to download the vim-plug run: sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
call plug#begin(stdpath('data'))

Plug 'airblade/vim-gitgutter'
Plug 'google/vim-jsonnet'
Plug 'hashivim/vim-terraform'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'markonm/traces.vim'
Plug 'morhetz/gruvbox'
Plug 'neoclide/coc.nvim', {'branch': 'release' }
Plug 'phanviet/vim-monokai-pro'
Plug 'projekt0n/github-nvim-theme'
Plug 'psf/black'
Plug 'sheerun/vim-polyglot'
Plug 'tpope/vim-fugitive'

call plug#end()

colorscheme gruvbox

" status bar colors
hi statusline guifg=black guibg=#8fbfdc ctermfg=black ctermbg=cyan

hi Visual gui=None term=reverse ctermfg=none ctermbg=232
hi Folded gui=None term=reverse ctermfg=none ctermbg=232

hi User1 ctermfg=007 ctermbg=239 guibg=#4e4e4e guifg=#adadad
hi User2 ctermfg=007 ctermbg=236 guibg=#303030 guifg=#adadad
hi User3 ctermfg=236 ctermbg=236 guibg=#303030 guifg=#303030
hi User4 ctermfg=239 ctermbg=239 guibg=#4e4e4e guifg=#4e4e4e

filetype plugin indent on

nnoremap <silent><leader>gc <cmd>GitGutterPreviewHunk<cr>

nnoremap <silent> ; <cmd>Buffers <cr>
nnoremap <silent> <c-p> <cmd>Files<cr>
nnoremap <silent><leader>rg <cmd>Rg<cr>

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)


" Symbol renaming.
nnoremap <leader>rn <Plug>(coc-rename)

" Use K to show documentation in preview window.
nnoremap <silent> K <cmd>call <SID>show_documentation()<CR>

" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()

inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"


nmap <leader>mn <plug>(fzf-maps-n)
nmap <leader>mi <plug>(fzf-maps-i)
nmap <leader>mx <plug>(fzf-maps-x)
nmap <leader>mo <plug>(fzf-maps-o)


" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocAction('format')<cr>

" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call CocAction('fold', <f-args>)<cr>


" use `:OR` for organize import of current buffer
command! -nargs=0 OR :call CocAction('runCommand', 'editor.action.organizeImport')<cr>

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

augroup SZYMON_CUSTOM
    au!

    " Highlight the symbol and its references when holding the cursor.
    autocmd CursorHold * silent call CocActionAsync('highlight')
    au InsertEnter * hi statusline guifg=black guibg=#d7afff ctermfg=black ctermbg=magenta
    au InsertLeave * hi statusline guifg=black guibg=#8fbfdc ctermfg=black ctermbg=cyan
    autocmd FileType yaml setlocal ts=12 sts=2 sw=2 expandtab indentkeys-=<:>

augroup END


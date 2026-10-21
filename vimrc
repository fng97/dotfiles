let mapleader = " "
let maplocalleader = " "

set number             " Enable line numbers
set scrolloff=3        " Vertically pad lines around cursor
set sidescrolloff=3    " Horizontally pad lines around cursor
set undofile           " Persist undo history across sessions
set confirm            " Confirm unsaved changes before exiting
set ignorecase         " Ignore case when searching...
set smartcase          " ...unless uppercase is used in search
set textwidth=100      " Break lines at 100 characters

set tabstop=4          " Spaces to display for tab character
set softtabstop=4      " Spaces inserted when tab pressed
set shiftwidth=4       " Spaces to use for indentation
set expandtab          " Convert tabs to spaces
set smartindent        " Auto-indent new lines
set autoindent         " Copy indent from current line
set breakindent        " Maintain wrap indentation on long lines

augroup CustomFiletypes
autocmd!
autocmd FileType c,cpp setlocal commentstring=//\ %s
autocmd FileType markdown setlocal spelllang=en_gb textwidth=80
autocmd FileType markdown,gitcommit setlocal formatoptions+=q comments+=n:>
autocmd FileType python setlocal textwidth=88
augroup END

vnoremap < <gv
vnoremap > >gv

nnoremap <Esc> :nohlsearch<CR>

nnoremap n nzz
nnoremap N Nzz

nnoremap <S-h> :bprevious<CR>
nnoremap <S-l> :bnext<CR>
nnoremap <leader>bn :en

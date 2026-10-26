set number                " Enable line numbers
set scrolloff=3           " Vertically pad lines around cursor
set sidescrolloff=3       " Horizontally pad lines around cursor
set undofile              " Persist undo history across sessions
set undodir=~/.vim/undo// " Use global undo file dir
set confirm               " Confirm unsaved changes before exiting
set ignorecase            " Ignore case when searching...
set smartcase             " ...unless uppercase is used in search
set textwidth=100         " Break lines at 100 characters
set laststatus=2          " Always show status line
set ruler                 " Show line row/col
set tabstop=4             " Spaces to display for tab character
set softtabstop=4         " Spaces inserted when tab pressed
set shiftwidth=4          " Spaces to use for indentation
set expandtab             " Convert tabs to spaces
set smartindent           " Auto-indent new lines
set autoindent            " Copy indent from current line
set breakindent           " Maintain wrap indentation on long lines

augroup CustomFiletypes
autocmd!
autocmd FileType c,cpp setlocal commentstring=//\ %s
autocmd FileType markdown setlocal textwidth=80
autocmd FileType markdown,gitcommit setlocal formatoptions+=q comments+=n:>
autocmd FileType python setlocal textwidth=88
augroup END

vnoremap < <gv
vnoremap > >gv

nnoremap n nzz
nnoremap N Nzz

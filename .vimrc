" Minimal Vim configuration with vim-plug (optional)

set nocompatible
set encoding=utf-8
syntax on
filetype plugin indent on

set number
set expandtab
set shiftwidth=2
set softtabstop=2
set tabstop=2
set backspace=indent,eol,start

" Better search
set ignorecase
set smartcase
set incsearch
set hlsearch

" Plugins (optional):
" Install vim-plug first, then run :PlugInstall
" call plug#begin('~/.vim/plugged')
" Plug 'tpope/vim-sensible'
" Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
" Plug 'junegunn/fzf.vim'
" call plug#end()



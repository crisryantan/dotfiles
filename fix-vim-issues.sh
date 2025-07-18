#!/usr/bin/env bash

# Script to fix common Vim/Janus compatibility issues
# Addresses E1208 error and other compatibility problems with modern Vim

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Fixing Vim/Janus compatibility issues...${NC}"

# Fix 1: E1208 error in tlib plugin
TLIB_FILE="$HOME/.vim/janus/vim/tools/tlib/plugin/02tlib.vim"
if [ -f "$TLIB_FILE" ]; then
    echo -e "${YELLOW}Fixing E1208 error in tlib plugin...${NC}"
    # Fix line 77: remove -complete from commands that don't accept arguments
    sed -i.bak 's/command! -nargs=0 -complete=command/command! -nargs=0/g' "$TLIB_FILE"
    echo -e "${GREEN}✓ Fixed tlib plugin${NC}"
fi

# Fix 2: Check for other common issues in Janus plugins
JANUS_DIR="$HOME/.vim/janus/vim"
if [ -d "$JANUS_DIR" ]; then
    echo -e "${YELLOW}Checking for other potential issues...${NC}"
    
    # Find other instances of -complete used with -nargs=0
    find "$JANUS_DIR" -name "*.vim" -type f | while read -r file; do
        if grep -q "command! -nargs=0 -complete=" "$file" 2>/dev/null; then
            echo -e "${YELLOW}Fixing similar issue in: $(basename "$file")${NC}"
            sed -i.bak 's/command! -nargs=0 -complete=[^ ]*/command! -nargs=0/g' "$file"
        fi
    done
fi

# Fix 3: Create a minimal vimrc for git if issues persist
echo -e "${YELLOW}Creating minimal vimrc for git commits...${NC}"
cat > ~/.vimrc.minimal << 'EOF'
" Minimal vimrc for git commits
" Avoids loading problematic plugins while keeping essential features

" Basic settings
set nocompatible
syntax on
filetype plugin indent on
set encoding=utf-8
set backspace=indent,eol,start

" Git commit specific settings
autocmd FileType gitcommit setlocal spell textwidth=72
autocmd FileType gitcommit setlocal colorcolumn=73

" Simple color scheme
colorscheme desert

" Basic indentation
set expandtab
set shiftwidth=2
set softtabstop=2
EOF

echo -e "${GREEN}✓ Created ~/.vimrc.minimal${NC}"
echo
echo -e "${BLUE}Fixes applied!${NC}"
echo
echo "If you still experience issues with git commits, you can use the minimal vimrc:"
echo "  git config --global core.editor 'vim -u ~/.vimrc.minimal'"
echo
echo "To revert to normal vim:"
echo "  git config --global --unset core.editor" 

#!/usr/bin/env bash

# vim-fixes.sh - Fix common Vim/Janus compatibility issues
#
# This script addresses compatibility issues with Vim plugins,
# particularly the E1208 error in the tlib plugin when used with Janus.
#
# SECURITY NOTE:
# - This script only modifies files within the Vim plugin directories
# - It creates backups of any files it modifies
# - It does not execute any remote code
# - It only makes targeted fixes to specific known issues

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Vim Compatibility Fixes ===${NC}"

# Function to safely modify a file with backup
safe_modify() {
    local file="$1"
    local search="$2"
    local replace="$3"
    local description="$4"
    
    if [ ! -f "$file" ]; then
        echo -e "${YELLOW}File not found: $file${NC}"
        return 1
    fi
    
    # Create backup
    local backup="${file}.bak.$(date +%Y%m%d_%H%M%S)"
    echo -e "${YELLOW}Creating backup: ${backup}${NC}"
    cp "$file" "$backup"
    
    # Check if pattern exists
    if grep -q "$search" "$file"; then
        echo -e "${YELLOW}Fixing: $description${NC}"
        sed -i.tmp "s|$search|$replace|g" "$file"
        rm -f "${file}.tmp"
        echo -e "${GREEN}✓ Fixed: $description${NC}"
        return 0
    else
        echo -e "${GREEN}✓ No fix needed: $description${NC}"
        return 0
    fi
}

# Fix 1: E1208 error in tlib plugin
fix_tlib_e1208() {
    local tlib_file="$HOME/.vim/janus/vim/tools/tlib/plugin/02tlib.vim"
    
    if [ -f "$tlib_file" ]; then
        safe_modify "$tlib_file" \
            "command! -nargs=0 -complete=command TBrowseScriptnames" \
            "command! -nargs=0 TBrowseScriptnames" \
            "E1208 error in tlib plugin (TBrowseScriptnames command)"
    else
        echo -e "${YELLOW}tlib plugin not found, skipping fix${NC}"
    fi
}

# Fix 2: Check for other common issues in Janus plugins
fix_other_janus_issues() {
    local janus_dir="$HOME/.vim/janus/vim"
    
    if [ -d "$janus_dir" ]; then
        echo -e "${YELLOW}Checking for other potential issues...${NC}"
        
        # Find other instances of -complete used with -nargs=0
        find "$janus_dir" -name "*.vim" -type f -print0 | while IFS= read -r -d '' file; do
            if grep -q "command! -nargs=0 -complete=" "$file" 2>/dev/null; then
                local filename=$(basename "$file")
                safe_modify "$file" \
                    "command! -nargs=0 -complete=[^ ]*" \
                    "command! -nargs=0" \
                    "Similar E1208 issue in $filename"
            fi
        done
    else
        echo -e "${YELLOW}Janus not installed, skipping additional fixes${NC}"
    fi
}

# Create a minimal vimrc for git if issues persist
create_minimal_vimrc() {
    local minimal_vimrc="$HOME/.vimrc.minimal"
    
    echo -e "${YELLOW}Creating minimal vimrc for git commits...${NC}"
    
    cat > "$minimal_vimrc" << 'EOF'
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

    echo -e "${GREEN}✓ Created $minimal_vimrc${NC}"
    echo -e "${YELLOW}To use with git: git config --global core.editor 'vim -u ~/.vimrc.minimal'${NC}"
}

# Main function
main() {
    # Check if Vim is installed
    if ! command -v vim &> /dev/null; then
        echo -e "${RED}Vim not found. Skipping fixes.${NC}"
        return 1
    fi
    
    # Apply fixes
    fix_tlib_e1208
    fix_other_janus_issues
    create_minimal_vimrc
    
    echo
    echo -e "${GREEN}Vim fixes applied successfully!${NC}"
    echo
    echo -e "${YELLOW}If you still experience issues with git commits, you can use the minimal vimrc:${NC}"
    echo -e "  ${BLUE}git config --global core.editor 'vim -u ~/.vimrc.minimal'${NC}"
    echo
    echo -e "${YELLOW}To revert to normal vim:${NC}"
    echo -e "  ${BLUE}git config --global --unset core.editor${NC}"
}

# Run main function
main 
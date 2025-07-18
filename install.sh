#!/usr/bin/env bash

# Modern installation script for dotfiles
# Handles both bash and zsh shells, existing installations, and common issues

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Detect the current shell
detect_shell() {
    if [ -n "$ZSH_VERSION" ]; then
        echo "zsh"
    elif [ -n "$BASH_VERSION" ]; then
        echo "bash"
    else
        echo "unknown"
    fi
}

# Main installation function
main() {
    print_info "Starting dotfiles installation..."
    
    # Change to script directory
    cd "$(dirname "${BASH_SOURCE[0]}")"
    
    # Update from git
    print_info "Updating dotfiles from git..."
    git pull origin master || print_warning "Could not pull latest changes"
    
    # Detect shell
    CURRENT_SHELL=$(detect_shell)
    USER_SHELL=$(basename "$SHELL")
    print_info "Current shell: $CURRENT_SHELL"
    print_info "Default shell: $USER_SHELL"
    
    # Install dependencies
    print_info "Installing dependencies..."
    if [ -f "./.dep.sh" ]; then
        source ./.dep.sh
    else
        print_warning "No .dep.sh found, skipping dependency installation"
    fi
    
    # Run bootstrap
    print_info "Copying dotfiles to home directory..."
    if [ "$1" == "--force" ] || [ "$1" == "-f" ]; then
        ./bootstrap.sh --force
    else
        ./bootstrap.sh
    fi
    
    # Handle zsh configuration
    if [ "$USER_SHELL" = "zsh" ]; then
        print_info "Configuring for zsh..."
        setup_zsh
    fi
    
    # Fix Vim issues
    print_info "Checking Vim configuration..."
    fix_vim_issues
    
    # Run health check
    print_info "Running health check..."
    if [ -f "./healthcheck.sh" ]; then
        ./healthcheck.sh
    fi
    
    print_success "Installation complete!"
    print_info "Please restart your terminal or run: source ~/.$USER_SHELL"rc
}

# Setup zsh to work with bash dotfiles
setup_zsh() {
    local ZSHRC="$HOME/.zshrc"
    local MARKER="# === Dotfiles Configuration ==="
    
    # Check if our configuration is already added
    if grep -q "$MARKER" "$ZSHRC" 2>/dev/null; then
        print_info "Zsh configuration already exists, skipping..."
        return
    fi
    
    print_info "Adding dotfiles configuration to .zshrc..."
    
    # Backup existing .zshrc
    if [ -f "$ZSHRC" ]; then
        cp "$ZSHRC" "$ZSHRC.backup.$(date +%Y%m%d_%H%M%S)"
        print_info "Backed up existing .zshrc"
    fi
    
    # Add our configuration
    cat >> "$ZSHRC" << 'EOF'

# === Dotfiles Configuration ===
# Load bash-based dotfiles in zsh

# Add ~/bin to PATH
export PATH="$HOME/bin:$PATH"

# Load shell dotfiles
for file in ~/.{path,exports,aliases,functions,extra}; do
    [ -r "$file" ] && [ -f "$file" ] && source "$file"
done
unset file

# Load z (smart cd)
[ -f ~/.bin/z/z.sh ] && source ~/.bin/z/z.sh

# Enable zsh options for bash compatibility
setopt AUTO_CD           # cd by typing directory name
setopt GLOB_STAR_SHORT   # ** for recursive globbing
setopt NO_CASE_GLOB      # case insensitive globbing
setopt APPEND_HISTORY    # append to history file
setopt HIST_IGNORE_DUPS  # ignore duplicate commands
setopt CORRECT           # command correction

# Enable prompt substitution
setopt PROMPT_SUBST

# Git info function
git_info() {
    git rev-parse --is-inside-work-tree &>/dev/null || return
    local branch=$(git symbolic-ref -q HEAD | sed -e 's|^refs/heads/||')
    local dirty=$(git diff --quiet --ignore-submodules HEAD &>/dev/null; [ $? -eq 1 ] && echo "*")
    echo -e "$branch$dirty "
}

# Zsh prompt (similar to bash prompt)
PROMPT='
%F{blue}%~%f
$(git rev-parse --is-inside-work-tree &>/dev/null && echo "%F{magenta}🐶  %f")$(git_info)%F{white}:%f '

PROMPT2='%F{yellow}→ %f'
# === End Dotfiles Configuration ===
EOF
    
    print_success "Zsh configuration added"
}

# Fix common Vim issues
fix_vim_issues() {
    local VIM_PLUGIN="/Users/$USER/.vim/janus/vim/tools/tlib/plugin/02tlib.vim"
    
    if [ -f "$VIM_PLUGIN" ]; then
        # Fix the E1208 error
        if grep -q "command! -nargs=0 -complete=command TBrowseScriptnames" "$VIM_PLUGIN" 2>/dev/null; then
            print_info "Fixing Vim plugin compatibility issue..."
            sed -i.bak 's/command! -nargs=0 -complete=command TBrowseScriptnames/command! -nargs=0 TBrowseScriptnames/' "$VIM_PLUGIN"
            print_success "Vim issue fixed"
        fi
    fi
}

# Run main installation
main "$@" 

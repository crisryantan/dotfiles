#!/usr/bin/env bash

# Modern dependency installation script
# Handles existing installations gracefully and updates outdated dependencies

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

# Create bin directory if it doesn't exist
if [ ! -d "$HOME/.bin" ]; then
    print_info "Creating ~/.bin directory..."
    mkdir -p "$HOME/.bin"
    print_success "Created ~/.bin directory"
fi

# Install z - smart directory navigation
install_z() {
    local Z_DIR="$HOME/.bin/z"
    
    if [ -d "$Z_DIR" ]; then
        print_info "Updating z..."
        cd "$Z_DIR"
        git pull origin master
        cd - > /dev/null
        print_success "z updated"
    else
        print_info "Installing z..."
        git clone https://github.com/rupa/z.git "$Z_DIR"
        print_success "z installed"
    fi
}

# Install vim-plug for Vim and Neovim
install_vim_plug() {
    if command -v curl > /dev/null 2>&1; then
        # Vim
        if [ ! -f "$HOME/.vim/autoload/plug.vim" ]; then
            print_info "Installing vim-plug for Vim..."
            curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
                https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
            print_success "vim-plug (Vim) installed"
        else
            print_info "vim-plug (Vim) already installed"
        fi
        # Neovim
        if command -v nvim > /dev/null 2>&1; then
            local NVIM_PLUG_PATH="$HOME/.local/share/nvim/site/autoload/plug.vim"
            if [ ! -f "$NVIM_PLUG_PATH" ]; then
                print_info "Installing vim-plug for Neovim..."
                curl -fLo "$NVIM_PLUG_PATH" --create-dirs \
                    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
                print_success "vim-plug (Neovim) installed"
            else
                print_info "vim-plug (Neovim) already installed"
            fi
        fi
    else
        print_warning "curl not found; skipping vim-plug installation"
    fi
}

# Main installation
print_info "Installing dependencies..."

# Install z
install_z

# Install vim-plug if Vim or Neovim is available
if command -v vim > /dev/null || command -v nvim > /dev/null; then
    install_vim_plug
else
    print_warning "Vim/Neovim not found, skipping vim-plug installation"
fi

print_success "Dependencies installed!"

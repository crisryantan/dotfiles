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

# Install Janus (Vim distribution)
install_janus() {
    if [ -d "$HOME/.vim/janus" ]; then
        print_info "Janus already installed, updating..."
        cd "$HOME/.vim"
        rake
        cd - > /dev/null
        print_success "Janus updated"
    else
        print_info "Installing Janus vim distribution..."
        if command -v curl > /dev/null && command -v ruby > /dev/null && command -v rake > /dev/null; then
            curl -L https://bit.ly/janus-bootstrap | bash
            print_success "Janus installed"
        else
            print_warning "Skipping Janus installation: curl, ruby or rake not found"
            print_info "To install Janus manually later, run: curl -L https://bit.ly/janus-bootstrap | bash"
        fi
    fi
}

# Main installation
print_info "Installing dependencies..."

# Install z
install_z

# Install Janus if vim is available
if command -v vim > /dev/null; then
    install_janus
else
    print_warning "Vim not found, skipping Janus installation"
fi

print_success "Dependencies installed!"

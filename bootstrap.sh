#!/usr/bin/env bash

# Bootstrap script for dotfiles
# Copies dotfiles to home directory with proper backup

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

cd "$(dirname "${BASH_SOURCE}")"

# Update from git if not forced
if [ "$1" != "--force" ] && [ "$1" != "-f" ]; then
    print_info "Updating from git..."
    git pull origin master || print_warning "Could not pull latest changes"
fi

# Files to exclude from copying
EXCLUDES=(
    ".git"
    ".DS_Store"
    "bootstrap.sh"
    "README.md"
    "LICENSE-MIT.txt"
    "install.sh"
    "healthcheck.sh"
    "fix-vim-issues.sh"
    ".dep.sh"
)

# Function to copy dotfiles
doIt() {
    # Create backup directory
    BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    
    # Backup existing dotfiles
    print_info "Backing up existing dotfiles to $BACKUP_DIR..."
    
    # Find all dotfiles in the repo
    for file in $(find . -maxdepth 1 -name ".*" -type f); do
        filename=$(basename "$file")
        
        # Skip excluded files
        skip=false
        for exclude in "${EXCLUDES[@]}"; do
            if [ "$filename" == "$exclude" ]; then
                skip=true
                break
            fi
        done
        
        if [ "$skip" == true ]; then
            continue
        fi
        
        # Backup if exists
        if [ -f "$HOME/$filename" ]; then
            cp "$HOME/$filename" "$BACKUP_DIR/" 2>/dev/null || true
        fi
    done
    
    # Copy dotfiles
    print_info "Copying dotfiles to home directory..."
    
    # Build rsync exclude pattern
    RSYNC_EXCLUDES=""
    for exclude in "${EXCLUDES[@]}"; do
        RSYNC_EXCLUDES="$RSYNC_EXCLUDES --exclude=$exclude"
    done
    
    # Use rsync to copy files
    rsync -av --no-perms $RSYNC_EXCLUDES . "$HOME"
    
    # Source bash_profile
    if [ -f "$HOME/.bash_profile" ]; then
        print_info "Sourcing .bash_profile..."
        source "$HOME/.bash_profile" 2>/dev/null || true
    fi
    
    print_success "Dotfiles installed!"
}

# Confirm before proceeding
if [ "$1" == "--force" ] || [ "$1" == "-f" ]; then
    doIt
else
    read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        doIt
    fi
fi

unset doIt

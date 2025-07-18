#!/usr/bin/env bash

# This is a compatibility wrapper for the moved script
# The actual script is now in scripts/vim-fixes.sh

echo "NOTE: This script has been moved to scripts/vim-fixes.sh"
echo "Redirecting to the new location..."
echo

# Check if the new script exists
if [ -f "./scripts/vim-fixes.sh" ]; then
    ./scripts/vim-fixes.sh
else
    echo "ERROR: Could not find scripts/vim-fixes.sh"
    echo "Please run: cd ~/.dotfiles && git pull"
    exit 1
fi 

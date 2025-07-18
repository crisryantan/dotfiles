#!/usr/bin/env bash

# This is a compatibility wrapper for the moved script
# The actual script is now in scripts/healthcheck.sh

echo "NOTE: This script has been moved to scripts/healthcheck.sh"
echo "Redirecting to the new location..."
echo

# Check if the new script exists
if [ -f "./scripts/healthcheck.sh" ]; then
    ./scripts/healthcheck.sh
else
    echo "ERROR: Could not find scripts/healthcheck.sh"
    echo "Please run: cd ~/.dotfiles && git pull"
    exit 1
fi 

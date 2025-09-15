#!/usr/bin/env bash

# Modern macOS setup (safe defaults)
# Tested on recent macOS (Ventura/Sonoma). Idempotent and conservative.

set -e

BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}=== macOS Setup (Safe Defaults) ===${NC}"

# Ask for admin once if needed for certain tweaks
if command -v sudo >/dev/null 2>&1; then
	echo -e "${YELLOW}Requesting administrator privileges (if needed)...${NC}"
	sudo -v || true
fi

echo -e "${BLUE}Finder & Files...${NC}"
# Show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
# Show status and path bar in Finder
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder ShowPathbar -bool true
# New Finder windows show home directory
defaults write com.apple.finder NewWindowTarget -string "PfLo"
defaults write com.apple.finder NewWindowTargetPath -string "file://$HOME/"
# Show the ~/Library folder
chflags nohidden "$HOME/Library" || true
# Relaunch Finder to apply
killall Finder >/dev/null 2>&1 || true

echo -e "${BLUE}Dock...${NC}"
# Auto-hide Dock and remove the hide/show delay
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0.2
# Show indicator lights for open apps
defaults write com.apple.dock show-process-indicators -bool true
# Apply Dock changes
killall Dock >/dev/null 2>&1 || true

echo -e "${BLUE}Keyboard & Input...${NC}"
# Fast key repeat (use safe values)
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 25
# Disable press-and-hold in favor of key repeat
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

echo -e "${BLUE}Screenshots...${NC}"
mkdir -p "$HOME/Desktop/Screenshots"
defaults write com.apple.screencapture location -string "$HOME/Desktop/Screenshots"
defaults write com.apple.screencapture type -string "png"
killall SystemUIServer >/dev/null 2>&1 || true

echo -e "${BLUE}Terminal...${NC}"
# Only use UTF-8 in Terminal
defaults write com.apple.terminal StringEncodings -array 4

echo -e "${GREEN}Done. Some changes may require a logout/restart to take effect.${NC}"



#!/usr/bin/env bash

# Health check script for dotfiles installation
# Verifies that everything is set up correctly

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check mark and X mark
CHECK="${GREEN}✓${NC}"
CROSS="${RED}✗${NC}"

echo -e "${BLUE}=== Dotfiles Health Check ===${NC}"
echo

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if a file exists
file_exists() {
    [ -f "$1" ]
}

# Function to check if a directory exists
dir_exists() {
    [ -d "$1" ]
}

# Check shell configuration
echo -e "${BLUE}Checking shell configuration...${NC}"

CURRENT_SHELL=$(basename "$SHELL")
echo -e "Current shell: ${YELLOW}$CURRENT_SHELL${NC}"

if [ "$CURRENT_SHELL" = "zsh" ]; then
    if file_exists "$HOME/.zshrc" && grep -q "Dotfiles Configuration" "$HOME/.zshrc" 2>/dev/null; then
        echo -e "$CHECK Zsh configured for dotfiles"
    else
        echo -e "$CROSS Zsh not configured for dotfiles"
        echo -e "  ${YELLOW}Run: cat ~/.dotfiles/.zshrc.template >> ~/.zshrc${NC}"
    fi
fi

# Check dotfiles
echo
echo -e "${BLUE}Checking dotfiles...${NC}"

DOTFILES=(
    ".aliases"
    ".bash_profile"
    ".bash_prompt"
    ".bashrc"
    ".exports"
    ".functions"
    ".gitconfig"
)

for dotfile in "${DOTFILES[@]}"; do
    if file_exists "$HOME/$dotfile"; then
        echo -e "$CHECK $dotfile"
    else
        echo -e "$CROSS $dotfile missing"
    fi
done

# Check dependencies
echo
echo -e "${BLUE}Checking dependencies...${NC}"

# Check z
if dir_exists "$HOME/.bin/z" && file_exists "$HOME/.bin/z/z.sh"; then
    echo -e "$CHECK z (smart cd) installed"
else
    echo -e "$CROSS z not installed"
    echo -e "  ${YELLOW}Run: ./.dep.sh${NC}"
fi

# Check if z is loaded
if command_exists z 2>/dev/null || alias z 2>/dev/null; then
    echo -e "$CHECK z command available"
else
    echo -e "$CROSS z command not available (restart shell or source rc file)"
fi

# Check Vim/Neovim
VIM_FOUND=false
if command_exists vim; then
    VIM_VERSION=$(vim --version | head -1)
    echo -e "$CHECK Vim installed: $VIM_VERSION"
    VIM_FOUND=true
fi
if command_exists nvim; then
    NVIM_VERSION=$(nvim --version | head -1)
    echo -e "$CHECK Neovim installed: $NVIM_VERSION"
    VIM_FOUND=true
fi
if [ "$VIM_FOUND" = false ]; then
    echo -e "$CROSS Vim/Neovim not installed (optional)"
fi

# Check for vim-plug presence
if [ -f "$HOME/.vim/autoload/plug.vim" ] || [ -f "$HOME/.local/share/nvim/site/autoload/plug.vim" ]; then
    echo -e "$CHECK vim-plug installed"
else
    echo -e "$CROSS vim-plug not installed"
    echo -e "  ${YELLOW}You can install via: curl -fLo ~/.vim/autoload/plug.vim --create-dirs \\
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim${NC}"
fi

# Check Git configuration
echo
echo -e "${BLUE}Checking Git configuration...${NC}"

if command_exists git; then
    echo -e "$CHECK Git installed"
    
    # Check git editor
    GIT_EDITOR=$(git config --get core.editor || echo "default")
    echo -e "  Git editor: ${YELLOW}$GIT_EDITOR${NC}"
    
    # Check if user has set their identity
    GIT_USER=$(git config --get user.name || echo "not set")
    GIT_EMAIL=$(git config --get user.email || echo "not set")
    
    if [ "$GIT_USER" != "not set" ]; then
        echo -e "$CHECK Git user name: $GIT_USER"
    else
        echo -e "$CROSS Git user name not set"
        echo -e "  ${YELLOW}Run: git config --global user.name \"Your Name\"${NC}"
    fi
    
    if [ "$GIT_EMAIL" != "not set" ]; then
        echo -e "$CHECK Git user email: $GIT_EMAIL"
    else
        echo -e "$CROSS Git user email not set"
        echo -e "  ${YELLOW}Run: git config --global user.email \"your@email.com\"${NC}"
    fi
else
    echo -e "$CROSS Git not installed"
fi

# Check aliases
echo
echo -e "${BLUE}Checking aliases...${NC}"

# Source aliases if not already loaded
if ! alias gs &>/dev/null; then
    source "$HOME/.aliases" 2>/dev/null || true
fi

SAMPLE_ALIASES=("gs" "ga" "ll" "..")
WORKING_ALIASES=0

for alias_name in "${SAMPLE_ALIASES[@]}"; do
    if alias "$alias_name" &>/dev/null; then
        ((WORKING_ALIASES++))
    fi
done

if [ $WORKING_ALIASES -eq ${#SAMPLE_ALIASES[@]} ]; then
    echo -e "$CHECK All sample aliases working"
else
    echo -e "$CROSS Some aliases not loaded ($WORKING_ALIASES/${#SAMPLE_ALIASES[@]} working)"
    echo -e "  ${YELLOW}Restart your terminal or run: source ~/.$CURRENT_SHELL"rc"${NC}"
    if [ "$CURRENT_SHELL" = "zsh" ]; then
        echo -e "  ${YELLOW}Zsh users can also: source ~/.zshrc${NC}"
    elif [ "$CURRENT_SHELL" = "bash" ]; then
        echo -e "  ${YELLOW}Bash users can also: source ~/.bash_profile${NC}"
    fi
fi

# Summary
echo
echo -e "${BLUE}=== Summary ===${NC}"

if [ "$CURRENT_SHELL" = "zsh" ] && ! grep -q "Dotfiles Configuration" "$HOME/.zshrc" 2>/dev/null; then
    echo -e "${YELLOW}Action needed:${NC} Configure zsh for dotfiles"
    echo -e "Run: ${GREEN}cat ~/.dotfiles/.zshrc.template >> ~/.zshrc && source ~/.zshrc${NC}"
elif ! alias gs &>/dev/null; then
    echo -e "${YELLOW}Action needed:${NC} Reload your shell configuration"
    echo -e "Run: ${GREEN}source ~/.$CURRENT_SHELL"rc"${NC}"
else
    echo -e "${GREEN}Everything looks good!${NC} 🎉"
    echo -e "Your terminal is properly configured with the dotfiles."
fi

echo 
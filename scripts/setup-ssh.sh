#!/usr/bin/env bash

# setup-ssh.sh - Set up SSH authentication for GitHub on macOS
# This script helps configure SSH for seamless Git operations with GitHub

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== GitHub SSH Setup ===${NC}"
echo

# Check if SSH key already exists
if [ -f ~/.ssh/id_ed25519 ]; then
    echo -e "${YELLOW}SSH key already exists at ~/.ssh/id_ed25519${NC}"
    read -p "Do you want to generate a new key anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${GREEN}Using existing SSH key${NC}"
    else
        # Generate new SSH key
        echo -e "${YELLOW}Generating new SSH key...${NC}"
        read -p "Enter your email address: " email
        ssh-keygen -t ed25519 -C "$email"
    fi
else
    # Generate new SSH key
    echo -e "${YELLOW}No SSH key found. Generating new SSH key...${NC}"
    read -p "Enter your email address: " email
    ssh-keygen -t ed25519 -C "$email"
fi

# Start SSH agent
echo -e "${YELLOW}Starting SSH agent...${NC}"
eval "$(ssh-agent -s)"

# Create SSH config directory if it doesn't exist
mkdir -p ~/.ssh

# Create or update SSH config
echo -e "${YELLOW}Creating/updating SSH config...${NC}"
cat > ~/.ssh/config << 'EOF'
# GitHub SSH Configuration
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519
    AddKeysToAgent yes
    UseKeychain yes
    IdentitiesOnly yes
EOF

echo -e "${GREEN}SSH config created at ~/.ssh/config${NC}"

# Add key to SSH agent
echo -e "${YELLOW}Adding SSH key to agent...${NC}"
if ssh-add --apple-use-keychain ~/.ssh/id_ed25519 2>/dev/null; then
    echo -e "${GREEN}SSH key added to agent${NC}"
else
    # Fall back to older syntax if --apple-use-keychain is not supported
    ssh-add -K ~/.ssh/id_ed25519
    echo -e "${GREEN}SSH key added to agent (using legacy -K option)${NC}"
fi

# Copy public key to clipboard
echo -e "${YELLOW}Copying public key to clipboard...${NC}"
pbcopy < ~/.ssh/id_ed25519.pub
echo -e "${GREEN}Public key copied to clipboard${NC}"

# Test connection
echo -e "${YELLOW}Testing connection to GitHub...${NC}"
echo "You should see: 'Hi username! You've successfully authenticated, but GitHub does not provide shell access.'"
echo
ssh -T git@github.com || true

echo
echo -e "${BLUE}=== Next Steps ===${NC}"
echo -e "1. Add your SSH key to GitHub:"
echo -e "   - Go to ${YELLOW}https://github.com/settings/keys${NC}"
echo -e "   - Click '${GREEN}New SSH key${NC}'"
echo -e "   - Paste your key (already in clipboard) and save"
echo
echo -e "2. Update your repository remote URL:"
echo -e "   ${YELLOW}git remote set-url origin git@github.com:username/repository.git${NC}"
echo
echo -e "3. Test with a git pull:"
echo -e "   ${YELLOW}git pull${NC}"
echo

# Check if this is the dotfiles repository
if [ -f "./install.sh" ] && [ -d "./scripts" ]; then
    echo -e "${BLUE}=== Dotfiles Repository ===${NC}"
    echo -e "Would you like to update this dotfiles repository to use SSH? (y/n) "
    read -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        current_remote=$(git remote -v | grep fetch | awk '{print $2}')
        if [[ $current_remote == https://github.com/* ]]; then
            repo_name=$(echo $current_remote | sed 's/https:\/\/github.com\///')
            echo -e "${YELLOW}Updating remote URL from HTTPS to SSH...${NC}"
            git remote set-url origin "git@github.com:$repo_name"
            echo -e "${GREEN}Remote URL updated to: git@github.com:$repo_name${NC}"
        else
            echo -e "${GREEN}Remote URL is already using SSH: $current_remote${NC}"
        fi
    fi
fi

echo -e "${GREEN}SSH setup complete!${NC}" 
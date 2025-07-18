# Ryan's dotfiles

A collection of dotfiles and scripts for setting up a development environment with a beautifully customized terminal.

## Features

- 🎨 Beautiful terminal prompt with git integration
- 🚀 Smart directory navigation with `z`
- ⚡ Useful aliases and functions
- 🔧 Vim configuration with Janus
- 💻 Support for both bash and zsh shells

## Installation

### SSH Setup (Recommended)

For seamless Git operations, set up SSH authentication with GitHub:

```bash
# If you already have the dotfiles repository:
cd ~/.dotfiles
./scripts/setup-ssh.sh

# Or manually:
ssh-keygen -t ed25519 -C "your_email@example.com"
eval "$(ssh-agent -s)"
ssh-add --apple-use-keychain ~/.ssh/id_ed25519
mkdir -p ~/.ssh
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
pbcopy < ~/.ssh/id_ed25519.pub
```

Then add the SSH key to your GitHub account:
1. Go to GitHub → Settings → SSH and GPG keys
2. Click "New SSH key"
3. Paste your key and save

### Quick Install (Recommended)

```bash
git clone git@github.com:crisryantan/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

The `install.sh` script will:
- Detect your shell (bash/zsh) and configure accordingly
- Install dependencies (z, vim plugins)
- Copy dotfiles to your home directory
- Fix common compatibility issues
- Set up your terminal prompt

### Manual Install

If you prefer to install components separately:

```bash
# Clone the repository
git clone git@github.com:crisryantan/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# Install dependencies
./.dep.sh

# Copy dotfiles to home directory
./bootstrap.sh
```

### For Zsh Users

If you're using zsh (default on modern macOS), the installer will automatically configure it to work with these dotfiles.

To manually add the configuration, append the contents of `.zshrc.template` to your `~/.zshrc`:

```bash
cat ~/.dotfiles/.zshrc.template >> ~/.zshrc
source ~/.zshrc
```

### Verifying Installation

After installation, run the health check script to verify everything is set up correctly:

```bash
cd ~/.dotfiles
./scripts/healthcheck.sh
```

The script will check for:
- Proper shell configuration
- Installed dependencies
- Git configuration
- Working aliases
- And more!

## Troubleshooting

### Git Commit Vim Error (E1208)

If you see this error when running `git commit`:
```
Error detected while processing /Users/ryan.tan/.vim/janus/vim/tools/tlib/plugin/02tlib.vim:
line   77: E1208: -complete used without allowing arguments
```

Run the fix script:
```bash
cd ~/.dotfiles
./scripts/vim-fixes.sh
```

### Alternative Solutions for Git Editor

If you continue to have issues with Vim, you can use a different editor for git:

```bash
# Use VS Code/Cursor
git config --global core.editor "code --wait"

# Use nano (simple terminal editor)
git config --global core.editor "nano"

# Use minimal vim (without plugins)
git config --global core.editor "vim -u ~/.vimrc.minimal"
```

### Existing Installation Errors

If you get "directory already exists" errors when running `.dep.sh`, this means dependencies are already installed. You can:
- Run `./install.sh` which handles existing installations gracefully
- Or run `./bootstrap.sh` directly to just update your dotfiles

### Missing Dependencies

If the `z` command doesn't work after installation, try:

```bash
# Manually install z
mkdir -p ~/.bin
git clone https://github.com/rupa/z.git ~/.bin/z
echo '. ~/.bin/z/z.sh' >> ~/.bash_profile  # For bash
# OR
echo '. ~/.bin/z/z.sh' >> ~/.zshrc  # For zsh

# Then reload your shell
source ~/.bash_profile  # For bash
# OR
source ~/.zshrc  # For zsh
```

### SSH Authentication Issues

If you see "You've successfully authenticated, but GitHub does not provide shell access" when testing your SSH connection, this is normal. It means your SSH key is working correctly with GitHub.

If you're having issues with Git operations:

1. Ensure your SSH key is added to the agent:
   ```bash
   eval "$(ssh-agent -s)"
   ssh-add --apple-use-keychain ~/.ssh/id_ed25519
   ```

2. Verify your SSH connection:
   ```bash
   ssh -T git@github.com
   ```

3. Check your repository's remote URL:
   ```bash
   git remote -v
   ```

4. If using HTTPS, switch to SSH:
   ```bash
   git remote set-url origin git@github.com:username/repository.git
   ```

## What's Included

### Dotfiles
- `.aliases` - Useful command shortcuts
- `.bash_profile` - Bash configuration
- `.bash_prompt` - Custom prompt with git integration
- `.functions` - Shell functions
- `.exports` - Environment variables
- `.gitconfig` - Git configuration
- `.vimrc.after` / `.vimrc.before` - Vim customizations

### Scripts
- `install.sh` - Modern installation script with shell detection
- `.dep.sh` - Dependency installation (z, vim plugins)
- `bootstrap.sh` - Copies dotfiles to home directory
- `.zshrc.template` - Zsh configuration template
- `scripts/healthcheck.sh` - Verifies correct installation
- `scripts/vim-fixes.sh` - Fixes Vim/Janus compatibility issues
- `scripts/setup-ssh.sh` - Sets up SSH for GitHub authentication

## Customization

### Adding Your Own Settings

Create a `~/.extra` file for settings you don't want to commit:

```bash
# Git credentials
GIT_AUTHOR_NAME="Your Name"
GIT_AUTHOR_EMAIL="your@email.com"
git config --global user.name "$GIT_AUTHOR_NAME"
git config --global user.email "$GIT_AUTHOR_EMAIL"

# Custom aliases
alias myproject="cd ~/path/to/project"
```

### Prompt Customization

The prompt shows:
- Current directory in blue
- Git branch with 🐶 emoji when in a repository
- `*` when there are uncommitted changes

To customize colors or symbols, edit the prompt configuration in:
- Bash: `.bash_prompt`
- Zsh: The PROMPT variable in `.zshrc`

## Updating

To update your dotfiles:

```bash
cd ~/.dotfiles
git pull origin master
./bootstrap.sh --force
```

## Compatibility

- **OS**: macOS, Linux
- **Shells**: bash, zsh
- **Vim**: 7.0+ (some plugins may require 8.0+)

## Credits

Originally inspired by [Mathias Bynens' dotfiles](https://github.com/mathiasbynens/dotfiles).

## License

MIT

# dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Quick Start

```bash
git clone git@github.com:eschnitzler/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Install system dependencies (Arch / Debian)
./packages.sh

# Interactively select which configs to stow (requires fzf)
./install.sh

# Or stow everything at once
./install.sh --all
```

## Structure

```
dotfiles/
├── stowables/          # Each subfolder is a stow module
│   ├── bash/           # .bashrc, .bash_aliases, .bash_functions
│   ├── btop/           # btop terminal monitor
│   ├── copilot/        # GitHub Copilot
│   ├── fish/           # Fish shell + completions
│   ├── gh/             # GitHub CLI
│   ├── git/            # .gitconfig, git-hotfix
│   ├── hypr/           # Hyprland (illogical-impulse overrides)
│   ├── kitty/          # Kitty terminal
│   ├── lazygit/        # Lazygit TUI
│   ├── nvim/           # Neovim (LazyVim)
│   ├── opencode/       # OpenCode AI config
│   ├── ptpython/       # ptpython REPL
│   └── starship/       # Starship prompt
├── lib/                # Shell helpers (center, spinner)
├── install.sh          # fzf-powered stow selector
├── packages.sh         # System package installer
└── .gitignore
```

## Usage

```bash
# List available modules
./install.sh --list

# Stow specific modules manually
stow -v -R -d stowables/ -t "$HOME" nvim fish git

# Install system packages then stow everything
./install.sh --packages --all
```

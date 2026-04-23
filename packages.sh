#!/usr/bin/env bash
set -euo pipefail

# ---------------------------------------------------------------------------
# System package installer — run once on a fresh machine
# Supports: Arch/Artix, Debian/Ubuntu, Fedora/RHEL
# ---------------------------------------------------------------------------

detect_os() {
  if [[ -f /etc/arch-release || -f /etc/artix-release ]]; then
    echo "arch"
  elif [[ -f /etc/fedora-release ]] || (grep -qi fedora /etc/os-release 2>/dev/null); then
    echo "fedora"
  elif [[ -f /etc/debian_version ]]; then
    echo "debian"
  else
    echo "unknown"
  fi
}

detect_arch() {
  local arch
  arch=$(uname -m)
  case "$arch" in
    x86_64)  echo "amd64" ;;
    aarch64) echo "arm64" ;;
    *)       echo "$arch" ;;
  esac
}

OS=$(detect_os)
ARCH=$(detect_arch)

echo "Detected OS: $OS ($(uname -m))"

# ---------------------------------------------------------------------------
# Arch
# ---------------------------------------------------------------------------
install_arch() {
  sudo pacman -S --noconfirm \
    btop \
    cargo \
    curl \
    entr \
    eza \
    fd \
    feh \
    ffmpeg \
    fish \
    fzf \
    git-delta \
    gnupg \
    grim \
    jq \
    kanshi \
    lazygit \
    less \
    libnotify \
    openssh \
    pass \
    python-pip \
    ripgrep \
    slurp \
    sshpass \
    starship \
    stow \
    swappy \
    tmux \
    wget \
    wl-clipboard \
    xclip

  # yay for AUR packages
  if ! command -v yay &>/dev/null; then
    echo "Installing yay (AUR helper)..."
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    (cd /tmp/yay && makepkg -si --noconfirm)
    rm -rf /tmp/yay
  fi
}

# ---------------------------------------------------------------------------
# Debian / Ubuntu
# ---------------------------------------------------------------------------
install_debian() {
  sudo apt update
  sudo apt install -y \
    btop \
    cargo \
    curl \
    entr \
    eza \
    fd-find \
    feh \
    ffmpeg \
    fish \
    fzf \
    gnupg \
    jq \
    less \
    libnotify-bin \
    openssh-client \
    python3-pip \
    ripgrep \
    sshpass \
    stow \
    tmux \
    wget \
    wl-clipboard \
    xclip

  # Symlink fd-find → fd
  mkdir -p "$HOME/.local/bin"
  if command -v fdfind &>/dev/null && [[ ! -L "$HOME/.local/bin/fd" ]]; then
    ln -svf "$(command -v fdfind)" "$HOME/.local/bin/fd"
  fi

  install_delta_binary
  install_starship_binary
  install_lazygit_binary
}

# ---------------------------------------------------------------------------
# Fedora / RHEL
# ---------------------------------------------------------------------------
install_fedora() {
  sudo dnf install -y \
    btop \
    cargo \
    curl \
    entr \
    eza \
    fd-find \
    feh \
    ffmpeg-free \
    fish \
    fzf \
    gnupg2 \
    jq \
    less \
    libnotify \
    openssh-clients \
    python3-pip \
    ripgrep \
    sshpass \
    stow \
    tmux \
    wget \
    wl-clipboard \
    xclip

  # Symlink fd → fd  (Fedora installs as 'fd' already, but just in case)
  if command -v fdfind &>/dev/null && ! command -v fd &>/dev/null; then
    mkdir -p "$HOME/.local/bin"
    ln -svf "$(command -v fdfind)" "$HOME/.local/bin/fd"
  fi

  install_delta_binary
  install_starship_binary
  install_lazygit_binary
}

# ---------------------------------------------------------------------------
# Binary installers (for distros without native packages)
# ---------------------------------------------------------------------------
install_delta_binary() {
  command -v delta &>/dev/null && return
  echo "Installing git-delta from GitHub releases..."
  local version
  version=$(curl -sS https://api.github.com/repos/dandavison/delta/releases/latest | grep tag_name | cut -d '"' -f 4)
  local deb_arch="$ARCH"

  if [[ "$OS" == "debian" ]]; then
    curl -Lo /tmp/delta.deb "https://github.com/dandavison/delta/releases/download/${version}/git-delta_${version}_${deb_arch}.deb"
    sudo dpkg -i /tmp/delta.deb
    rm -f /tmp/delta.deb
  else
    # Fedora / generic — use musl tarball
    local tar_arch
    case "$ARCH" in
      amd64) tar_arch="x86_64" ;;
      arm64) tar_arch="aarch64" ;;
      *)     tar_arch="$ARCH" ;;
    esac
    curl -Lo /tmp/delta.tar.gz "https://github.com/dandavison/delta/releases/download/${version}/delta-${version}-${tar_arch}-unknown-linux-musl.tar.gz"
    tar xf /tmp/delta.tar.gz -C /tmp
    sudo install "/tmp/delta-${version}-${tar_arch}-unknown-linux-musl/delta" /usr/local/bin/delta
    rm -rf /tmp/delta*
  fi
}

install_starship_binary() {
  command -v starship &>/dev/null && return
  echo "Installing starship..."
  curl -sS https://starship.rs/install.sh | sh -s -- --yes
}

install_lazygit_binary() {
  command -v lazygit &>/dev/null && return
  echo "Installing lazygit from GitHub releases..."
  local version tar_arch
  version=$(curl -sS https://api.github.com/repos/jesseduffield/lazygit/releases/latest | grep tag_name | cut -d '"' -f 4 | tr -d v)
  case "$ARCH" in
    amd64) tar_arch="x86_64" ;;
    arm64) tar_arch="arm64" ;;
    *)     tar_arch="$ARCH" ;;
  esac
  curl -Lo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${version}/lazygit_${version}_Linux_${tar_arch}.tar.gz"
  tar xf /tmp/lazygit.tar.gz -C /tmp lazygit
  sudo install /tmp/lazygit /usr/local/bin/lazygit
  rm -f /tmp/lazygit /tmp/lazygit.tar.gz
}

# ---------------------------------------------------------------------------
# Run
# ---------------------------------------------------------------------------
case "$OS" in
  arch)   install_arch ;;
  debian) install_debian ;;
  fedora) install_fedora ;;
  *)
    echo "Unsupported OS. Detected: $(cat /etc/os-release 2>/dev/null | head -1)"
    echo "Supported: Arch, Debian/Ubuntu, Fedora/RHEL"
    exit 1
    ;;
esac

echo ""
echo "System packages installed. Run ./install.sh to stow dotfiles."

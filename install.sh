#!/usr/bin/env bash
set -uo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STOWABLES_DIR="$DOTFILES_DIR/stowables"

source "$DOTFILES_DIR/lib/utils.shlib"

# ---------------------------------------------------------------------------
# Discover available stowables
# ---------------------------------------------------------------------------
mapfile -t ALL_STOWABLES < <(
  find "$STOWABLES_DIR" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort
)

if [[ ${#ALL_STOWABLES[@]} -eq 0 ]]; then
  echo "No stowables found in $STOWABLES_DIR"
  exit 1
fi

# ---------------------------------------------------------------------------
# CLI flags
# ---------------------------------------------------------------------------
usage() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Options:
  --all         Stow everything without prompting
  --adopt       Adopt existing files into the repo (moves real files into
                stowables/, replacing them with symlinks)
  --list        List available stowables and exit
  --packages    Install system packages first (calls packages.sh)
  -h, --help    Show this help
EOF
}

STOW_ALL=false
STOW_ADOPT=false
INSTALL_PACKAGES=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --all) STOW_ALL=true; shift ;;
    --adopt) STOW_ADOPT=true; shift ;;
    --list)
      printf '%s\n' "${ALL_STOWABLES[@]}"
      exit 0
      ;;
    --packages) INSTALL_PACKAGES=true; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1"; usage; exit 1 ;;
  esac
done

if [[ "$INSTALL_PACKAGES" == true ]]; then
  bash "$DOTFILES_DIR/packages.sh"
fi

# ---------------------------------------------------------------------------
# Select stowables
# ---------------------------------------------------------------------------
if [[ "$STOW_ALL" == true ]]; then
  SELECTED=("${ALL_STOWABLES[@]}")
else
  if ! command -v fzf &>/dev/null; then
    echo "fzf not found — install it first or use --all"
    exit 1
  fi

  mapfile -t SELECTED < <(
    printf '%s\n' "${ALL_STOWABLES[@]}" |
      fzf --multi \
          --prompt="Select stowables (TAB to toggle, ENTER to confirm): " \
          --header="Available dotfile modules" \
          --preview="ls -1 $STOWABLES_DIR/{}" \
          --height=60% --border --reverse
  )

  if [[ ${#SELECTED[@]} -eq 0 ]]; then
    echo "Nothing selected."
    exit 0
  fi
fi

# ---------------------------------------------------------------------------
# Pre-flight: ensure common parent directories exist
# ---------------------------------------------------------------------------
mkdir -p "$HOME/.config" "$HOME/.local/bin"

# ---------------------------------------------------------------------------
# Build stow flags
# ---------------------------------------------------------------------------
STOW_FLAGS=(-v --no-folding -d "$STOWABLES_DIR" -t "$HOME")

if [[ "$STOW_ADOPT" == true ]]; then
  echo ""
  echo "⚠  --adopt will MOVE existing files into stowables/ and replace them"
  echo "   with symlinks. Any local changes in those files become the repo version."
  echo ""
  read -rp "Continue? [y/N] " confirm
  if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
  fi
  STOW_FLAGS+=(--adopt)
else
  STOW_FLAGS+=(-R)
fi

# ---------------------------------------------------------------------------
# Stow selected modules (per-package error handling)
# ---------------------------------------------------------------------------
center "Stowing dotfiles"

FAILED=()
SUCCEEDED=()

for pkg in "${SELECTED[@]}"; do
  if output=$(stow "${STOW_FLAGS[@]}" "$pkg" 2>&1); then
    SUCCEEDED+=("$pkg")
    echo "  ✓ $pkg"
  else
    FAILED+=("$pkg")
    echo "  ✗ $pkg"
    echo "$output" | sed 's/^/    /'
  fi
done

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
echo ""
if [[ ${#FAILED[@]} -gt 0 ]]; then
  echo "Stowed ${#SUCCEEDED[@]}/${#SELECTED[@]} modules. Failed: ${FAILED[*]}"
  echo ""
  echo "Tips:"
  echo "  • Real files blocking?    → re-run with --adopt to absorb them"
  echo "  • Absolute symlinks?      → remove them and re-run (stow uses relative links)"
  echo "  • Other conflicts?        → remove the conflicting files manually"
  exit 1
else
  center "Done! Stowed ${#SUCCEEDED[@]} module(s): ${SUCCEEDED[*]}"
fi

# ---------------------------------------------------------------------------
# Post-stow: configure secrets from pass
# ---------------------------------------------------------------------------
setup_copilot() {
  local copilot_dir="$HOME/.config/github-copilot"
  local apps_json="$copilot_dir/apps.json"

  # Already configured
  [[ -f "$apps_json" ]] && return

  echo ""
  echo "Setting up GitHub Copilot token..."

  if ! command -v pass &>/dev/null; then
    echo "  ⚠ pass not installed. Skipping copilot token setup."
    echo "    Run :Copilot auth in Neovim to authenticate manually."
    return
  fi

  local token
  token=$(pass show copilot/oauth_token 2>/dev/null) || true

  if [[ -z "$token" ]]; then
    echo "  ⚠ No token found in pass at 'copilot/oauth_token'"
    echo ""
    echo "  To set up Copilot, either:"
    echo "    1. Run :Copilot auth in Neovim (easiest)"
    echo "    2. Store your token in pass for future installs:"
    echo "       pass insert copilot/oauth_token"
    return
  fi

  local github_user
  github_user=$(git config --global github.user 2>/dev/null || echo "")

  if [[ -z "$github_user" ]]; then
    echo "  ⚠ No github.user set in gitconfig. Set it with:"
    echo "    git config --global github.user YOUR_USERNAME"
    return
  fi

  local app_id="Iv1.b507a08c87ecfe98"
  mkdir -p "$copilot_dir"
  cat > "$apps_json" <<EOJSON
{"github.com:${app_id}":{"user":"${github_user}","oauth_token":"${token}","githubAppId":"${app_id}"}}
EOJSON
  chmod 600 "$apps_json"
  echo "  ✓ Copilot token configured from pass"
}

# Run post-stow hooks for stowed modules
for pkg in "${SUCCEEDED[@]}"; do
  case "$pkg" in
    copilot) setup_copilot ;;
  esac
done

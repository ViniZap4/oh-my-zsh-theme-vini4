#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── Detect package manager ─────────────────────────────────────────
detect_pm() {
  if command -v brew &>/dev/null; then echo "brew"
  elif command -v apt &>/dev/null; then echo "apt"
  elif command -v pacman &>/dev/null; then echo "pacman"
  elif command -v dnf &>/dev/null; then echo "dnf"
  elif command -v zypper &>/dev/null; then echo "zypper"
  elif command -v nix-env &>/dev/null; then echo "nix"
  else echo "unknown"
  fi
}

PM=$(detect_pm)
echo "→ Package Manager: $PM"

# ── Ensure zsh and curl are installed ─────────────────────────────
install_prerequisites() {
  local missing=()
  command -v zsh &>/dev/null || missing+=("zsh")
  command -v curl &>/dev/null || missing+=("curl")

  if [[ ${#missing[@]} -eq 0 ]]; then
    return
  fi

  echo "→ Installing: ${missing[*]}"
  case "$PM" in
    brew)   brew install "${missing[@]}" 2>/dev/null || true ;;
    apt)    sudo apt-get update -qq && sudo apt-get install -y "${missing[@]}" 2>/dev/null || true ;;
    pacman) sudo pacman -S --noconfirm --needed "${missing[@]}" 2>/dev/null || true ;;
    dnf)    sudo dnf install -y "${missing[@]}" 2>/dev/null || true ;;
    zypper) sudo zypper install -y "${missing[@]}" 2>/dev/null || true ;;
  esac
}

install_prerequisites

# ── Ensure Oh My Zsh is installed ─────────────────────────────────
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  echo "→ Oh My Zsh not found. Installing..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
  echo "→ Oh My Zsh already installed"
fi

# ── Create themes directory if needed ──────────────────────────────
THEMES_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes"
mkdir -p "$THEMES_DIR"

# ── Create symlink ────────────────────────────────────────────────
TARGET="$THEMES_DIR/vini4.zsh-theme"

if [[ -f "$TARGET" && ! -L "$TARGET" ]]; then
  BACKUP="${TARGET}.backup.$(date +%Y%m%d%H%M%S)"
  echo "→ Backing up existing $TARGET to $BACKUP"
  mv "$TARGET" "$BACKUP"
elif [[ -L "$TARGET" ]]; then
  rm "$TARGET"
fi

ln -s "${SCRIPT_DIR}/vini4.zsh-theme" "$TARGET"
echo "✔ Linked vini4.zsh-theme → $TARGET"

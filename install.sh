#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── Detect OS ──────────────────────────────────────────────────────
detect_os() {
  case "$(uname -s)" in
    Darwin) echo "macos" ;;
    Linux)
      if grep -qi microsoft /proc/version 2>/dev/null; then
        echo "wsl"
      else
        echo "linux"
      fi
      ;;
    *) echo "unknown" ;;
  esac
}

OS=$(detect_os)
echo "→ Detected OS: $OS"

# ── Ensure Oh My Zsh is installed ─────────────────────────────────
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  echo "→ Oh My Zsh not found. Installing..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
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

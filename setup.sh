#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

export HOMEBREW_NO_INTERACTIVE=1

cat << 'EOF'

███╗   ███╗ █████╗ ██████╗ ███╗   ███╗███████╗██╗      █████╗ ██████╗ ███████╗
████╗ ████║██╔══██╗██╔══██╗████╗ ████║██╔════╝██║     ██╔══██╗██╔══██╗██╔════╝
██╔████╔██║███████║██████╔╝██╔████╔██║█████╗  ██║     ███████║██║  ██║█████╗
██║╚██╔╝██║██╔══██║██╔══██╗██║╚██╔╝██║██╔══╝  ██║     ██╔══██║██║  ██║██╔══╝
██║ ╚═╝ ██║██║  ██║██║  ██║██║ ╚═╝ ██║███████╗███████╗██║  ██║██████╔╝███████╗
╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝╚══════╝╚═╝  ╚═╝╚═════╝ ╚══════╝

EOF

sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

install_pkg()  { brew list "$1" &>/dev/null 2>&1 && echo "$1 already installed." || { yes | brew install "${2:-$1}" && echo "$1 installed."; }; }
install_cask() { brew list --cask "$1" &>/dev/null 2>&1 && echo "$1 already installed." || { brew install --cask "$1" && echo "$1 installed."; }; }

echo "==> Checking Homebrew..."
if command -v brew &>/dev/null; then
  echo "Homebrew already installed: $(brew --version | head -1)"
else
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo "Homebrew installed."
fi

install_apps() {
  local header=$1; shift
  local csv selected
  csv=$(IFS=,; echo "$*")
  selected=$(printf '%s\n' "$@" | gum choose --no-limit --selected="$csv" --header "$header")
  while IFS= read -r app; do
    [[ -z "$app" ]] && continue
    case "$app" in
      neardrop)
        brew list neardrop &>/dev/null 2>&1 && echo "neardrop already installed." || {
          brew install grishka/grishka/neardrop
          sudo xattr -r -d com.apple.quarantine "/Applications/NearDrop.app"
          echo "NearDrop installed."
        }
        ;;
      borders) install_pkg borders FelixKratz/formulae/borders ;;
      sketchybar)        bash "$SCRIPT_DIR/scripts/install_sketchybar.sh" ;;
      smudge-nightlight) bash "$SCRIPT_DIR/scripts/install_smudge_nightlight.sh" ;;
      *) install_cask "$app" ;;

    esac
  done <<< "$selected"
}

PRODUCTIVITY=(zen keeper-password-manager slack linear obsidian onedrive microsoft-teams claude-code spotify)
DEVELOPMENT=(zed docker dbeaver-community ghostty openmtp keka)
UTILITIES=(notunes bluesnooze caffeine raycast neardrop ffmpeg hammerspoon borders sketchybar smudge-nightlight)

# ─── Apps ────────────────────────────────────────────────────────────────────

install_apps "Productivity" "${PRODUCTIVITY[@]}"
install_apps "Development" "${DEVELOPMENT[@]}"
install_apps "Utilities" "${UTILITIES[@]}"

# ─── CLI Tools ────────────────────────────────────────────────────────────────

echo "==> Development Packages"
DEV_PKGS=(yabai skhd-zig k9s git gh awscli just lazygit lazydocker openfortivpn hunk)
DEV_PKGS_CSV=$(IFS=,; echo "${DEV_PKGS[*]}")
SELECTED=$(printf '%s\n' "${DEV_PKGS[@]}" | gum choose --no-limit --selected="$DEV_PKGS_CSV" --header "Select dev packages to install:")

while IFS= read -r pkg; do
  [[ -z "$pkg" ]] && continue
  case "$pkg" in
    yabai)    install_pkg yabai asmvik/formulae/yabai ;;
    skhd-zig) install_pkg skhd-zig jackielii/tap/skhd-zig ;;
    hunk)     install_pkg hunk modem-dev/tap/hunk ;;
    git)
      install_pkg git
      if ! grep -q 'eval "$(/opt/homebrew/bin/brew shellenv)"' "$HOME/.zshrc" 2>/dev/null; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zshrc"
        echo "Brew shellenv added to ~/.zshrc."
      fi
      eval "$(/opt/homebrew/bin/brew shellenv)"
      ;;
    *)        install_pkg "$pkg" ;;
  esac
done <<< "$SELECTED"

# ─── macOS Defaults ──────────────────────────────────────────────────────────

bash "$SCRIPT_DIR/scripts/macos.sh"

# ─── Config ──────────────────────────────────────────────────────────────────

echo "==> Configuring Ghostty..."
mkdir -p "$HOME/.config/ghostty"
cp "$SCRIPT_DIR/config/ghostty/config" "$HOME/.config/ghostty/config"
echo "Ghostty configured."

echo "==> Configuring Zed settings..."
mkdir -p "$HOME/.config/zed"
cp "$SCRIPT_DIR/config/zed/settings.json" "$HOME/.config/zed/settings.json"
echo "Zed settings applied."

echo "==> Configuring yabai..."
mkdir -p "$HOME/.config/yabai"
cp "$SCRIPT_DIR/config/yabai/yabairc" "$HOME/.config/yabai/yabairc"
chmod +x "$HOME/.config/yabai/yabairc"
yabai --start-service
echo "yabai configured."

echo "==> Configuring skhd..."
mkdir -p "$HOME/.config/skhd"
cp "$SCRIPT_DIR/config/skhd/skhdrc" "$HOME/.config/skhd/skhdrc"

if ! skhd --check-grabber &>/dev/null 2>&1; then
  sudo skhd --install-grabber
fi
echo "skhd configured."

echo "==> Configuring borders..."
mkdir -p "$HOME/.config/borders"
cp "$SCRIPT_DIR/config/borders/bordersrc" "$HOME/.config/borders/bordersrc"
chmod +x "$HOME/.config/borders/bordersrc"
brew services start borders
echo "borders configured."

echo "==> Configuring openfortivpn..."
if [ ! -f "/opt/homebrew/etc/openfortivpn/openfortivpn/config" ]; then
    sudo cp "$SCRIPT_DIR/config/openfortivpn/config" /opt/homebrew/etc/openfortivpn/openfortivpn/config
    echo "openfortivpn configured."
else
    echo "openfortivpn already configured, skipping."
fi

echo "==> Remapping F4 Spotlight media key to standard F4 (for skhd)..."
mkdir -p "$HOME/Library/LaunchAgents"
cp "$SCRIPT_DIR/config/launchagents/com.user.hidutil.fkeys-remap.plist" "$HOME/Library/LaunchAgents/com.user.hidutil.fkeys-remap.plist"
launchctl bootout "gui/$(id -u)/com.user.hidutil.fkeys-remap" 2>/dev/null || true
launchctl bootstrap "gui/$(id -u)" "$HOME/Library/LaunchAgents/com.user.hidutil.fkeys-remap.plist" || true
# --set replaces the entire UserKeyMapping table, so keep all remaps in this one plist.
echo "F4 + F5 remap registered (takes effect on next login)."

echo "==> Setting wallpaper..."
osascript -e "tell application \"Finder\" to set desktop picture to POSIX file \"$SCRIPT_DIR/wallpaper/wallpaper.jpg\""
echo "Wallpaper set."

# ─── Git ─────────────────────────────────────────────────────────────────────

echo "==> Configuring git..."
git config --global --get push.autoSetupRemote &>/dev/null || git config --global push.autoSetupRemote true
git config --global --get pull.rebase         &>/dev/null || git config --global pull.rebase true
if command -v hunk &>/dev/null; then
  git config --global --get core.pager &>/dev/null || git config --global core.pager "hunk pager"
fi
echo "git configured."

# ─── Final ─────────────────────────────────────────────────────────────────────

install_pkg dockutil

echo "==> Removing Dock apps..."
dockutil --remove all --no-restart
killall Dock
killall ControlCenter

echo ""
echo "==> Done! Please restart your Mac for all changes to take effect."

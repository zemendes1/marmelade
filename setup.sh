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
      *) install_cask "$app" ;;
    esac
  done <<< "$selected"
}

PRODUCTIVITY=(zen keeper-password-manager slack linear obsidian onedrive microsoft-teams claude-code spotify)
DEVELOPMENT=(zed docker dbeaver-community ghostty openmtp keka)
UTILITIES=(notunes bluesnooze caffeine karabiner-elements raycast neardrop)

install_apps "Productivity" "${PRODUCTIVITY[@]}"
install_apps "Development" "${DEVELOPMENT[@]}"
install_apps "Utilities" "${UTILITIES[@]}"

# ─── Dev Utils ───────────────────────────────────────────────────────────────

echo "==> Development Packages"
DEV_PKGS=(yabai skhd-zig k9s git gh ffmpeg awscli just lazygit lazydocker)
DEV_PKGS_CSV=$(IFS=,; echo "${DEV_PKGS[*]}")
SELECTED=$(printf '%s\n' "${DEV_PKGS[@]}" | gum choose --no-limit --selected="$DEV_PKGS_CSV" --header "Select dev packages to install:")

while IFS= read -r pkg; do
  [[ -z "$pkg" ]] && continue
  case "$pkg" in
    yabai)    install_pkg yabai asmvik/formulae/yabai ;;
    skhd-zig) install_pkg skhd-zig jackielii/tap/skhd-zig ;;
    *)        install_pkg "$pkg" ;;
  esac
done <<< "$SELECTED"

# ─── Configs ─────────────────────────────────────────────────────────────────────

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

echo "==> Configuring Karabiner..."
mkdir -p "$HOME/.config/karabiner"
cp "$SCRIPT_DIR/config/karabiner/karabiner.json" "$HOME/.config/karabiner/karabiner.json"
echo "Karabiner configured."

echo "==> Setting wallpaper..."
osascript -e "tell application \"Finder\" to set desktop picture to POSIX file \"$SCRIPT_DIR/wallpaper/wallpaper.jpg\""
echo "Wallpaper set."

# ─── Dock ─────────────────────────────────────────────────────────────────────

install_pkg dockutil

echo "==> Configuring Dock..."
defaults write com.apple.dock launchanim -bool false
defaults write com.apple.dock autohide -bool true
defaults write com.apple.WindowManager StandardHideWidgets -int 1
defaults write com.apple.WindowManager EnableStandardClickToShowDesktop -bool false
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock mineffect -string "scale"
dockutil --remove all --no-restart
dockutil --add /Applications/Zen.app --no-restart
dockutil --add /Applications/Slack.app --no-restart
dockutil --add /Applications/Spotify.app --no-restart
dockutil --add /Applications/Obsidian.app --no-restart
dockutil --add /Applications/Linear.app --no-restart
dockutil --add /Applications/Docker.app --no-restart
dockutil --add /Applications/Ghostty.app --no-restart
dockutil --add /Applications/Zed.app --no-restart
dockutil --add /Applications/DBeaver.app --no-restart
dockutil --add /System/Applications/System\ Settings.app --no-restart
killall Dock
killall ControlCenter
echo "Dock configured."

echo "==> Enabling Dark Mode..."
osascript -e 'tell application "System Events" to tell appearance preferences to set dark mode to true'
echo "Dark Mode enabled."

echo "==> Configuring Lock Screen..."
defaults write com.apple.screensaver askForPassword -bool true
defaults write com.apple.screensaver askForPasswordDelay -int 0
echo "Lock Screen configured."

echo "==> Configuring Keyboard..."
if ! defaults read com.apple.HIToolbox AppleEnabledInputSources 2>/dev/null | grep -q "com.apple.keylayout.ABC"; then
  defaults write com.apple.HIToolbox AppleEnabledInputSources -array-add \
    '<dict><key>Bundle ID</key><string>com.apple.keylayout.ABC</string><key>InputSourceKind</key><string>Keyboard Layout</string><key>KeyboardLayout ID</key><integer>252</integer><key>KeyboardLayout Name</key><string>ABC</string></dict>'
fi
defaults write com.apple.TextInputMenu visible -bool true
echo "Keyboard configured."

echo "==> Configuring Login Items..."
for app in "Karabiner-Elements" "Caffeine" "Bluesnooze" "noTunes"; do
  osascript -e "tell application \"System Events\" to make login item at end with properties {path:\"/Applications/$app.app\", hidden:false}" >/dev/null 2>&1 || true
  echo "$app added to login items."
done
echo "Login Items configured."

echo ""
echo "==> Done! Please restart your Mac for all changes to take effect."

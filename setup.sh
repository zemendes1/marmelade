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

echo "==> Checking Homebrew..."
if command -v brew &>/dev/null; then
  echo "Homebrew already installed: $(brew --version | head -1)"
else
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo "Homebrew installed."
fi

for cask in zen keeper-password-manager slack claude-code linear zed spotify docker keka notunes bluesnooze obsidian dbeaver-community karabiner-elements caffeine openmtp raycast ghostty; do
  echo "==> Checking $cask..."
  if brew list --cask "$cask" &>/dev/null 2>&1; then
    echo "$cask already installed."
  else
    echo "Installing $cask..."
    brew install --cask "$cask"
    echo "$cask installed."
  fi
done

echo "==> Checking NearDrop..."
if brew list neardrop &>/dev/null 2>&1; then
  echo "NearDrop already installed."
else
  echo "Installing NearDrop..."
  brew install grishka/grishka/neardrop
  sudo xattr -r -d com.apple.quarantine "/Applications/NearDrop.app"
  echo "NearDrop installed."
fi

# ─── Microsoft ───────────────────────────────────────────────────────────────

for cask in onedrive microsoft-teams; do
  echo "==> Checking $cask..."
  if brew list --cask "$cask" &>/dev/null 2>&1; then
    echo "$cask already installed."
  else
    echo "Installing $cask..."
    brew install --cask "$cask"
    echo "$cask installed."
  fi
done

# ─── Dev Utils ───────────────────────────────────────────────────────────────

echo "==> Checking yabai..."
if brew list yabai &>/dev/null 2>&1; then
  echo "yabai already installed."
else
  echo "Installing yabai..."
  brew install asmvik/formulae/yabai
  echo "yabai installed."
fi

echo "==> Checking skhd-zig..."
if brew list skhd-zig &>/dev/null 2>&1; then
  echo "skhd-zig already installed."
else
  echo "Installing skhd-zig..."
  brew install jackielii/tap/skhd-zig
  echo "skhd-zig installed."
fi

for pkg in k9s git gh ffmpeg awscli just; do
  echo "==> Checking $pkg..."
  if brew list "$pkg" &>/dev/null 2>&1; then
    echo "$pkg already installed."
  else
    echo "Installing $pkg..."
    yes | brew install "$pkg"
    echo "$pkg installed."
  fi
done

# ─── Dock ─────────────────────────────────────────────────────────────────────

echo "==> Checking dockutil..."
if brew list dockutil &>/dev/null 2>&1; then
  echo "dockutil already installed."
else
  echo "Installing dockutil..."
  brew install dockutil
  echo "dockutil installed."
fi

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

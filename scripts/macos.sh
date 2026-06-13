#!/bin/bash

set -e

# ─── Dock ─────────────────────────────────────────────────────────────────────

echo "==> Configuring Dock..."
defaults write com.apple.dock launchanim -bool false
defaults write com.apple.dock autohide -bool true
defaults write com.apple.WindowManager StandardHideWidgets -int 1
defaults write com.apple.WindowManager EnableStandardClickToShowDesktop -bool false
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock mineffect -string "scale"
defaults write com.apple.dock workspaces-auto-swoosh -bool false
echo "Dock configured."

# ─── Spaces ───────────────────────────────────────────────────────────────────

echo "==> Disabling auto-rearrange Spaces..."
defaults write com.apple.dock mru-spaces -bool false
defaults write NSGlobalDomain AppleSpacesSwitchOnActivate -bool false
echo "Auto-rearrange Spaces disabled."

# ─── Keyboard ─────────────────────────────────────────────────────────────────

echo "==> Configuring Keyboard..."
if ! defaults read com.apple.HIToolbox AppleEnabledInputSources 2>/dev/null | grep -q "com.apple.keylayout.ABC"; then
  defaults write com.apple.HIToolbox AppleEnabledInputSources -array-add \
    '<dict><key>Bundle ID</key><string>com.apple.keylayout.ABC</string><key>InputSourceKind</key><string>Keyboard Layout</string><key>KeyboardLayout ID</key><integer>252</integer><key>KeyboardLayout Name</key><string>ABC</string></dict>'
fi
defaults write com.apple.TextInputMenu visible -bool true
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15
echo "Keyboard configured."

# ─── Hotkeys ──────────────────────────────────────────────────────────────────

echo "==> Disabling Spotlight shortcuts..."
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 64 '<dict><key>enabled</key><false/><key>value</key><dict><key>parameters</key><array><integer>65535</integer><integer>49</integer><integer>1048576</integer></array><key>type</key><string>standard</string></dict></dict>'
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 65 '<dict><key>enabled</key><false/><key>value</key><dict><key>parameters</key><array><integer>65535</integer><integer>49</integer><integer>1572864</integer></array><key>type</key><string>standard</string></dict></dict>'
echo "Spotlight shortcuts disabled."

echo "==> Disabling Launchpad (F4) shortcut..."
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 160 '<dict><key>enabled</key><false/><key>value</key><dict><key>parameters</key><array><integer>65535</integer><integer>118</integer><integer>0</integer></array><key>type</key><string>standard</string></dict></dict>'
echo "Launchpad shortcut disabled."

echo "==> Disabling Input Sources (language switching) shortcuts..."
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 60 '<dict><key>enabled</key><false/><key>value</key><dict><key>parameters</key><array><integer>65535</integer><integer>65535</integer><integer>0</integer></array><key>type</key><string>standard</string></dict></dict>'
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 61 '<dict><key>enabled</key><false/><key>value</key><dict><key>parameters</key><array><integer>65535</integer><integer>65535</integer><integer>0</integer></array><key>type</key><string>standard</string></dict></dict>'
echo "Input Sources shortcuts disabled."

# ─── Appearance ───────────────────────────────────────────────────────────────

echo "==> Enabling Dark Mode..."
osascript -e 'tell application "System Events" to tell appearance preferences to set dark mode to true'
echo "Dark Mode enabled."

# ─── Lock Screen ──────────────────────────────────────────────────────────────

echo "==> Configuring Lock Screen..."
defaults write com.apple.screensaver askForPassword -bool true
defaults write com.apple.screensaver askForPasswordDelay -int 0
echo "Lock Screen configured."

#!/bin/sh
## Applies the macOS preferences that differ from a fresh install. Log out and
## back in afterwards; the Dock and Finder restart at the end.
set -eu

here=$(cd "$(dirname "$0")" && pwd)

# MARK: Global
defaults write NSGlobalDomain AppleInterfaceStyle -string Dark
defaults write NSGlobalDomain AppleLocale -string en_AU
defaults write NSGlobalDomain AppleLanguages -array en-AU
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write NSGlobalDomain AppleMiniaturizeOnDoubleClick -bool false
defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 2
defaults write NSGlobalDomain com.apple.mouse.scaling -float 1.5

# MARK: Keyboard
# F1 to F12 act as function keys; the fn key alone does nothing.
defaults write NSGlobalDomain com.apple.keyboard.fnState -bool true
defaults write com.apple.HIToolbox AppleFnUsageType -int 2
# System shortcuts: ctrl+1 to ctrl+9 switch desktops, cmd+shift+4 copies a
# selection to the clipboard, and F11 and full-screen screenshots are off.
defaults import com.apple.symbolichotkeys "$here/symbolichotkeys.plist"

# MARK: Trackpad
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool false
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool false

# MARK: Dock and spaces
defaults write com.apple.dock autohide -bool false
defaults write com.apple.dock tilesize -int 38
defaults write com.apple.dock magnification -bool true
defaults write com.apple.dock largesize -int 72
defaults write com.apple.spaces spans-displays -bool false

# MARK: Window manager
# Stage Manager, click-to-show-desktop and edge tiling are off; yabai tiles.
defaults write com.apple.WindowManager GloballyEnabled -bool false
defaults write com.apple.WindowManager EnableStandardClickToShowDesktop -bool false
defaults write com.apple.WindowManager EnableTilingByEdgeDrag -bool false
defaults write com.apple.WindowManager EnableTiledWindowMargins -bool false

# MARK: Finder
defaults write com.apple.finder FXPreferredViewStyle -string Nlsv
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false

# MARK: Screenshots
defaults write com.apple.screencapture location -string /private/tmp

# MARK: KeyCastr
defaults write io.github.keycastr selectedVisualizer -string Svelte
defaults write io.github.keycastr mouse.displayOption -int 1

killall Dock Finder SystemUIServer 2>/dev/null || true

#!/bin/sh
## Applies the Rex app settings that live in the macOS preferences domain.
## Rex reads init.lua for key bindings only; fonts, layout and themes are
## stored in com.superlogical.rex, which the app rewrites at runtime, so they
## are written here instead of being linked. Quit Rex before running.
set -eu

domain=com.superlogical.rex
here=$(cd "$(dirname "$0")" && pwd)

# MARK: Terminal
defaults write "$domain" Workspace.terminalFontName -string "Fira Code"
defaults write "$domain" Workspace.terminalFontPointSize -int 12
defaults write "$domain" Workspace.terminalAllowsLigatures -bool true
defaults write "$domain" Workspace.terminalFontSmoothing -bool true
defaults write "$domain" Workspace.terminalSmoothScrolling -bool true

# MARK: Layout
defaults write "$domain" Workspace.tabStyle -string vertical
defaults write "$domain" Workspace.tabIconTintMode -string off
defaults write "$domain" Workspace.sidebarPosition -string left
defaults write "$domain" Workspace.sidebarWidth -int 207
defaults write "$domain" Workspace.sidebarShowsActivity -bool false
defaults write "$domain" Workspace.activityGrouping -string priority
defaults write "$domain" Workspace.paneDensity -string comfortable
defaults write "$domain" Workspace.animationStyle -string snappy
defaults write "$domain" Workspace.inactivePaneFadeMode -string both

# MARK: Themes
# Workspace.customThemes holds a JSON array as raw bytes. The dark theme ID
# refers to the "Ayu" entry in themes/custom.json.
defaults write "$domain" Workspace.customThemes -data "$(jq -c . "$here/themes/custom.json" | xxd -p | tr -d '\n')"
defaults write "$domain" Workspace.interfaceStyle -string useTheme
defaults write "$domain" Workspace.lightThemeID -string merino-light
defaults write "$domain" Workspace.darkThemeID -string custom-C3032526-94D7-44E2-A822-F5AB56D1DAAA

# MARK: Agents and server
defaults write "$domain" rex.agents.names-sessions -bool false
defaults write "$domain" rex.server.run-mode -string bundled
defaults write "$domain" rex.server.automatic-restart-enabled -bool true

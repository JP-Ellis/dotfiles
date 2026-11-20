# macOS setup

Dotter deploys nothing from this directory. Run the pieces by hand on a new Mac.

- `defaults.sh` writes the system preferences that differ from a fresh install. It imports `symbolichotkeys.plist`, the export of System Settings → Keyboard → Keyboard Shortcuts.
- `fstab.nas` is the NFS entry for the NAS. Add it with `sudo vifs`. The rustic repository path `/mnt/nas/rustic` depends on this mount.
- `../brew/Brewfile` lists taps, formulae and casks. Install with `brew bundle --file brew/Brewfile`. Refresh with `brew bundle dump --file brew/Brewfile --force --tap --formula --cask`.
- `../rex/defaults.sh` writes the Rex app settings and custom theme.

The tap `jp-ellis/local` is a local directory at `$(brew --repository)/Library/Taps/jp-ellis/homebrew-local`. Its formulae `ffmpeg-tritium.rb` and `svt-av1-tritium.rb` are symlinks into the `HomebrewFormula/` directories of the `FFmpeg/FFmpeg` and `Uranite/svt-av1-tritium` checkouts under `~/src`.

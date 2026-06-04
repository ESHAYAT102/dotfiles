# These dotfiles are being used with [archon](https://github.com/ESHAYAT102/archon)

## XDPH Screen-Share Picker

`config/hypr/xdph.conf` points `custom_picker_binary` at
`~/.local/bin/xdph-no-picker`, a no-op picker that exits with status `1`.
This makes unwanted `xdg-desktop-portal-hyprland` screencast requests fail
silently instead of opening the `Windows / Outputs / Region` chooser.

To restore normal screen sharing, set `custom_picker_binary` back to
`hyprland-preview-share-picker` and restart:

```bash
systemctl --user restart xdg-desktop-portal-hyprland.service xdg-desktop-portal.service
```

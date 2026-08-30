# Hide Icons for Omarchy

A compact Omarchy top-bar overflow controller. It collapses selected bar
widgets behind one button and reveals their real bar slots to its left when
clicked.

The controlled widgets are not copied or reparented. They remain ordinary
Omarchy bar entries, so their settings, tooltips, popups, IPC routes, and
per-monitor behavior continue to work normally.

## Requirements

- Omarchy Quattro
- Selected widgets must be in the same bar section as Hide Icons
- Each selected widget ID should be unique within that section
- The configured center-anchor widget cannot be hidden

No external packages or background processes are required.

## Security and configuration

Omarchy plugins run unsandboxed inside the long-running shell process. Hide
Icons does not run external commands, access the network, start services, or
request elevated privileges. Dragging a widget onto or out of the controller
updates only the `items` setting on this plugin's existing bar entry through
Omarchy's shell configuration API.

## Install

Install through Omarchy's plugin manager:

```sh
omarchy plugin add https://github.com/ESHAYAT102/hide-icons-omarchy-plugin.git --enable
```

## Configure

Keep Hide Icons and every controlled widget as entries in the same section of
`~/.config/omarchy/shell.json`. Place the controller immediately before the
widgets so they reveal beside its button:

```json
{
  "version": 1,
  "bar": {
    "layout": {
      "right": [
        {
          "id": "esh.hide-icons",
          "items": [
            "omarchy.bluetooth",
            "omarchy.network",
            "omarchy.audio",
            "omarchy.monitor"
          ]
        },
        "omarchy.bluetooth",
        "omarchy.network",
        "omarchy.audio",
        "omarchy.monitor",
        "omarchy.power"
      ]
    }
  }
}
```

The `items` setting also accepts a comma-separated string:

```json
{
  "id": "esh.hide-icons",
  "items": "omarchy.bluetooth, omarchy.network, omarchy.audio"
}
```

You can update an existing instance from the command line:

```sh
omarchy bar set esh.hide-icons items \
  '["omarchy.bluetooth","omarchy.network","omarchy.audio"]' --json
```

## Usage

- Left-click the Hide Icons button to reveal or collapse the configured widgets.
- Drag any visible bar widget onto the Hide Icons button to add it to the group.
- Dropped widgets are placed immediately to the left of the Hide Icons button.
- Reveal the group and drag one of its widgets elsewhere on the bar to remove
  it from the group.
- Opening a configured widget through a keyboard shortcut or IPC reveals its
  slot automatically.
- Collapsing the group closes an open popup owned by one of its widgets.
- Each monitor keeps its own expanded or collapsed state.

## Remove

```sh
omarchy plugin remove esh.hide-icons
```

The plugin restores managed slots before unloading. The original widget
entries and settings remain in `shell.json` and become visible again.

## Development

Validate the plugin from the repository root:

```sh
omarchy plugin validate .
qmllint -I "$OMARCHY_PATH/shell" BarWidget.qml
```

The plugin must pass `omarchy plugin validate` before installation or
publication. The lint command requires Qt's `qmllint` executable to be on
`PATH`.

## Compatibility

Omarchy does not currently expose a public API for grouping arbitrary bar
widgets. Hide Icons uses the bar's live module-slot and drag registries rather
than duplicating widgets. This preserves behavior but depends on Omarchy
Quattro's current `moduleSlots`, `barDragSource`, `barDragTarget`, `slotWindow`,
and `sameWindow` bar APIs.

## License

MIT. See [LICENSE](LICENSE).

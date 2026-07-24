import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import qs.Commons
import qs.Ui
import "LauncherSearch.js" as LauncherSearch

Item {
  id: root

  property string omarchyPath: Quickshell.env("OMARCHY_PATH")
  property var shell: null
  property var manifest: null

  property bool opened: false
  property string placeholder: "\uf002 Search..."
  property string filterText: ""
  property int selectedIndex: 0
  property bool cursorActive: true
  property var filteredEntries: []
  property int launchSerial: 0
  property int launchToplevelCount: 0
  property var launchActiveToplevel: null
  property bool launchOsdOpen: false
  property string launchOsdMessage: ""
  property var configuredHiddenEntryIds: ({})
  property var desktopHiddenEntryIds: ({})
  property bool deleteConfirmOpen: false
  property var deleteEntry: null

  // Maps an icon name to a file on disk (e.g. "omacut" -> ".../apps/omacut.svg").
  // Used as a fallback for icons that Qt's themed lookup misses because they were
  // installed after this process started (its icon cache never re-scans). Refreshed
  // whenever the app list changes, so newly installed apps get their icon live.
  property var iconIndex: ({})
  property var pendingIconIndex: ({})

  // Match the Omarchy menu surface.
  property color background: Color.menu.background
  property color foreground: Color.menu.text
  property color border: Color.popups.border
  property var borderSpec: Border.localOrSurfaceSpec("popups", "border", border, Color.popups.border, Math.max(1, Style.space(2)))
  property color scrim: "transparent"
  property color selectedBackground: Color.menu.selectedBackground
  property color selectedText: Color.menu.selectedText
  property color selectedBorder: Color.menu.selectedBorder
  property var selectedBorderSpec: Border.surfaceSpec("menu", "selected-border", selectedBorder, 0)
  property string fontFamily: Style.font.menuFamily

  property int cardWidth: 760
  property int cardHeight: 520
  property int contentMargin: 20
  property int contentSpacing: 10
  property int searchHeight: 44
  property int gridColumns: 5
  property int gridCellHeight: 112
  property int iconSize: 56

  function open(payloadJson) {
    var payload = ({})
    try { payload = JSON.parse(payloadJson || "{}") } catch (e) { payload = ({}) }

    root.placeholder = payload.placeholder || "\uf002 Search..."
    root.cardWidth = Math.max(300, Number(payload.width || 760))
    var requestedListHeight = Number(payload.listHeight || payload.maxHeight || 0)
    root.cardHeight = requestedListHeight > 0
      ? root.contentMargin * 2 + root.searchHeight + root.contentSpacing + requestedListHeight
      : 520

    root.filterText = payload.query || ""
    root.selectedIndex = 0
    root.cursorActive = true
    root.disarmHover()
    root.opened = true
    root.rebuildDisplay()
    // The shell may start before first-install packages have finished placing
    // their icons. Refresh here even when the desktop entry list did not change.
    if (!iconIndexScan.running) iconIndexScan.running = true
    Qt.callLater(function() { keyCatcher.forceActiveFocus() })
  }

  function close() {
    root.opened = false
  }

  function dismiss() {
    root.deleteConfirmOpen = false
    root.deleteEntry = null
    root.opened = false
    if (root.shell && typeof root.shell.hide === "function")
      root.shell.hide((root.manifest && root.manifest.id) || "omarchy.launcher")
  }

  function iconSource(icon) {
    var value = String(icon || "")
    if (value.length === 0) return Quickshell.iconPath("application-x-executable", true)
    if (value.indexOf("file://") === 0 || value.indexOf("image://") === 0) return value
    if (value.charAt(0) === "/") return Util.fileUrl(value)
    // Prefer the context-limited app/device index. An unconstrained themed
    // lookup can resolve an app name such as "zoom" to an action icon instead.
    var found = root.iconIndex[value]
    if (found) return Util.fileUrl(found)
    var themed = Quickshell.iconPath(value, true)
    if (themed.length > 0) return themed
    return Quickshell.iconPath("application-x-executable", true)
  }

  function entryName(entry) {
    return LauncherSearch.entryName(entry)
  }

  function entrySubtext(entry) {
    return LauncherSearch.entrySubtext(entry)
  }

  function entrySortKey(entry) {
    return LauncherSearch.entrySortKey(entry)
  }

  function toplevelCount() {
    try { return ToplevelManager.toplevels.values.length } catch (e) { return 0 }
  }

  function entrySearchText(entry) {
    return LauncherSearch.entrySearchText(entry)
  }

  function disarmHover() {
    pointerGate.reset()
  }

  function selectFromPointer(index, item, mouse) {
    if (!pointerGate.moved(item, mouse)) return
    root.cursorActive = true
    root.selectedIndex = index
  }

  function isHiddenEntry(entry) {
    var id = String((entry && entry.id) || "")
    return root.configuredHiddenEntryIds[id] === true || root.desktopHiddenEntryIds[id] === true
  }

  function normalizeDesktopId(id) {
    var value = String(id || "").trim()
    if (value.slice(-8) === ".desktop") value = value.slice(0, -8)
    return value
  }

  function loadConfiguredHides(rawText) {
    var next = ({})
    var lines = String(rawText || "").split(/\n/)
    for (var i = 0; i < lines.length; i++) {
      var id = root.normalizeDesktopId(lines[i])
      if (id.length > 0) next[id] = true
    }
    root.configuredHiddenEntryIds = next
    if (root.opened) root.rebuildDisplay()
  }

  function loadDesktopHiddenEntries(rawText) {
    var next = ({})
    var lines = String(rawText || "").split(/\n/)
    for (var i = 0; i < lines.length; i++) {
      var id = root.normalizeDesktopId(lines[i])
      if (id.length > 0) next[id] = true
    }
    root.desktopHiddenEntryIds = next
    if (root.opened) root.rebuildDisplay()
  }

  function iconIndexScanCommand() {
    // List app/device icons across the XDG icon dirs and /usr/share/pixmaps as
    // "<path>" lines. Some desktop entries, such as Print Settings, use device
    // icons like "printer" instead of app icons. SVGs are emitted before PNGs
    // so the parser, which keeps the first hit per name, prefers scalable icons.
    return [
      'dirs="$HOME/.icons $HOME/.local/share/icons";',
      'IFS=":"; for d in ${XDG_DATA_DIRS:-/usr/local/share:/usr/share}; do dirs="$dirs $d/icons"; done; unset IFS;',
      'for ext in svg png; do',
      '  for base in $dirs; do',
      '    [[ -d $base ]] && find "$base" \\( -path "*/apps/*" -o -path "*/devices/*" \\) -name "*.$ext" 2>/dev/null;',
      '  done;',
      '  find /usr/share/pixmaps -maxdepth 1 -name "*.$ext" 2>/dev/null;',
      'done'
    ].join(' ')
  }

  function indexIconLine(path) {
    var value = String(path || "").trim()
    if (value.length === 0) return
    var slash = value.lastIndexOf("/")
    var file = slash >= 0 ? value.slice(slash + 1) : value
    var dot = file.lastIndexOf(".")
    var name = dot > 0 ? file.slice(0, dot) : file
    if (name.length > 0 && root.pendingIconIndex[name] === undefined)
      root.pendingIconIndex[name] = value
  }

  function hiddenEntryScanCommand() {
    var desktop = [Quickshell.env("XDG_CURRENT_DESKTOP"), Quickshell.env("XDG_SESSION_DESKTOP"), Quickshell.env("DESKTOP_SESSION")].filter(function(v) { return String(v || "").length > 0 }).join(":")
    var script = root.omarchyPath + "/shell/plugins/launcher/hidden-entries.sh"
    return Util.shellQuote(script) + " " + Util.shellQuote(desktop)
  }

  function fuzzyScore(entry, query) {
    return LauncherSearch.fuzzyScore(entry, query)
  }

  function sortedEntries(query) {
    var values = DesktopEntries.applications.values || []
    return LauncherSearch.sortedEntries(values, query, function(entry) { return root.isHiddenEntry(entry) })
  }

  function rebuildDisplay() {
    displayModel.clear()
    var rows = root.sortedEntries(root.filterText)
    var entries = []
    var count = Math.min(rows.length, 256)
    for (var i = 0; i < count; i++) {
      var entry = rows[i].entry
      entries.push(entry)
      displayModel.append({
        name: root.entryName(entry),
        subtext: root.entrySubtext(entry),
        icon: String(entry.icon || "")
      })
    }
    root.filteredEntries = entries

    if (displayModel.count === 0) root.selectedIndex = 0
    else if (root.selectedIndex >= displayModel.count) root.selectedIndex = displayModel.count - 1
    else if (root.selectedIndex < 0) root.selectedIndex = 0

    Qt.callLater(function() {
      if (displayModel.count > 0) resultList.positionViewAtIndex(root.selectedIndex, GridView.Contain)
    })
  }

  function setFilter(nextFilter) {
    root.filterText = nextFilter
    root.selectedIndex = 0
    root.cursorActive = true
    root.disarmHover()
    root.rebuildDisplay()
  }

  function select(delta) {
    if (displayModel.count === 0) return
    root.cursorActive = true
    root.disarmHover()
    root.selectedIndex = Math.max(0, Math.min(displayModel.count - 1, root.selectedIndex + delta))
    resultList.positionViewAtIndex(root.selectedIndex, GridView.Contain)
  }

  function activateIndex(index) {
    if (root.deleteConfirmOpen) return
    if (index < 0 || index >= root.filteredEntries.length) return
    var entry = root.filteredEntries[index]
    if (!entry) return
    var desktopId = String(entry.id || "")
    if (!desktopId) return

    root.beginLaunchFeedback(entry)
    root.dismiss()
    Util.execDetached("gtk-launch " + Util.shellQuote(desktopId))
  }

  function requestDeleteIndex(index) {
    if (index < 0 || index >= root.filteredEntries.length) return
    var entry = root.filteredEntries[index]
    if (!entry) return
    root.deleteEntry = entry
    deleteConfirm.selectedIndex = 1
    root.deleteConfirmOpen = true
  }

  function cancelDelete() {
    root.deleteConfirmOpen = false
    root.deleteEntry = null
    deleteConfirm.selectedIndex = 1
    root.disarmHover()
    Qt.callLater(function() { keyCatcher.forceActiveFocus() })
  }

  function confirmDelete() {
    var entry = root.deleteEntry
    if (!entry) return

    var desktopId = String(entry.id || "")
    var name = root.entryName(entry)
    var command = Util.shellQuote(root.omarchyPath + "/bin/omarchy-remove-launcher-entry") + " " + Util.shellQuote(desktopId) + " " + Util.shellQuote(name)
    root.dismiss()
    Util.execDetached(command)
  }

  function beginLaunchFeedback(entry) {
    root.launchSerial++
    root.launchToplevelCount = root.toplevelCount()
    root.launchActiveToplevel = ToplevelManager.activeToplevel
    root.launchOsdOpen = false
    root.launchOsdMessage = "Launching " + root.entryName(entry) + "…"
    launchDelay.restart()
    launchTimeout.restart()
  }

  function closeLaunchFeedback(serial) {
    if (serial !== root.launchSerial) return
    launchDelay.stop()
    launchTimeout.stop()
    if (root.launchOsdOpen) {
      Quickshell.execDetached(["omarchy-shell", "osd", "close"])
      root.launchOsdOpen = false
    }
  }

  function maybeFinishLaunchFeedback() {
    if (!launchDelay.running && !launchTimeout.running && !root.launchOsdOpen) return
    if (root.toplevelCount() <= root.launchToplevelCount && ToplevelManager.activeToplevel === root.launchActiveToplevel) return
    root.closeLaunchFeedback(root.launchSerial)
  }

  ListModel { id: displayModel }

  Process {
    id: hiddenEntryScan
    command: ["bash", "-lc", root.hiddenEntryScanCommand()]
    stdout: SplitParser { onRead: function(line) { hiddenEntryOutput.text += line + "\n" } }
    onStarted: hiddenEntryOutput.text = ""
    onExited: root.loadDesktopHiddenEntries(hiddenEntryOutput.text)
  }

  Process {
    id: iconIndexScan
    command: ["bash", "-lc", root.iconIndexScanCommand()]
    stdout: SplitParser { onRead: function(line) { root.indexIconLine(line) } }
    onStarted: root.pendingIconIndex = ({})
    // Swapping the property re-evaluates every iconSource() binding, so
    // newly found icons appear without rebuilding the list.
    onExited: root.iconIndex = root.pendingIconIndex
  }

  // Coalesces bursts of app-list changes (a package install touches many
  // entries) into a single rescan.
  Timer {
    id: iconIndexDebounce
    interval: 750
    onTriggered: if (!iconIndexScan.running) iconIndexScan.running = true
  }

  QtObject {
    id: hiddenEntryOutput
    property string text: ""
  }

  FileView {
    id: launcherHidesFile
    path: root.omarchyPath + "/default/omarchy/launcher.hides"
    watchChanges: true
    printErrors: false
    onLoaded: root.loadConfiguredHides(text())
    onFileChanged: root.loadConfiguredHides(text())
    onLoadFailed: root.loadConfiguredHides("")
  }

  PointerMoveGate {
    id: pointerGate
    referenceItem: card
  }

  Connections {
    target: ToplevelManager.toplevels
    function onValuesChanged() { root.maybeFinishLaunchFeedback() }
  }

  Connections {
    target: ToplevelManager
    function onActiveToplevelChanged() { root.maybeFinishLaunchFeedback() }
  }

  Timer {
    id: launchDelay
    interval: 2000
    onTriggered: {
      if (root.toplevelCount() > root.launchToplevelCount || ToplevelManager.activeToplevel !== root.launchActiveToplevel) return
      root.launchOsdOpen = true
      Quickshell.execDetached(["omarchy-shell", "osd", "show", JSON.stringify({ icon: "󱓞", message: root.launchOsdMessage, duration: 0 })])
    }
  }

  Timer {
    id: launchTimeout
    interval: 15000
    onTriggered: root.closeLaunchFeedback(root.launchSerial)
  }

  Connections {
    target: DesktopEntries.applications
    function onValuesChanged() {
      hiddenEntryScan.running = true
      iconIndexDebounce.restart()
      if (root.opened) root.rebuildDisplay()
    }
  }

  Component.onCompleted: {
    hiddenEntryScan.running = true
    iconIndexScan.running = true
  }

  PanelWindow {
    id: panel
    visible: root.opened
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    WlrLayershell.namespace: "omarchy-launcher"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    exclusionMode: ExclusionMode.Ignore

    Rectangle {
      anchors.fill: parent
      color: root.scrim
    }

    MouseArea {
      anchors.fill: parent
      onClicked: root.dismiss()
    }

    BorderSurface {
      id: card
      width: Math.min(root.cardWidth, panel.width - Style.gapsOut * 2)
      height: Math.min(root.cardHeight, panel.height - Style.gapsOut * 2)
      radius: Style.cornerRadius
      anchors.centerIn: parent
      color: root.background
      borderSpec: root.borderSpec
      padding: root.contentMargin
      clip: true

      MouseArea { anchors.fill: parent; onClicked: {} }

      Item {
        id: keyCatcher
        anchors.fill: parent
        z: root.deleteConfirmOpen ? 20 : 0
        focus: true

        Keys.priority: Keys.BeforeItem
        Keys.onPressed: function(event) {
          if (root.deleteConfirmOpen) {
            if (deleteConfirm.handleKey(event)) event.accepted = true
            return
          }

          if (event.key === Qt.Key_Escape) {
            if (root.filterText.length > 0) root.setFilter("")
            else root.dismiss()
            event.accepted = true
          } else if (Util.editsFilter(event, root.filterText)) {
            root.setFilter(Util.editedFilter(event, root.filterText))
            event.accepted = true
          } else if (event.key === Qt.Key_Up) {
            root.select(-root.gridColumns)
            event.accepted = true
          } else if (event.key === Qt.Key_Down) {
            root.select(root.gridColumns)
            event.accepted = true
          } else if (event.key === Qt.Key_Left) {
            root.select(-1)
            event.accepted = true
          } else if (event.key === Qt.Key_Right) {
            root.select(1)
            event.accepted = true
          } else if (event.key === Qt.Key_PageUp) {
            root.select(-root.gridColumns * 3)
            event.accepted = true
          } else if (event.key === Qt.Key_PageDown) {
            root.select(root.gridColumns * 3)
            event.accepted = true
          } else if (event.key === Qt.Key_Home) {
            if (displayModel.count > 0) {
              root.cursorActive = true
              root.disarmHover()
              root.selectedIndex = 0
              resultList.positionViewAtIndex(root.selectedIndex, GridView.Contain)
            }
            event.accepted = true
          } else if (event.key === Qt.Key_End) {
            if (displayModel.count > 0) {
              root.cursorActive = true
              root.disarmHover()
              root.selectedIndex = displayModel.count - 1
              resultList.positionViewAtIndex(root.selectedIndex, GridView.Contain)
            }
            event.accepted = true
          } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            root.activateIndex(root.selectedIndex)
            event.accepted = true
          } else if (event.key === Qt.Key_Delete) {
            root.requestDeleteIndex(root.selectedIndex)
            event.accepted = true
          } else if (event.text && event.text.length === 1 && event.text.charCodeAt(0) >= 32 && event.text.charCodeAt(0) !== 127 && (event.modifiers === Qt.NoModifier || event.modifiers === Qt.ShiftModifier)) {
            root.setFilter(root.filterText + event.text)
            event.accepted = true
          }
        }

        ConfirmDialog {
          id: deleteConfirm

          anchors.fill: parent
          opened: root.deleteConfirmOpen
          z: 10
          message: "Do you want to uninstall " + root.entryName(root.deleteEntry) + "?"
          confirmText: "Uninstall"
          background: root.background
          foreground: root.foreground
          scrim: root.scrim
          selectedBackground: root.selectedBackground
          selectedText: root.selectedText
          fontFamily: root.fontFamily
          cornerRadius: Style.cornerRadius
          onCanceled: root.cancelDelete()
          onConfirmed: root.confirmDelete()
        }
      }

      Column {
        anchors.fill: parent
        anchors.topMargin: card.contentTopInset
        anchors.rightMargin: card.contentRightInset
        anchors.bottomMargin: card.contentBottomInset
        anchors.leftMargin: card.contentLeftInset
        spacing: root.contentSpacing

        Rectangle {
          width: parent.width
          height: root.searchHeight
          radius: 0
          color: root.background

          Text {
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            text: root.filterText || root.placeholder
            color: root.foreground
            opacity: root.filterText ? 1 : 0.5
            font.family: root.fontFamily
            font.pixelSize: 18
            elide: Text.ElideRight
          }
        }

        Item {
          width: parent.width
          height: parent.height - root.searchHeight - root.contentSpacing

          GridView {
            id: resultList
            anchors.fill: parent
            model: displayModel
            clip: true
            cellWidth: width / root.gridColumns
            cellHeight: root.gridCellHeight
            boundsBehavior: Flickable.StopAtBounds

            delegate: Item {
              id: cell
              required property int index
              required property string name
              required property string subtext
              required property string icon

              readonly property bool hasCursor: root.cursorActive && cell.index === root.selectedIndex
              width: resultList.cellWidth
              height: resultList.cellHeight

              BorderSurface {
                id: tile
                anchors.fill: parent
                anchors.margins: 4
                radius: Style.cornerRadius
                color: cell.hasCursor ? root.selectedBackground : "transparent"
                borderSpec: cell.hasCursor ? root.selectedBorderSpec : Border.none()

                Image {
                  id: appIcon
                  anchors.top: parent.top
                  anchors.topMargin: 10
                  anchors.horizontalCenter: parent.horizontalCenter
                  width: root.iconSize
                  height: root.iconSize
                  fillMode: Image.PreserveAspectFit
                  // Decode at physical pixels: IconImage uses the logical size,
                  // which leaves PNG icons upscaled and blurry on HiDPI displays.
                  sourceSize.width: root.iconSize * Screen.devicePixelRatio
                  sourceSize.height: root.iconSize * Screen.devicePixelRatio
                  source: root.iconSource(cell.icon)
                  asynchronous: true
                }

                Text {
                  anchors.centerIn: appIcon
                  visible: appIcon.status === Image.Error
                  text: "?"
                  color: cell.hasCursor ? root.selectedText : root.foreground
                  font.family: root.fontFamily
                  font.pixelSize: 24
                }

                Text {
                  anchors.top: appIcon.bottom
                  anchors.topMargin: 7
                  anchors.left: parent.left
                  anchors.leftMargin: 6
                  anchors.right: parent.right
                  anchors.rightMargin: 6
                  horizontalAlignment: Text.AlignHCenter
                  text: cell.name
                  color: cell.hasCursor ? root.selectedText : root.foreground
                  font.family: root.fontFamily
                  font.pixelSize: 14
                  elide: Text.ElideRight
                }

                MouseArea {
                  id: mouseArea
                  anchors.fill: parent
                  hoverEnabled: true
                  cursorShape: Qt.PointingHandCursor
                  onEntered: root.selectFromPointer(cell.index, tile, {
                    x: mouseArea.mouseX,
                    y: mouseArea.mouseY
                  })
                  onPositionChanged: function(mouse) {
                    root.selectFromPointer(cell.index, tile, mouse)
                  }
                  onClicked: {
                    root.cursorActive = true
                    root.selectedIndex = cell.index
                    root.activateIndex(cell.index)
                  }
                }
              }
            }
          }

          Text {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.leftMargin: 14
            visible: displayModel.count === 0
            text: "No Results"
            color: root.foreground
            font.family: root.fontFamily
            font.pixelSize: 18
          }
        }
      }
    }
  }
}

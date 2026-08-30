import QtQuick
import qs.Commons
import qs.Ui

BarWidget {
  id: root

  moduleName: "esh.hide-icons"

  property bool expanded: false
  property bool collapseWhenPopoutCloses: false
  property bool dropArmed: false
  property var pendingDragSource: null
  property string pendingDragId: ""
  property bool pendingDragWasManaged: false
  property var managedStates: []

  readonly property var configuredIds: parseConfiguredIds(setting("items", []))
  readonly property int hiddenCount: managedStates.length
  readonly property bool hasConfiguredItems: configuredIds.length > 0
  readonly property bool hasManagedItems: hiddenCount > 0
  readonly property color themeAccent: Color.flatColor(
    Color.pick("popups.border", Color.accent), Color.accent)

  function canonicalId(value) {
    var id = String(value || "").trim()
    if (bar && typeof bar.canonicalWidgetId === "function") return bar.canonicalWidgetId(id)
    return id
  }

  function parseConfiguredIds(value) {
    var source = []
    if (typeof value === "string") source = value.split(",")
    else if (value && typeof value.length === "number") source = value

    var ids = []
    for (var i = 0; i < source.length; i++) {
      var item = source[i]
      var rawId = item && typeof item === "object" ? item.id : item
      var id = canonicalId(rawId)
      if (id && id !== canonicalId(root.moduleName) && ids.indexOf(id) === -1) ids.push(id)
    }
    return ids
  }

  function ownSlot() {
    if (!bar || !bar.moduleSlots) return null
    for (var i = 0; i < bar.moduleSlots.length; i++) {
      var slot = bar.moduleSlots[i]
      if (slot && slot.activeItem === root) return slot
    }
    return null
  }

  function targetSlots() {
    var ownerSlot = ownSlot()
    if (!ownerSlot || !bar || !bar.moduleSlots) return []
    var ownerWindow = typeof bar.slotWindow === "function" ? bar.slotWindow(ownerSlot) : null
    if (!ownerWindow) return []
    var result = []

    for (var i = 0; i < bar.moduleSlots.length; i++) {
      var slot = bar.moduleSlots[i]
      if (!slot || slot === ownerSlot || !slot.activeItem) continue
      if (slot.region !== ownerSlot.region) continue
      if (configuredIds.indexOf(canonicalId(slot.moduleName)) === -1) continue
      if (slot.region === "center"
          && canonicalId(slot.moduleName) === canonicalId(bar.centerAnchor)) continue
      var slotWindow = typeof bar.slotWindow === "function" ? bar.slotWindow(slot) : null
      if (!slotWindow || (typeof bar.sameWindow === "function"
          && !bar.sameWindow(ownerWindow, slotWindow))) continue
      result.push(slot)
    }
    return result
  }

  function stateForSlot(slot) {
    for (var i = 0; i < managedStates.length; i++) {
      if (managedStates[i].slot === slot) return managedStates[i]
    }
    return null
  }

  function restoreState(state) {
    try {
      if (!state || !state.slot) return
      state.slot.visible = state.originalVisible
    } catch (error) {
      // A bar layout reload may already have destroyed this slot.
    }
  }

  function syncManagedSlots() {
    var targets = targetSlots()
    var next = []

    for (var i = 0; i < managedStates.length; i++) {
      var oldState = managedStates[i]
      if (!oldState || targets.indexOf(oldState.slot) === -1) restoreState(oldState)
    }

    for (var j = 0; j < targets.length; j++) {
      var slot = targets[j]
      var state = stateForSlot(slot)
      if (!state) state = { slot: slot, originalVisible: slot.visible }
      next.push(state)
    }

    managedStates = next
    var revealForPopout = root.managesItem(bar.activePopout)
    if (revealForPopout && !root.expanded)
      Qt.callLater(root.revealForActivePopout)

    for (var k = 0; k < managedStates.length; k++) {
      var state = managedStates[k]
      try {
        state.slot.visible = root.expanded || revealForPopout
      } catch (error) {
      }
    }
  }

  function restoreManagedSlots() {
    for (var i = 0; i < managedStates.length; i++) restoreState(managedStates[i])
    managedStates = []
  }

  function settingsWithItems(ids) {
    var next = {}
    for (var key in settings) {
      if (key !== "id" && key !== "items") next[key] = settings[key]
    }
    next.items = ids
    return next
  }

  function persistConfiguredIds(ids) {
    if (!bar || !bar.shell || typeof bar.shell.updateEntryInline !== "function") return false
    return bar.shell.updateEntryInline(root.moduleName, settingsWithItems(ids))
  }

  function addConfiguredId(id) {
    var canonical = canonicalId(id)
    if (!canonical || canonical === canonicalId(root.moduleName)) return
    var ids = configuredIds.slice()
    if (ids.indexOf(canonical) === -1) ids.push(canonical)
    persistConfiguredIds(ids)
  }

  function removeConfiguredId(id) {
    var canonical = canonicalId(id)
    var ids = configuredIds.filter(function(item) { return item !== canonical })
    if (ids.length !== configuredIds.length) persistConfiguredIds(ids)
  }

  function managesSlot(slot) {
    if (!slot) return false
    for (var i = 0; i < managedStates.length; i++) {
      if (managedStates[i] && managedStates[i].slot === slot) return true
    }
    return false
  }

  function dragWasReleased(source) {
    try {
      if (!source || !source.children) return false
      for (var i = 0; i < source.children.length; i++) {
        var child = source.children[i]
        if (child && "suppressClick" in child && "dragging" in child)
          return child.suppressClick === true
      }
    } catch (error) {
    }
    return false
  }

  function beginDrag(source) {
    pendingDragSource = source
    pendingDragId = source ? canonicalId(source.moduleName) : ""
    pendingDragWasManaged = managesSlot(source)
    dropArmed = bar && bar.barDragTarget === ownSlot()
    if (dropArmed) bar.barDragAfter = false
  }

  function finishDrag() {
    var completed = dragWasReleased(pendingDragSource)
    var id = pendingDragId
    var wasManaged = pendingDragWasManaged
    var target = bar ? bar.barDragTarget : null
    var droppedOnController = !!target && target === ownSlot()
    var droppedElsewhere = !!target && !droppedOnController

    pendingDragSource = null
    pendingDragId = ""
    pendingDragWasManaged = false
    dropArmed = false

    if (!completed || !id || id === canonicalId(root.moduleName)) return
    if (droppedOnController) root.addConfiguredId(id)
    else if (wasManaged && droppedElsewhere) root.removeConfiguredId(id)
  }

  function managesItem(item) {
    if (!item) return false
    for (var i = 0; i < managedStates.length; i++) {
      var state = managedStates[i]
      if (state && state.slot && root.itemBelongsToSlot(item, state.slot)) return true
    }
    return false
  }

  function itemBelongsToSlot(item, slot) {
    if (!item || !slot || !slot.activeItem) return false
    var current = item
    for (var i = 0; current && i < 24; i++) {
      if (current === slot.activeItem) return true
      current = current.parent
    }
    return "opened" in slot.activeItem && slot.activeItem.opened === true
  }

  function collapse() {
    root.collapseWhenPopoutCloses = false
    var popout = bar ? bar.activePopout : null
    if (managesItem(popout)) {
      if (typeof popout.closeForPopoutSwitch === "function") popout.closeForPopoutSwitch()
      else if (typeof popout.close === "function") popout.close()
    }
    root.expanded = false
  }

  function revealForActivePopout() {
    if (!root.bar || !root.managesItem(root.bar.activePopout)) return
    if (!root.expanded) {
      root.collapseWhenPopoutCloses = true
      root.expanded = true
    }
  }

  function handleActivePopoutChanged() {
    if (root.bar && root.managesItem(root.bar.activePopout)) {
      root.revealForActivePopout()
      return
    }
    if (!root.collapseWhenPopoutCloses) return

    Qt.callLater(function() {
      if (!root.collapseWhenPopoutCloses) return
      if (root.bar && root.managesItem(root.bar.activePopout)) return
      root.collapse()
    })
  }

  function toggle() {
    if (!root.hasManagedItems) return
    if (root.expanded) root.collapse()
    else root.expanded = true
  }

  function tooltip() {
    if (root.dropArmed && root.pendingDragId)
      return "Drop " + root.pendingDragId + " here to hide it"
    if (!root.hasConfiguredItems) return "Hide Icons: configure widget IDs"
    if (!root.hasManagedItems) return "Hide Icons: place configured widgets beside this item"
    return root.expanded
      ? "Hide " + root.hiddenCount + " bar widget" + (root.hiddenCount === 1 ? "" : "s")
      : "Show " + root.hiddenCount + " hidden widget" + (root.hiddenCount === 1 ? "" : "s")
  }

  onExpandedChanged: syncManagedSlots()
  onConfiguredIdsChanged: Qt.callLater(syncManagedSlots)
  onBarChanged: Qt.callLater(syncManagedSlots)
  Component.onCompleted: Qt.callLater(syncManagedSlots)
  Component.onDestruction: restoreManagedSlots()

  Connections {
    target: root.bar

    function onModuleSlotsChanged() {
      Qt.callLater(root.syncManagedSlots)
    }

    function onBarDragTargetChanged() {
      root.dropArmed = !!root.bar.barDragSource && root.bar.barDragTarget === root.ownSlot()
      if (root.dropArmed) root.bar.barDragAfter = false
    }

    function onBarDragAfterChanged() {
      if (root.bar.barDragSource && root.bar.barDragTarget === root.ownSlot()
          && root.bar.barDragAfter)
        root.bar.barDragAfter = false
    }

    function onBarDragSourceChanged() {
      if (root.bar.barDragSource) root.beginDrag(root.bar.barDragSource)
      else root.finishDrag()
    }

    function onActivePopoutChanged() {
      root.handleActivePopoutChanged()
    }
  }

  Instantiator {
    model: root.bar && root.bar.moduleSlots ? root.bar.moduleSlots : []

    delegate: Connections {
      required property var modelData
      target: modelData

      function onActiveItemChanged() {
        Qt.callLater(root.syncManagedSlots)
      }
    }
  }

  implicitWidth: trigger.implicitWidth
  implicitHeight: trigger.implicitHeight

  BarIconButton {
    id: trigger

    anchors.fill: parent
    bar: root.bar
    iconComponent: Component {
      Item {
        id: glyphRoot

        readonly property int renderedFontSize: Math.max(1, Math.round(trigger.fontSize))
        readonly property real tightWidth: Math.max(1, glyphMetrics.tightBoundingRect.width)
        readonly property real horizontalCorrection: glyph.implicitWidth / 2
          - (glyphMetrics.tightBoundingRect.x + tightWidth / 2)

        TextMetrics {
          id: glyphMetrics
          font.family: trigger.fontFamily
          font.pixelSize: glyphRoot.renderedFontSize
          text: String(root.setting("icon", "\uf141"))
        }

        Text {
          id: glyph
          anchors.centerIn: parent
          anchors.horizontalCenterOffset: glyphRoot.horizontalCorrection
          text: String(root.setting("icon", "\uf141"))
          textFormat: Text.PlainText
          color: trigger.active && trigger.useActiveColor
            ? trigger.activeColor : trigger.foreground
          font.family: trigger.fontFamily
          font.pixelSize: glyphRoot.renderedFontSize
          renderType: Text.NativeRendering
          rotation: trigger.textRotation
        }
      }
    }
    active: root.expanded || root.dropArmed
    activeColor: root.themeAccent
    dimmed: !root.hasManagedItems
    tooltipText: root.tooltip()

    onPressed: function(button) {
      if (button === Qt.LeftButton) root.toggle()
    }
  }
}

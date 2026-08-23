import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Commons
import qs.Services.UI
import qs.Widgets

// Fullscreen overlay that positions an NPopupContextMenu at the cursor.
// Cross-compositor — relies on standard wl_pointer hover events delivered
// by any Wayland compositor (Hyprland, Niri, Sway, ...). No hyprctl.
PanelWindow {
  id: root

  required property ShellScreen screen
  property var pluginApi: null
  property var menuItems: []

  signal actionSelected(string action)
  signal cancelled

  property bool _menuShown: false

  anchors.top: true
  anchors.left: true
  anchors.right: true
  anchors.bottom: true
  visible: false
  color: "transparent"

  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
  WlrLayershell.namespace: "noctalia-plugin-manager-add-to-bar-" + (screen?.name || "unknown")
  WlrLayershell.exclusionMode: ExclusionMode.Ignore

  function show(items) {
    menuItems = items || []
    _menuShown = false
    visible = true
    // Fallback: show menu after 300 ms even if no pointer event arrives
    // (e.g. cursor outside screen). Normally the first wl_pointer.enter or
    // wl_pointer.motion reaching cursorArea fires _showMenuAtCursor sooner.
    fallbackTimer.restart()
  }

  function close() {
    fallbackTimer.stop()
    _menuShown = false
    visible = false
    contextMenu.visible = false
  }

  function _showMenuAtCursor() {
    if (_menuShown || !visible) return
    _menuShown = true
    fallbackTimer.stop()
    anchorPoint.x = cursorArea.mouseX
    anchorPoint.y = cursorArea.mouseY
    contextMenu.model = root.menuItems
    contextMenu.anchorItem = anchorPoint
    contextMenu.visible = true
  }

  Timer {
    id: fallbackTimer
    interval: 300
    repeat: false
    onTriggered: root._showMenuAtCursor()
  }

  NPopupContextMenu {
    id: contextMenu
    visible: false
    screen: root.screen
    minWidth: 200

    onTriggered: (action, item) => {
      root.actionSelected(action)
      root.close()
    }
  }

  Item {
    id: anchorPoint
    width: 1
    height: 1
    x: 0
    y: 0
  }

  MouseArea {
    id: cursorArea
    anchors.fill: parent
    hoverEnabled: true
    acceptedButtons: Qt.LeftButton | Qt.RightButton

    onEntered: root._showMenuAtCursor()
    onPositionChanged: mouse => root._showMenuAtCursor()

    onClicked: mouse => {
      root.cancelled()
      root.close()
    }
  }

  Component.onDestruction: {
    close()
  }
}

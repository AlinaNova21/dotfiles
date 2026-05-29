import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons

Item {
  id: root
  property var pluginApi: null

  // First AddToBarMenu instance, captured from the per-screen Variants delegate.
  property var addToBarMenu: null

  // State for the pending add-to-bar request
  property string _pendingPluginId: ""
  property string _pendingPluginName: ""
  property var _onAddToBarAction: null

  // Called by InstalledTabContent when the user clicks the "+" button on a plugin.
  // onAction(pluginId, section, pluginName) runs when user picks left/center/right.
  function showAddToBarMenu(pluginId, pluginName, onAction) {
    if (!pluginApi || !addToBarMenu) return
    _pendingPluginId = pluginId
    _pendingPluginName = pluginName
    _onAddToBarAction = onAction
    addToBarMenu.show([
      { "label": pluginApi.tr("panel.add-to-bar-left"),   "action": "left",   "icon": "align-left" },
      { "label": pluginApi.tr("panel.add-to-bar-center"), "action": "center", "icon": "align-center" },
      { "label": pluginApi.tr("panel.add-to-bar-right"),  "action": "right",  "icon": "align-right" }
    ])
  }

  IpcHandler {
    target: "plugin:plugin-manager"

    function toggle() {
      if (pluginApi) {
        pluginApi.withCurrentScreen(screen => {
          pluginApi.togglePanel(screen);
        });
      }
    }
  }

  Variants {
    model: Quickshell.screens

    delegate: AddToBarMenu {
      required property var modelData

      screen: modelData
      pluginApi: root.pluginApi

      Component.onCompleted: {
        if (!root.addToBarMenu) {
          root.addToBarMenu = this
        }
      }

      onActionSelected: action => {
        if (root._onAddToBarAction) {
          root._onAddToBarAction(root._pendingPluginId, action, root._pendingPluginName)
        }
        root._pendingPluginId = ""
        root._pendingPluginName = ""
        root._onAddToBarAction = null
      }

      onCancelled: {
        root._pendingPluginId = ""
        root._pendingPluginName = ""
        root._onAddToBarAction = null
      }
    }
  }

  Component.onDestruction: {
    _pendingPluginId = ""
    _pendingPluginName = ""
    _onAddToBarAction = null
  }
}

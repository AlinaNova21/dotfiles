import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Commons
import qs.Services.Noctalia
import qs.Services.UI
import qs.Widgets

ColumnLayout {
  id: root
  spacing: Style.marginL
  Layout.fillWidth: true

  property var pluginApi: null
  property string selectedPluginId: ""
  signal pluginSelected(string pluginId)

  // Track which plugins are currently updating
  property var updatingPlugins: ({})
  property int installedPluginsRefreshCounter: 0
  property string pluginSearchText: ""

  // Plugin id targeted by the add-to-bar context menu (set on click, read on action)
  property string _addToBarPluginId: ""

  // Add a plugin's bar widget to the given section on the current panel screen.
  // Mirrors the core Settings.Bar → MonitorWidgetsConfig._addWidgetToSection flow.
  function _addPluginToBar(pluginId, section, pluginName) {
    if (!pluginApi) return
    var screen = pluginApi.panelOpenScreen
    if (!screen || !screen.name) return
    var screenName = screen.name
    var widgetId = "plugin:" + pluginId

    var currentWidgets = Settings.getBarWidgetsForScreen(screenName)
    var widgets = {
      "left": [],
      "center": [],
      "right": []
    }
    try {
      widgets.left = JSON.parse(JSON.stringify(currentWidgets.left || []))
      widgets.center = JSON.parse(JSON.stringify(currentWidgets.center || []))
      widgets.right = JSON.parse(JSON.stringify(currentWidgets.right || []))
    } catch (e) {
      Logger.w("PluginManager", "Failed to clone bar widgets:", e)
    }

    var sections = ["left", "center", "right"]
    for (var s = 0; s < sections.length; s++) {
      var arr = widgets[sections[s]]
      for (var i = 0; i < arr.length; i++) {
        if (arr[i] && arr[i].id === widgetId) {
          var alreadyMsg = pluginApi.tr("panel.already-on-bar", { plugin: pluginName || pluginId })
          ToastService.showNotice(pluginApi.tr("panel.title"), alreadyMsg)
          return
        }
      }
    }

    var newWidget = { "id": widgetId }
    var meta = BarWidgetRegistry.pluginWidgetMetadata ? BarWidgetRegistry.pluginWidgetMetadata[widgetId] : null
    if (meta) {
      Object.keys(meta).forEach(function (key) {
        if (key !== "id") newWidget[key] = meta[key]
      })
    }

    if (!widgets[section]) widgets[section] = []
    widgets[section].push(newWidget)

    Settings.setScreenOverride(screenName, "widgets", widgets)
    BarService.widgetsRevision++

    var successMsg = pluginApi.tr("panel.add-to-bar-success", { plugin: pluginName || pluginId })
    ToastService.showNotice(pluginApi.tr("panel.title"), successMsg)
  }

  function stripAuthorEmail(author) {
    if (!author) return "";
    var lastBracket = author.lastIndexOf("<");
    if (lastBracket >= 0) {
      return author.substring(0, lastBracket).trim();
    }
    return author;
  }

  // Check for updates when tab becomes visible
  onVisibleChanged: {
    if (visible && PluginService.pluginsFullyLoaded) {
      PluginService.checkForUpdates();
    }
  }

  // Uninstall confirmation dialog
  Popup {
    id: uninstallDialog
    parent: Overlay.overlay
    modal: true
    dim: false
    anchors.centerIn: parent
    width: Math.round(400 * Style.uiScaleRatio)
    padding: Style.marginL

    property var pluginToUninstall: null

    background: Rectangle {
      color: Color.mSurface
      radius: Style.radiusS
      border.color: Color.mPrimary
      border.width: Style.borderM
    }

    contentItem: ColumnLayout {
      width: parent.width
      spacing: Style.marginL

      NHeader {
        label: pluginApi?.tr("panel.uninstall-dialog-title")
        description: {
          if (!pluginApi) return ""
          return pluginApi.tr("panel.uninstall-dialog-description", { plugin: uninstallDialog.pluginToUninstall?.name || "" })
        }
      }

      RowLayout {
        spacing: Style.marginM
        Layout.fillWidth: true

        Item {
          Layout.fillWidth: true
        }

        NButton {
          text: pluginApi?.tr("panel.cancel")
          onClicked: uninstallDialog.close()
        }

        NButton {
          text: pluginApi?.tr("panel.uninstall")
          backgroundColor: Color.mPrimary
          textColor: Color.mOnPrimary
          onClicked: {
            if (uninstallDialog.pluginToUninstall) {
              root.uninstallPlugin(uninstallDialog.pluginToUninstall.compositeKey);
              uninstallDialog.close();
            }
          }
        }
      }
    }
  }

  // Plugin settings popup
  NPluginSettingsPopup {
    id: pluginSettingsDialog
    parent: Overlay.overlay
    showToastOnSave: true
  }

  // Plugin name paired with _addToBarPluginId (kept for external call-backs)
  property var _addToBarPluginName: ""

  function uninstallPlugin(pluginId) {
    var manifest = PluginRegistry.getPluginManifest(pluginId);
    var pluginName = manifest?.name || pluginId;

    BarService.widgetsRevision++;

    if (!pluginApi) return;
    var title = pluginApi.tr("panel.title")
    var msg = pluginApi.tr("panel.uninstalling", { plugin: pluginName })
    ToastService.showNotice(title, msg);

    PluginService.uninstallPlugin(pluginId, function (success, error) {
      if (!pluginApi) return;
      if (success) {
        var successMsg = pluginApi.tr("panel.uninstall-success", { plugin: pluginName })
        ToastService.showNotice(title, successMsg);
      } else {
        var errorMsg = pluginApi.tr("panel.uninstall-error", { error: error || pluginApi.tr("panel.unknown-error") })
        ToastService.showError(title, errorMsg);
      }
    });
  }

  // Listen to plugin registry changes
  Connections {
    target: PluginRegistry

    function onPluginsChanged() {
      root.installedPluginsRefreshCounter++;
    }
  }

  // Auto-update toggle
  NToggle {
    label: pluginApi?.tr("panel.auto-update")
    description: pluginApi?.tr("panel.auto-update-description")
    checked: Settings.data.plugins.autoUpdate
    onToggled: checked => Settings.data.plugins.autoUpdate = checked
  }

  // Check for updates button
  NButton {
    property bool isChecking: Object.keys(PluginService.activeFetches).length > 0

    text: pluginApi?.tr("panel.refresh")
    icon: "refresh"
    enabled: !isChecking
    visible: Object.keys(PluginService.pluginUpdates).length === 0
    Layout.fillWidth: true
    onClicked: PluginService.checkForUpdates()
  }

  // Update All button
  NButton {
    property int updateCount: Object.keys(PluginService.pluginUpdates).length
    property bool isUpdating: false

    text: pluginApi?.tr("panel.update-all")
    icon: "download"
    visible: (updateCount > 0)
    enabled: !isUpdating
    backgroundColor: Color.mPrimary
    textColor: Color.mOnPrimary
    Layout.fillWidth: true
    onClicked: {
      isUpdating = true;
      var pluginIds = Object.keys(PluginService.pluginUpdates);
      var currentIndex = 0;

      function updateNext() {
        if (currentIndex >= pluginIds.length) {
          isUpdating = false;
          return;
        }

        var pluginId = pluginIds[currentIndex];
        currentIndex++;

        PluginService.updatePlugin(pluginId, function (success, error) {
          if (!success) {
            Logger.w("PluginManager", "Failed to update", pluginId + ":", error);
          }
          Qt.callLater(updateNext);
        });
      }

      updateNext();
    }
  }

  // Search input
  NTextInput {
    placeholderText: I18n.tr("placeholders.search")
    inputIconName: "search"
    text: root.pluginSearchText
    onTextChanged: root.pluginSearchText = text
    Layout.fillWidth: true
  }

  // Installed plugins list
  ColumnLayout {
    spacing: Style.marginM
    Layout.fillWidth: true

    Repeater {
      id: installedPluginsRepeater

      model: {
        void (root.installedPluginsRefreshCounter);

        var allIds = PluginRegistry.getAllInstalledPluginIds();
        var plugins = [];
        for (var i = 0; i < allIds.length; i++) {
          var compositeKey = allIds[i];
          var manifest = PluginRegistry.getPluginManifest(compositeKey);
          if (manifest) {
            var pluginData = JSON.parse(JSON.stringify(manifest));
            pluginData.compositeKey = compositeKey;
            pluginData.updateInfo = PluginService.pluginUpdates[compositeKey];
            pluginData.pendingUpdateInfo = PluginService.pluginUpdatesPending[compositeKey];
            pluginData.enabled = PluginRegistry.isPluginEnabled(compositeKey);

            var parsed = PluginRegistry.parseCompositeKey(compositeKey);
            pluginData.isFromOfficialRepo = parsed.isOfficial;
            if (!parsed.isOfficial) {
              pluginData.sourceName = PluginRegistry.getSourceNameByHash(parsed.sourceHash);
            }

            pluginData.official = false;
            pluginData.lastUpdated = null;
            var availablePlugins = PluginService.availablePlugins || [];
            for (var j = 0; j < availablePlugins.length; j++) {
              if (availablePlugins[j].id === manifest.id) {
                pluginData.official = availablePlugins[j].official === true;
                pluginData.lastUpdated = availablePlugins[j].lastUpdated || null;
                break;
              }
            }

            plugins.push(pluginData);
          }
        }

        // Apply fuzzy search
        var query = root.pluginSearchText.trim();
        if (query !== "") {
          var results = FuzzySort.go(query, plugins, {
            "keys": ["name", "description"],
            "limit": 50
          });
          var out = [];
          for (var k = 0; k < results.length; k++) {
            out.push(results[k].obj);
          }
          return out;
        }

        return plugins;
      }

      delegate: NBox {
        Layout.fillWidth: true
        Layout.leftMargin: Style.borderS
        Layout.rightMargin: Style.borderS
        implicitHeight: Math.round(contentColumn.implicitHeight + Style.margin2L)
        color: modelData.compositeKey === root.selectedPluginId ? Color.mHover : Color.mSurface

        MouseArea {
          anchors.fill: parent
          propagateComposedEvents: true
          cursorShape: Qt.PointingHandCursor
          onClicked: mouse => {
            root.pluginSelected(modelData.compositeKey)
            mouse.accepted = false
          }
        }

        ColumnLayout {
          id: contentColumn
          anchors.fill: parent
          anchors.margins: Style.marginL
          spacing: Style.marginS

          // Row 1: icon, name, badge
          RowLayout {
            spacing: Style.marginM
            Layout.fillWidth: true

            NIcon {
              icon: "plugin"
              pointSize: Style.fontSizeL
              color: PluginService.hasPluginError(modelData.compositeKey) ? Color.mError : Color.mPrimary
            }

            NText {
              text: modelData.name
              color: Color.mPrimary
              elide: Text.ElideRight
              Layout.fillWidth: true
            }

            // Official badge
            Rectangle {
              visible: modelData.official === true
              color: Color.mSecondary
              radius: Style.radiusXS
              implicitWidth: officialBadgeRow.implicitWidth + Style.margin2S
              implicitHeight: officialBadgeRow.implicitHeight + Style.margin2XS

              RowLayout {
                id: officialBadgeRow
                anchors.centerIn: parent
                spacing: Style.marginXS

                NIcon {
                  icon: "official-plugin"
                  pointSize: Style.fontSizeXXS
                  color: Color.mOnSecondary
                }

                NText {
                  text: pluginApi?.tr("panel.official")
                  font.pointSize: Style.fontSizeXXS
                  font.weight: Style.fontWeightMedium
                  color: Color.mOnSecondary
                }
              }
            }
          }

          // Row 2: action buttons left, toggle right
          RowLayout {
            spacing: Style.marginXS
            Layout.fillWidth: true

            NIconButtonHot {
              icon: "bug"
              hot: PluginService.isPluginHotReloadEnabled(modelData.id)
              tooltipText: pluginApi?.tr("panel.hot-reload")
              baseSize: Style.baseWidgetSize * 0.7
              onClicked: PluginService.togglePluginHotReload(modelData.id)
              visible: Settings.isDebug
            }

            NIconButton {
              id: addToBarBtn
              icon: "plus"
              tooltipText: pluginApi?.tr("panel.add-to-bar")
              baseSize: Style.baseWidgetSize * 0.7
              visible: (modelData.entryPoints?.barWidget !== undefined)
              enabled: modelData.enabled
              onClicked: {
                var rootRef = root
                var pid = modelData.id
                var pname = modelData.name
                var main = pluginApi?.mainInstance
                if (!main) return
                main.showAddToBarMenu(pid, pname, function (chosenId, chosenAction, chosenName) {
                  rootRef._addPluginToBar(chosenId, chosenAction, chosenName)
                })
              }
            }

            NIconButton {
              icon: "settings"
              tooltipText: pluginApi?.tr("panel.open-settings")
              baseSize: Style.baseWidgetSize * 0.7
              visible: (modelData.entryPoints?.settings !== undefined)
              enabled: modelData.enabled
              onClicked: {
                pluginSettingsDialog.openPluginSettings(modelData);
              }
            }

            NIconButton {
              icon: "external-link"
              tooltipText: pluginApi?.tr("panel.open-plugin-page")
              baseSize: Style.baseWidgetSize * 0.7
              onClicked: {
                var sourceUrl = PluginRegistry.getPluginSourceUrl(modelData.compositeKey) || "";
                Qt.openUrlExternally(sourceUrl && !PluginRegistry.isMainSource(sourceUrl) ? sourceUrl : "https://noctalia.dev/plugins/" + modelData.id);
              }
            }

            NIconButton {
              icon: "trash"
              tooltipText: pluginApi?.tr("panel.uninstall")
              baseSize: Style.baseWidgetSize * 0.7
              onClicked: {
                uninstallDialog.pluginToUninstall = modelData;
                uninstallDialog.open();
              }
            }

            NButton {
              id: updateButton
              property string pluginId: modelData.compositeKey
              property bool isUpdating: root.updatingPlugins[pluginId] === true

              text: pluginApi?.tr("panel.update")
              icon: isUpdating ? "" : "download"
              visible: modelData.updateInfo !== undefined
              enabled: !isUpdating
              backgroundColor: Color.mPrimary
              textColor: Color.mOnPrimary
              fontSize: Style.fontSizeXXS
              fontWeight: Style.fontWeightMedium
              onClicked: {
                var pid = pluginId;
                var pname = modelData.name;
                var pversion = modelData.updateInfo?.availableVersion || "";
                var rootRef = root;
                var updates = Object.assign({}, rootRef.updatingPlugins);
                updates[pid] = true;
                rootRef.updatingPlugins = updates;

                PluginService.updatePlugin(pid, function (success, error) {
                  var updates2 = Object.assign({}, rootRef.updatingPlugins);
                  updates2[pid] = false;
                  rootRef.updatingPlugins = updates2;

                  var api = rootRef.pluginApi;
                  if (!api) return;
                  if (success) {
                    var title = api.tr("panel.title")
                    var msg = api.tr("panel.install-success", { plugin: pname })
                    ToastService.showNotice(title, msg);
                  } else {
                    var title2 = api.tr("panel.title")
                    var errMsg = api.tr("panel.install-error", { error: error || api.tr("panel.unknown-error") })
                    ToastService.showError(title2, errMsg);
                  }
                });
              }
            }

            Item { Layout.fillWidth: true }

            NToggle {
              checked: modelData.enabled
              baseSize: Style.baseWidgetSize * 0.7
              onToggled: checked => {
                if (checked) {
                  PluginService.enablePlugin(modelData.compositeKey);
                } else {
                  PluginService.disablePlugin(modelData.compositeKey);
                }
              }
            }
          }

          // Description
          NText {
            visible: modelData.description
            text: modelData.description || ""
            font.pointSize: Style.fontSizeXS
            color: Color.mOnSurface
            wrapMode: Text.WordWrap
            elide: Text.ElideNone
            Layout.fillWidth: true
          }

          // Details row
          RowLayout {
            spacing: Style.marginS
            Layout.fillWidth: true

            NText {
              text: {
                if (modelData.updateInfo) {
                  return pluginApi?.tr("panel.version-update", { from: modelData.version, to: modelData.updateInfo.availableVersion })
                }
                return pluginApi?.tr("panel.version-display", { version: modelData.version });
              }
              font.pointSize: Style.fontSizeXS
              color: modelData.updateInfo ? Color.mPrimary : Color.mOnSurfaceVariant
              font.weight: modelData.updateInfo ? Style.fontWeightMedium : Style.fontWeightRegular
            }

            NText {
              text: pluginApi?.tr("panel.separator")
              font.pointSize: Style.fontSizeXS
              color: Color.mOnSurfaceVariant
            }

            NText {
              text: stripAuthorEmail(modelData.author)
              font.pointSize: Style.fontSizeXS
              color: Color.mOnSurfaceVariant
            }

            Item {
              Layout.fillWidth: true
            }
          }

          // Error indicator
          RowLayout {
            spacing: Style.marginS
            visible: PluginService.hasPluginError(modelData.compositeKey)

            NIcon {
              icon: "alert-triangle"
              pointSize: Style.fontSizeS
              color: Color.mError
            }

            NText {
              property var errorInfo: PluginService.getPluginError(modelData.compositeKey)
              text: errorInfo ? errorInfo.error : ""
              font.pointSize: Style.fontSizeXXS
              color: Color.mError
              wrapMode: Text.WordWrap
              Layout.fillWidth: true
              elide: Text.ElideRight
              maximumLineCount: 3
            }
          }
        }
      }
    }

    NLabel {
      visible: PluginRegistry.getAllInstalledPluginIds().length === 0
      label: pluginApi?.tr("panel.no-plugins-installed")
      Layout.fillWidth: true
    }
  }
}

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Commons
import qs.Services.Noctalia
import qs.Services.UI
import qs.Widgets

Item {
  id: root

  property var pluginApi: null

  readonly property var geometryPlaceholder: panelContainer

  property var panelScreen: pluginApi?.panelOpenScreen
  property real contentPreferredHeight: panelScreen ? Math.round(panelScreen.height * 0.95) : Math.round(700 * Style.uiScaleRatio)
  property real contentPreferredWidth: Math.round(contentPreferredHeight * 16 / 9)

  readonly property bool allowAttach: true

  anchors.fill: parent

  // Shared selection state
  property string selectedPluginId: ""
  property string _selectedPluginFallbackUrl: ""

  function _buildReadmeFallbackUrl(pluginId, sourceUrl) {
    if (!sourceUrl || sourceUrl === "") return ""
    if (sourceUrl.indexOf("https://github.com/") !== 0) return ""
    if (!(/^[a-zA-Z0-9_-]+$/).test(pluginId)) return ""
    var raw = sourceUrl.replace("https://github.com/", "https://raw.githubusercontent.com/")
    if (sourceUrl.indexOf("noctalia-dev/noctalia-plugins") !== -1)
      return raw + "/main/" + pluginId + "/README.md"
    return raw + "/main/README.md"
  }

  // ── Auto-select first plugin of the active tab ──
  function _isInstalledSelection(id) {
    if (!id) return false
    var ids = PluginRegistry.getAllInstalledPluginIds() || []
    for (var i = 0; i < ids.length; i++) {
      if (ids[i] === id) return true
    }
    return false
  }

  function _isAvailableSelection(id) {
    if (!id) return false
    var av = PluginService.availablePlugins || []
    for (var i = 0; i < av.length; i++) {
      if (av[i].id === id) return true
    }
    return false
  }

  function _firstAvailablePlugin() {
    var av = (PluginService.availablePlugins || []).slice()
    av.sort(function (a, b) {
      var da = a.lastUpdated ? new Date(a.lastUpdated).getTime() : 0
      var db = b.lastUpdated ? new Date(b.lastUpdated).getTime() : 0
      return db - da
    })
    var hwIdx = -1
    for (var i = 0; i < av.length; i++) {
      if (av[i].id === "hello-world") { hwIdx = i; break }
    }
    if (hwIdx >= 0) {
      var hw = av.splice(hwIdx, 1)[0]
      av.push(hw)
    }
    return av.length > 0 ? av[0] : null
  }

  function _autoSelectForTab(idx) {
    if (idx === 0) {
      if (_isInstalledSelection(root.selectedPluginId)) return
      var ids = PluginRegistry.getAllInstalledPluginIds() || []
      if (ids.length > 0) {
        root._selectedPluginFallbackUrl = ""
        root.selectedPluginId = ids[0]
      }
    } else if (idx === 1) {
      if (_isAvailableSelection(root.selectedPluginId)) return
      var first = _firstAvailablePlugin()
      if (first) {
        root._selectedPluginFallbackUrl = _buildReadmeFallbackUrl(first.id, first.source && first.source.url ? first.source.url : "")
        root.selectedPluginId = first.id
      }
    }
  }

  Component.onCompleted: Qt.callLater(function () { root._autoSelectForTab(subTabBar.currentIndex) })

  Connections {
    target: PluginService
    function onAvailablePluginsUpdated() {
      if (subTabBar.currentIndex === 1) root._autoSelectForTab(1)
    }
  }

  Rectangle {
    id: panelContainer
    anchors.fill: parent
    color: "transparent"

    RowLayout {
      anchors.fill: parent
      anchors.margins: Style.marginL
      spacing: 0

      // ── Left column: plugin list ──
      Item {
        Layout.preferredWidth: Math.round(360 * Style.uiScaleRatio)
        Layout.maximumWidth: Math.round(360 * Style.uiScaleRatio)
        Layout.fillHeight: true

        ColumnLayout {
          anchors.fill: parent
          spacing: 0

          NTabBar {
            id: subTabBar
            Layout.fillWidth: true
            Layout.bottomMargin: Style.marginM
            distributeEvenly: true
            currentIndex: 0
            onCurrentIndexChanged: root._autoSelectForTab(currentIndex)

            NTabButton {
              text: pluginApi?.tr("panel.tab-installed")
              tabIndex: 0
              checked: subTabBar.currentIndex === 0
            }
            NTabButton {
              text: pluginApi?.tr("panel.tab-available")
              tabIndex: 1
              checked: subTabBar.currentIndex === 1
            }
            NTabButton {
              text: pluginApi?.tr("panel.tab-sources")
              tabIndex: 2
              checked: subTabBar.currentIndex === 2
            }
          }

          StackLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: subTabBar.currentIndex

            // ── Installed tab ──
            NScrollView {
              id: installedScrollView
              horizontalPolicy: ScrollBar.AlwaysOff
              gradientColor: Color.mSurface

              Item {
                width: installedScrollView.availableWidth
                implicitWidth: installedScrollView.availableWidth
                implicitHeight: installedContent.implicitHeight

                InstalledTabContent {
                  id: installedContent
                  width: parent.width
                  pluginApi: root.pluginApi
                  selectedPluginId: root.selectedPluginId
                  onPluginSelected: id => {
                    root._selectedPluginFallbackUrl = ""
                    root.selectedPluginId = id
                  }
                }
              }
            }

            // ── Available tab ──
            NScrollView {
              id: availableScrollView
              horizontalPolicy: ScrollBar.AlwaysOff
              gradientColor: Color.mSurface

              Item {
                width: availableScrollView.availableWidth
                implicitWidth: availableScrollView.availableWidth
                implicitHeight: availableContent.implicitHeight

                AvailableTabContent {
                  id: availableContent
                  width: parent.width
                  pluginApi: root.pluginApi
                  selectedPluginId: root.selectedPluginId
                  onPluginSelected: (id, srcUrl) => {
                    root._selectedPluginFallbackUrl = root._buildReadmeFallbackUrl(id, srcUrl)
                    root.selectedPluginId = id
                  }
                }
              }
            }

            // ── Sources tab ──
            NScrollView {
              id: sourcesScrollView
              horizontalPolicy: ScrollBar.AlwaysOff
              gradientColor: Color.mSurface

              Item {
                width: sourcesScrollView.availableWidth
                implicitWidth: sourcesScrollView.availableWidth
                implicitHeight: sourcesContent.implicitHeight

                SourcesTabContent {
                  id: sourcesContent
                  width: parent.width
                  pluginApi: root.pluginApi
                }
              }
            }
          }
        }
      }

      // Vertical divider
      NDivider {
        vertical: true
        Layout.fillHeight: true
        Layout.leftMargin: Style.marginM
        Layout.rightMargin: Style.marginM
      }

      // ── Right column: README viewer ──
      PluginsReadmeView {
        Layout.fillWidth: true
        Layout.fillHeight: true
        pluginApi: root.pluginApi
        selectedPluginId: root.selectedPluginId
        fallbackReadmeUrl: root._selectedPluginFallbackUrl
      }
    }
  }
}

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
  implicitWidth: 0

  property var pluginApi: null
  property string pluginSearchText: ""
  property string selectedTag: ""
  property int tagsRefreshCounter: 0

  property string selectedPluginId: ""
  signal pluginSelected(string pluginId, string sourceUrl)
  property int availablePluginsRefreshCounter: 0

  // Pseudo tags for filtering
  readonly property var pseudoTags: ["official", "downloaded", "notDownloaded"]

  readonly property var availableTags: {
    void (root.tagsRefreshCounter);
    var tags = {};
    var plugins = PluginService.availablePlugins || [];
    for (var i = 0; i < plugins.length; i++) {
      var pluginTags = plugins[i].tags || [];
      for (var j = 0; j < pluginTags.length; j++) {
        tags[pluginTags[j]] = true;
      }
    }
    return Object.keys(tags).sort();
  }

  function stripAuthorEmail(author) {
    if (!author) return "";
    var lastBracket = author.lastIndexOf("<");
    if (lastBracket >= 0) {
      return author.substring(0, lastBracket).trim();
    }
    return author;
  }

  // Timer to check for updates after refresh starts
  Timer {
    id: checkUpdatesTimer
    interval: 100
    onTriggered: {
      PluginService.checkForUpdates();
    }
  }

  Component.onDestruction: {
    checkUpdatesTimer.stop();
  }

  function installPlugin(pluginMetadata) {
    if (!pluginApi) return;
    var title = pluginApi.tr("panel.title")
    var msg = pluginApi.tr("panel.installing", { plugin: pluginMetadata.name })
    ToastService.showNotice(title, msg);

    PluginService.installPlugin(pluginMetadata, false, function (success, error, registeredKey) {
      if (!pluginApi) return;
      if (success) {
        var successMsg = pluginApi.tr("panel.install-success", { plugin: pluginMetadata.name })
        ToastService.showNotice(title, successMsg);
        PluginService.enablePlugin(registeredKey);
      } else {
        var errorMsg = pluginApi.tr("panel.install-error", { error: error || pluginApi.tr("panel.unknown-error") })
        ToastService.showError(title, errorMsg);
      }
    });
  }

  // Listen to plugin service signals
  Connections {
    target: PluginService

    function onAvailablePluginsUpdated() {
      root.tagsRefreshCounter++;
      root.availablePluginsRefreshCounter++;

      Qt.callLater(function () {
        PluginService.checkForUpdates();
      });
    }
  }

  // Tag filter chips — wrapped in Item to prevent Flow's large implicitWidth
  Item {
    Layout.fillWidth: true
    implicitHeight: tagFilter.implicitHeight
    clip: true

    NTagFilter {
      id: tagFilter
      width: parent.width
      tags: root.pseudoTags.concat(root.availableTags)
      selectedTag: root.selectedTag
      onSelectedTagChanged: root.selectedTag = selectedTag
      label: pluginApi?.tr("panel.filter-tags-label")
      description: pluginApi?.tr("panel.filter-tags-description")
      expanded: true

      formatTag: function (tag) {
        if (tag === "")
          return pluginApi?.tr("panel.filter-all")
        if (tag === "official")
          return pluginApi?.tr("panel.official")
        if (tag === "downloaded")
          return pluginApi?.tr("panel.filter-downloaded")
        if (tag === "notDownloaded")
          return pluginApi?.tr("panel.filter-not-downloaded")
        return tag;
      }
    }
  }

  // Search input with refresh button
  RowLayout {
    Layout.fillWidth: true
    spacing: Style.marginM

    NTextInput {
      placeholderText: I18n.tr("placeholders.search")
      inputIconName: "search"
      text: root.pluginSearchText
      onTextChanged: root.pluginSearchText = text
      Layout.fillWidth: true
    }

    NIconButton {
      icon: "refresh"
      tooltipText: pluginApi?.tr("panel.refresh")
      baseSize: Style.baseWidgetSize * 0.9
      onClicked: {
        PluginService.refreshAvailablePlugins();
        checkUpdatesTimer.restart();
      }
    }
  }

  // Available plugins list
  ColumnLayout {
    spacing: Style.marginM
    Layout.fillWidth: true

    Repeater {
      id: availablePluginsRepeater

      model: {
        void (root.availablePluginsRefreshCounter);

        var all = PluginService.availablePlugins || [];
        var filtered = [];

        for (var i = 0; i < all.length; i++) {
          var plugin = all[i];
          var downloaded = plugin.downloaded || false;
          var pluginTags = plugin.tags || [];

          if (root.selectedTag === "") {
            filtered.push(plugin);
          } else if (root.selectedTag === "official") {
            if (plugin.official === true)
              filtered.push(plugin);
          } else if (root.selectedTag === "downloaded") {
            if (downloaded)
              filtered.push(plugin);
          } else if (root.selectedTag === "notDownloaded") {
            if (!downloaded)
              filtered.push(plugin);
          } else {
            if (pluginTags.indexOf(root.selectedTag) >= 0) {
              filtered.push(plugin);
            }
          }
        }

        // Apply fuzzy search
        var query = root.pluginSearchText.trim();
        if (query !== "") {
          var results = FuzzySort.go(query, filtered, {
            "keys": ["name", "description"],
            "limit": 50
          });
          filtered = [];
          for (var j = 0; j < results.length; j++) {
            filtered.push(results[j].obj);
          }
        } else {
          // Sort by lastUpdated (most recent first)
          filtered.sort(function (a, b) {
            var dateA = a.lastUpdated ? new Date(a.lastUpdated).getTime() : 0;
            var dateB = b.lastUpdated ? new Date(b.lastUpdated).getTime() : 0;
            return dateB - dateA;
          });
        }

        // Move hello-world plugin to the end
        var helloWorldIndex = -1;
        for (var h = 0; h < filtered.length; h++) {
          if (filtered[h].id === "hello-world") {
            helloWorldIndex = h;
            break;
          }
        }
        if (helloWorldIndex >= 0) {
          var helloWorld = filtered.splice(helloWorldIndex, 1)[0];
          filtered.push(helloWorld);
        }

        return filtered;
      }

      delegate: NBox {
        Layout.fillWidth: true
        Layout.leftMargin: Style.borderS
        Layout.rightMargin: Style.borderS
        implicitHeight: Math.round(contentColumn.implicitHeight + Style.margin2L)
        color: modelData.id === root.selectedPluginId ? Color.mHover : Color.mSurface

        MouseArea {
          anchors.fill: parent
          propagateComposedEvents: true
          cursorShape: Qt.PointingHandCursor
          onClicked: mouse => {
            root.pluginSelected(modelData.id, modelData.source?.url || "")
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
              color: Color.mPrimary
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

          // Row 2: action buttons
          RowLayout {
            spacing: Style.marginXS
            Layout.fillWidth: true

            NIconButton {
              icon: "external-link"
              baseSize: Style.baseWidgetSize * 0.7
              tooltipText: pluginApi?.tr("panel.open-plugin-page")
              onClicked: {
                var sourceUrl = modelData.source?.url || "";
                Qt.openUrlExternally(sourceUrl && !PluginRegistry.isMainSource(sourceUrl) ? sourceUrl : "https://noctalia.dev/plugins/" + modelData.id + "/");
              }
            }

            // Downloaded indicator
            NIcon {
              icon: "circle-check"
              pointSize: Style.baseWidgetSize * 0.5
              color: Color.mPrimary
              visible: modelData.downloaded === true
            }

            // Install button
            NIconButton {
              visible: modelData.downloaded === false && !PluginService.installingPlugins[modelData.id]
              icon: "download"
              baseSize: Style.baseWidgetSize * 0.7
              tooltipText: pluginApi?.tr("panel.install")
              onClicked: installPlugin(modelData)
            }

            // Installing spinner
            NBusyIndicator {
              visible: !modelData.downloaded && (PluginService.installingPlugins[modelData.id] === true)
              size: Style.baseWidgetSize * 0.5
              running: visible
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

          // Details: version, author
          RowLayout {
            spacing: Style.marginS
            Layout.fillWidth: true

            NText {
              text: pluginApi?.tr("panel.version-display", { version: modelData.version })
              font.pointSize: Style.fontSizeXS
              color: Color.mOnSurfaceVariant
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

          // Source name
          NText {
            visible: modelData.source ? true : false
            text: modelData.source ? modelData.source.name : ""
            font.pointSize: Style.fontSizeXS
            color: Color.mOnSurfaceVariant
          }

          // Last updated
          NText {
            visible: !!modelData.lastUpdated
            text: modelData.lastUpdated ? Time.formatRelativeTime(new Date(modelData.lastUpdated)) : ""
            font.pointSize: Style.fontSizeXS
            color: Color.mOnSurfaceVariant
          }
        }
      }
    }

    NLabel {
      visible: availablePluginsRepeater.count === 0
      label: pluginApi?.tr("panel.no-plugins-available")
      Layout.fillWidth: true
    }
  }
}

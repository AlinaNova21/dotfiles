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

  // List of plugin sources
  ColumnLayout {
    spacing: Style.marginM
    Layout.fillWidth: true

    Repeater {
      id: pluginSourcesRepeater
      model: PluginRegistry.pluginSources || []

      delegate: NBox {
        Layout.fillWidth: true
        implicitHeight: sourceRow.implicitHeight + Style.margin2L
        color: Color.mSurface

        RowLayout {
          id: sourceRow
          anchors.fill: parent
          anchors.margins: Style.marginL
          spacing: Style.marginM

          NIcon {
            icon: "brand-github"
            pointSize: Style.fontSizeL
          }

          ColumnLayout {
            spacing: Style.marginXS
            Layout.fillWidth: true

            NText {
              text: modelData.name
              color: Color.mOnSurface
              Layout.fillWidth: true
            }

            NText {
              text: modelData.url
              font.pointSize: Style.fontSizeXS
              color: Color.mOnSurfaceVariant
              Layout.fillWidth: true
              elide: Text.ElideRight
            }
          }

          NIconButton {
            icon: "trash"
            tooltipText: pluginApi?.tr("panel.uninstall")
            visible: index !== 0
            baseSize: Style.baseWidgetSize * 0.7
            onClicked: {
              PluginRegistry.removePluginSource(modelData.url);
            }
          }

          NToggle {
            checked: modelData.enabled !== false
            baseSize: Style.baseWidgetSize * 0.7
            onToggled: checked => {
              PluginRegistry.setSourceEnabled(modelData.url, checked);
              PluginService.refreshAvailablePlugins();
            }
          }
        }
      }
    }
  }

  // Add custom repository
  NButton {
    text: I18n.tr("panels.plugins.sources-add-custom")
    icon: "plus"
    onClicked: {
      addSourceDialog.open();
    }
    Layout.fillWidth: true
  }

  // Add source dialog
  Popup {
    id: addSourceDialog
    parent: Overlay.overlay
    modal: true
    dim: false
    anchors.centerIn: parent
    width: Math.round(500 * Style.uiScaleRatio)
    padding: Style.marginL

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
        label: I18n.tr("panels.plugins.sources-add-dialog-title")
        description: I18n.tr("panels.plugins.sources-add-dialog-description")
      }

      NTextInput {
        id: sourceNameInput
        label: I18n.tr("panels.plugins.sources-add-dialog-name")
        placeholderText: I18n.tr("panels.plugins.sources-add-dialog-name-placeholder")
        Layout.fillWidth: true
      }

      NTextInput {
        id: sourceUrlInput
        label: I18n.tr("panels.plugins.sources-add-dialog-url")
        placeholderText: "https://github.com/user/repo"
        Layout.fillWidth: true
      }

      RowLayout {
        spacing: Style.marginM
        Layout.fillWidth: true

        Item {
          Layout.fillWidth: true
        }

        NButton {
          text: pluginApi?.tr("panel.cancel")
          onClicked: addSourceDialog.close()
        }

        NButton {
          text: I18n.tr("common.add")
          backgroundColor: Color.mPrimary
          textColor: Color.mOnPrimary
          enabled: sourceNameInput.text.length > 0 && sourceUrlInput.text.length > 0
          onClicked: {
            if (PluginRegistry.addPluginSource(sourceNameInput.text, sourceUrlInput.text)) {
              PluginService.refreshAvailablePlugins();
              addSourceDialog.close();
              sourceNameInput.text = "";
              sourceUrlInput.text = "";
            }
          }
        }
      }
    }
  }

  // Listen to plugin registry changes
  Connections {
    target: PluginRegistry

    function onPluginsChanged() {
      pluginSourcesRepeater.model = undefined;
      Qt.callLater(function () {
        pluginSourcesRepeater.model = Qt.binding(function () {
          return PluginRegistry.pluginSources || [];
        });
      });
    }
  }
}

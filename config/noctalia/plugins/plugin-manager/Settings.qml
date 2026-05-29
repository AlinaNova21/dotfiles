import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets

ColumnLayout {
  id: root

  property var pluginApi: null

  property var cfg: pluginApi?.pluginSettings || ({})
  property var defaults: pluginApi?.manifest?.metadata?.defaultSettings || ({})

  property string valueIconColor: cfg.iconColor ?? defaults.iconColor

  spacing: Style.marginL

  NComboBox {
    label: pluginApi?.tr("settings.iconColor.label")
    description: pluginApi?.tr("settings.iconColor.desc")
    model: Color.colorKeyModel
    currentKey: root.valueIconColor
    onSelected: key => root.valueIconColor = key
  }

  function saveSettings() {
    if (!pluginApi) {
      Logger.e("PluginManager", "Cannot save settings: pluginApi is null");
      return;
    }

    pluginApi.pluginSettings.iconColor = root.valueIconColor;
    pluginApi.saveSettings();

    Logger.d("PluginManager", "Settings saved");
  }
}

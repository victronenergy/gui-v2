set(VictronGuiPlugins_CPP_SOURCES
    guiplugins/pluginaccesslevel.h
    guiplugins/pluginaccesslevel.cpp
    guiplugins/plugindataitem.h
    guiplugins/plugindataitem.cpp
    guiplugins/pluginunit.h
    guiplugins/pluginunit.cpp
)

set(VictronGuiPlugins_QML_MODULE_SINGLETON_SOURCES
    guiplugins/PluginIcons.qml
    guiplugins/PluginWords.qml
)
set_source_files_properties(${VictronGuiPlugins_QML_MODULE_SINGLETON_SOURCES} PROPERTIES QT_QML_SINGLETON_TYPE TRUE)

set(VictronGuiPlugins_QML_MODULE_SOURCES
    ${VictronGuiPlugins_QML_MODULE_SINGLETON_SOURCES}
    guiplugins/PluginDevicePage.qml
    guiplugins/PluginGradientListView.qml
    guiplugins/PluginIconImage.qml
    guiplugins/PluginListButton.qml
    guiplugins/PluginListItem.qml
    guiplugins/PluginListNavigation.qml
    guiplugins/PluginListQuantity.qml
    guiplugins/PluginListRadioButtonGroup.qml
    guiplugins/PluginListRow.qml
    guiplugins/PluginListSpinBox.qml
    guiplugins/PluginListSwitch.qml
    guiplugins/PluginListTemperature.qml
    guiplugins/PluginListText.qml
    guiplugins/PluginListTextField.qml
    guiplugins/PluginPage.qml
    guiplugins/PluginPrimaryListLabel.qml
    guiplugins/PluginSettingsListHeader.qml
)

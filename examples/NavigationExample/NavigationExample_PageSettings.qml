import QtQuick
import Victron.VenusOS

Page {
	id: root

	readonly property string pluginName: "NavigationExample"

	title: "Example"

	GradientListView {
		model: VisibleItemModel {
			ListSwitch {
				id: enabledSwitch
				text: "Enabled"
				checked: GuiPluginLoader.isPluginEnabled(root.pluginName)
				onClicked: GuiPluginLoader.setPluginEnabled(root.pluginName, !checked)

				Connections {
					target: GuiPluginLoader
					function onPluginUiStateChanged(name) {
						if (name === root.pluginName) {
							enabledSwitch.checked = GuiPluginLoader.isPluginEnabled(root.pluginName)
						}
					}
				}
			}

			ListRadioButtonGroup {
				id: gridColumnsGroup

				text: "Tile grid"
				optionModel: [
					{ display: "2 × 3", value: 2 },
					{ display: "3 × 2", value: 3 }
				]
				updateDataOnClick: false
				currentIndex: {
					const cols = Number(GuiPluginLoader.pluginSetting(root.pluginName, "gridColumns", 3))
					return cols === 2 ? 0 : 1
				}
				onOptionClicked: function(index) {
					const cols = optionModel[index].value
					GuiPluginLoader.setPluginSetting(root.pluginName, "gridColumns", cols)
					currentIndex = index
				}

				Connections {
					target: GuiPluginLoader
					function onPluginUiStateChanged(name) {
						if (name === root.pluginName) {
							const cols = Number(GuiPluginLoader.pluginSetting(root.pluginName, "gridColumns", 3))
							gridColumnsGroup.currentIndex = cols === 2 ? 0 : 1
						}
					}
				}
			}

			ListText {
				text: "Widget order"
				// Placeholder for a follow-up: persist an ordered id list in
				// GuiPluginLoader.pluginSetting(name, "widgetOrder", [...]).
				secondaryText: "Not yet configurable"
			}
		}
	}
}

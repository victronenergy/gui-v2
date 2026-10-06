import QtQuick
import Victron.VenusOS

Page {
	id: root

	title: "Simple"

	GradientListView {
		id: settingsListView

		model: VisibleItemModel {
			ListSwitch {
				id: enabledSwitch
				text: "Enabled"
				checked: GuiPluginLoader.isPluginEnabled("SimpleExample")
				onClicked: GuiPluginLoader.setPluginEnabled("SimpleExample", !checked)

				Connections {
					target: GuiPluginLoader
					function onPluginEnabledChanged(name) {
						if (name === "SimpleExample")
							enabledSwitch.checked = GuiPluginLoader.isPluginEnabled("SimpleExample")
					}
				}
			}

			ListSwitch {
				property bool value
				text: "Switch"
				checked: value
				onClicked: {
					value = !checked
					console.log("Switch now checked?", checked)
				}
			}
		}
	}
}

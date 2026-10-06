import QtQuick
import Victron.VenusOS

Page {
	id: root

	title: "SimpleTr"

	GradientListView {
		id: settingsListView

		model: VisibleItemModel {
			ListSwitch {
				id: enabledSwitch
				text: "Enabled"
				checked: GuiPluginLoader.isPluginEnabled("SimpleTrExample")
				onClicked: GuiPluginLoader.setPluginEnabled("SimpleTrExample", !checked)

				Connections {
					target: GuiPluginLoader
					function onPluginEnabledChanged(name) {
						if (name === "SimpleTrExample")
							enabledSwitch.checked = GuiPluginLoader.isPluginEnabled("SimpleTrExample")
					}
				}
			}

			ListSwitch {
				property bool value
				//% "Battery"
				text: qsTrId("simpletrexample_pagesettingssimple_text_battery")
				checked: value
				onClicked: {
					value = !checked
					console.log("Switch now checked?", checked)
				}
			}
		}
	}
}

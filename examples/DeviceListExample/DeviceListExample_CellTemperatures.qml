import QtQuick
import Victron.GuiPlugins

PluginDevicePage {
	id: root

	title: "Cell Temperatures" // No translation, just as an example.

	PluginGradientListView {
		PluginListSwitch {
			text: "Temperatures" + " " + root.serviceUid // Again, no translation, just as an example.
			checkable: true
			onClicked: console.log("Switch now checked?", checked)
		}
	}
}

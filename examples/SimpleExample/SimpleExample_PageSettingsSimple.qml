import QtQuick
import Victron.GuiPlugins

PluginPage {
	id: root

	title: "Simple"

	PluginItemListView {
		PluginListSwitch {
			text: "Switch"
			checkable: true
			onClicked: console.log("Switch now checked?", checked)
		}
	}
}

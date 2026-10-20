import QtQuick
import Victron.GuiPlugins

PluginPage {
	id: root

	title: "SimpleTr"

	PluginGradientListView {
		PluginListSwitch {
			//% "Battery"
			text: qsTrId("simpletrexample_pagesettingssimple_text_battery")
			checkable: true
			onClicked: console.log("Switch now checked?", checked)
		}
	}
}

import QtQuick
import Victron.GuiPlugins

PluginDevicePage {
	id: root

	//% "Cell Voltages"
	title: qsTrId("devicelistexample_cellvoltages_title_cell_voltages")

	PluginGradientListView {
		PluginListSwitch {
			//% "Battery"
			text: qsTrId("devicelistexample_cellvoltages_text_battery") + " " + root.serviceUid
			checkable: true
			onClicked: console.log("Switch now checked?", checked)
		}

		PluginListItem {
			//% "Image"
			text: qsTrId("devicelistexample_cellvoltages_text_image")

			// The image has its own colors, which can be seen on both light and dark backgrounds.
			Image {
				source: "qrc:/DeviceListExample/customimage.svg"
			}
		}
	}
}

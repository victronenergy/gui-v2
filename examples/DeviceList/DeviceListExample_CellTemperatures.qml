import QtQuick
import Victron.VenusOS

DeviceListPluginPage {
	id: root

	title: "Cell Temperatures" // No translation, just as an example.

	GradientListView {
		id: settingsListView

		model: VisibleItemModel {
			ListSwitch {
				property bool value
				text: "Temperatures"  + " " + root.device.serviceUid // Again, no translation, just as an example.
				checked: value
				onClicked: {
					value = !checked
					console.log("Switch now checked?", checked)
				}
			}
		}
	}
}

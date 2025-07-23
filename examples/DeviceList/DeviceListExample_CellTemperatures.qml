import QtQuick
import Victron.VenusOS

CustomDevicePageEntry {
	id: root

	title: "Cell Temperatures" // No translation, just as an example.

	GradientListView {
		id: settingsListView

		model: VisibleItemModel {
			ListSwitch {
				text: "Temperatures"  + " " + root.device.serviceUid // Again, no translation, just as an example.
				property bool value
				checked: value
				onClicked: {
					value = !checked
					console.log("Switch now checked?", checked)
				}
			}
		}
	}
}

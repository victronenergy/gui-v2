import QtQuick
import Victron.VenusOS

Page {
	id: root

	title: "Cell Temperatures" // No translation, just as an example.

	GradientListView {
		id: settingsListView

		model: VisibleItemModel {
			ListSwitch {
				text: "Temperatures" // Again, no translation, just as an example.
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

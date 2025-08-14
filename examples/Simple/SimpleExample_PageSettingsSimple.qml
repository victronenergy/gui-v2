import QtQuick
import Victron.VenusOS

Page {
	id: root

	title: "Simple"

	GradientListView {
		id: settingsListView

		model: VisibleItemModel {
			ListSwitch {
				text: "Switch"
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

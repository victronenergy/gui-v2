import QtQuick
import Victron.VenusOS

Page {
	id: root

	title: "Simple"

	GradientListView {
		id: settingsListView

		model: VisibleItemModel {
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

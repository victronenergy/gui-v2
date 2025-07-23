import QtQuick
import Victron.VenusOS

Page {
	id: root

	//% "Cell Voltages"
	title: qsTrId("devicelistexample_cellvoltages_title_cell_voltages")

	GradientListView {
		id: settingsListView

		model: VisibleItemModel {
			ListSwitch {
				//% "Battery"
				text: qsTrId("devicelistexample_cellvoltages_text_battery")
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

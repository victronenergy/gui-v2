import QtQuick
import Victron.VenusOS

Page {
	id: root

	title: "SimpleTr"

	GradientListView {
		id: settingsListView

		model: VisibleItemModel {
			ListSwitch {
				//% "Battery"
				text: qsTrId("simpletr_page_settings_simpletr_text_battery")
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

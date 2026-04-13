import QtQuick
import Victron.VenusOS

Page {
	id: root

	title: "SimpleTr"

	GradientListView {
		id: settingsListView

		model: VisibleItemModel {
			ListSwitch {
				property bool value
				//% "Battery"
				text: qsTrId("simpletrexample_pagesettingssimple_text_battery")
				checked: value
				onClicked: {
					value = !checked
					console.log("Switch now checked?", checked)
				}
			}
		}
	}
}

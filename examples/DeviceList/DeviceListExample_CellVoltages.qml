import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

DeviceListPluginPage {
	id: root

	//% "Cell Voltages"
	title: qsTrId("devicelistexample_cellvoltages_title_cell_voltages")

	GradientListView {
		id: settingsListView

		model: VisibleItemModel {
			ListSwitch {
				property bool value
				//% "Battery"
				text: qsTrId("devicelistexample_cellvoltages_text_battery") + " " + root.device.serviceUid
				checked: value
				onClicked: {
					value = !checked
					console.log("Switch now checked?", checked)
				}
			}

			ListItem {
				//% "Image"
				text: qsTrId("devicelistexample_cellvoltages_text_image")
				CP.IconImage {
					anchors {
						verticalCenter: parent.verticalCenter
						right: parent.right
						rightMargin: Theme.geometry_listItem_content_horizontalMargin
					}
					source: "qrc:/DeviceListExample/customimage.svg"
					color: Theme.color_font_primary
				}
			}
		}
	}
}

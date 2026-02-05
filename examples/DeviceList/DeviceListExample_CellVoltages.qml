import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.impl as CP
import Victron.VenusOS

DeviceListPluginPage {
	id: root

	//% "Cell Voltages"
	title: qsTrId("devicelistexample_cellvoltages_title_cell_voltages")

	GradientListView {
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

			ListItemControl {
				id: imageItem

				contentItem: RowLayout {
					Label {
						//% "Image"
						text: qsTrId("devicelistexample_cellvoltages_text_image")
						font: imageItem.font
						Layout.fillWidth: true
					}

					CP.IconImage {
						source: "qrc:/DeviceListExample/customimage.svg"
						color: Theme.color_font_primary
					}
				}
			}
		}
	}
}

/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string settings: Global.systemSettings.serviceUid

	topRightButton: Global.systemSettings.canAccess(VenusOS.User_AccessType_Installer)
			? VenusOS.StatusBar_RightButton_Add
			: VenusOS.StatusBar_RightButton_None

	Connections {
		target: Global.mainView?.statusBar ?? null
		enabled: root.isCurrentPage

		function onRightButtonClicked() {
			Global.pageManager.pushPage("/pages/settings/PageSettingsFroniusAddLocation.qml", { locations: _locations } )
		}
	}

	VeQuickItem {
		id: _locations

		uid: root.settings + "/Settings/Fronius/ModbusAlternates"
		// eg: [[1501,1],[1502,2]]
	}


	GradientListView {
		header: PrimaryListLabel {
			horizontalAlignment: Text.AlignHCenter
			//% "The default modbus port is 502 and the default unit ID is 126.\n"
			//% "Here you can add additional ports and unit IDs to scan for PV inverters."
			text: qsTrId("page_settings_fronius_modbus_locations_note")
		}
		model: _locations.value ? _locations.value.split(',') : []
		delegate: ListItem {
			id: locationDelegate

			property int locationNumber: index + 1
			property var modbusAlternates: modelData.split(':')

			//% "Port/Unit ID %1"
			text: qsTrId("page_settings_fronius_modbus_location_number").arg(locationNumber)
			content.spacing: 30
			content.children: [
				Label {
					id: portNumber

					anchors.verticalCenter: parent?.verticalCenter
					text: modbusAlternates[0].toUpperCase() // eg. '1501'
				},
				Label {
					id: unitAddress

					anchors.verticalCenter: parent?.verticalCenter
					text: modbusAlternates[1] // unit address
				},
				RemoveButton {
					id: removeButton
					visible: locationDelegate.clickable
					onClicked: {
						Global.dialogLayer.open(removeLocationDialog, {
							modbusLocation: modelData,
							//% "Port: %1 (Unit %2)"
							description: qsTrId("page_settings_fronius_modbus_remove_location_description")
									.arg(portNumber.text)
									.arg(unitAddress.text)
						})
					}
				}
			]

			interactive: true
			writeAccessLevel: VenusOS.User_AccessType_Installer
			onClicked: removeButton.clicked()
		}
	}

	Component {
		id: removeLocationDialog

		ModalWarningDialog {

			property var modbusLocation

			//% "Remove Modbus port and unit ID?"
			title: qsTrId("page_settings_fronius_modbus_remove_location")
			dialogDoneOptions: VenusOS.ModalDialog_DoneOptions_OkAndCancel
			height: Theme.geometry_modalDialog_height_small
			icon.color: Theme.color_orange
			acceptText: CommonWords.remove

			onAccepted: {
				const locations = _locations.value ? _locations.value.split(',') : []
				for (let i = 0; i < locations.length; ++i) {
					if (locations[i] === modbusLocation) {
						locations.splice(i, 1)
						_locations.setValue(locations.join(','))
						break
					}
				}
			}
		}
	}
}

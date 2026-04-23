/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import Victron.VenusOS

Page {
	id: root

	function _showRemoveDialog(locationData, port, address) {
		Global.dialogLayer.open(removeLocationDialog, {
			modbusLocation: locationData,
			//% "Port: %1 (Unit %2)"
			description: qsTrId("page_settings_fronius_modbus_remove_location_description")
					.arg(port)
					.arg(address)
		})
	}

	VeQuickItem {
		id: _locations

		uid: Global.systemSettings.serviceUid + "/Settings/Fronius/ModbusAlternates"
		// eg: [[1501,1],[1502,2]]
	}

	GradientListView {
		header: SettingsColumn {
			width: parent?.width ?? 0

			ListNavigation {
				//% "Add port and unit ID"
				text: qsTrId("page_settings_fronius_modbus_add_title")
				iconSource: "qrc:/images/icon_plus_32.svg"
				iconColor: Theme.color_ok
				showAccessLevel: VenusOS.User_AccessType_Installer
				onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsFroniusAddLocation.qml", { locations: _locations } )
			}

			PrimaryListLabel {
				//% "The default modbus port is 502 and the default unit ID is 126."
				text: qsTrId("page_settings_fronius_modbus_locations_note")
			}
		}
		model: _locations.value ? _locations.value.split(',') : []
		delegate: ListQuantityGroupNavigation {
			id: locationDelegate

			readonly property int locationNumber: index + 1
			readonly property var modbusAlternates: modelData.split(':')
			readonly property string portNumber: modbusAlternates[0]
			readonly property string unitAddress: modbusAlternates[1]

			function showRemoveDialog() {
				root._showRemoveDialog(modelData, portNumber, unitAddress)
			}

			//% "Port/Unit ID %1"
			text: qsTrId("page_settings_fronius_modbus_location_number").arg(locationNumber)
			iconSource: "qrc:/images/icon_minus_32.svg"
			iconColor: Theme.color_ok
			hasSubMenu: false
			quantityModel: QuantityObjectModel {
				QuantityObject { object: locationDelegate; key: "portNumber"; unit: VenusOS.Units_None }
				QuantityObject { object: locationDelegate; key: "unitAddress"; unit: VenusOS.Units_None }
			}

			background: ListSettingBackground {
				indicatorColor: locationDelegate.backgroundIndicatorColor

				ListPressArea {
					anchors.fill: parent
					enabled: locationDelegate.clickable
					onClicked: locationDelegate.showRemoveDialog()
				}
			}

			interactive: userHasWriteAccess
			Keys.enabled: Global.keyNavigationEnabled && interactive
			onClicked: showRemoveDialog()
		}
	}

	Component {
		id: removeLocationDialog

		ModalWarningDialog {
			property var modbusLocation

			//% "Remove Modbus port and unit ID?"
			title: qsTrId("page_settings_fronius_modbus_remove_location")
			dialogDoneOptions: VenusOS.ModalDialog_DoneOptions_OkAndCancel
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

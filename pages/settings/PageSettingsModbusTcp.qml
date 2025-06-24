/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	readonly property string modbustcpServiceUid: BackendConnection.serviceUidForType("modbustcp")

	VeQuickItem {
		id: lastError
		uid: root.modbustcpServiceUid + "/LastError/Message"
	}

	VeQuickItem {
		id: timestamp
		uid: root.modbustcpServiceUid + "/LastError/Timestamp"
	}

	GradientListView {
		model: VisibleItemModel {
			ListSwitch {
				id: enableModbusTcp

				//% "Enable Modbus TCP Server"
				text: qsTrId("settings_modbus_enable_modbus_tcp")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Services/Modbus"
			}

			ListRadioButtonGroup {
				//% "Access permissions"
				text: qsTrId("settings_modbus_access_rights")
				preferredVisible: enableModbusTcp.checked
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/ModbusServer/ReadWrite"
				optionModel: [
					//% "Write allowed"
					{ display: qsTrId("settings_modbus_access_readwrite"), value: 1 },
					//% "Read only"
					{ display: qsTrId("settings_modbus_access_readonly"), value: 0 },
				]
			}

			ListNavigation {
				//% "Available services"
				text: qsTrId("settings_modbus_available_services")
				preferredVisible: enableModbusTcp.checked
				onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsModbusTcpServices.qml", { title: text })
			}

			PrimaryListLabel {
				//% "No errors reported"
				text: lastError.valid ? lastError.value : qsTrId("settings_modbus_no_errors")
				preferredVisible: enableModbusTcp.checked
				horizontalAlignment: Text.AlignHCenter
			}

			ListText {
				//% "Time of last error"
				text: qsTrId("settings_modbus_time_of_last_error")
				secondaryText: timestamp.valid ? Qt.formatDateTime(new Date(timestamp.value * 1000), "yyyy-MM-dd hh:mm:ss") : ""
				preferredVisible: enableModbusTcp.checked && lastError.valid
			}

			ListButton {
				text: CommonWords.clear_error_action
				secondaryText: CommonWords.press_to_clear
				preferredVisible: enableModbusTcp.checked && lastError.valid
				onClicked: {
					lastError.setValue(undefined)
					timestamp.setValue(undefined)
				}
			}
		}
	}
}

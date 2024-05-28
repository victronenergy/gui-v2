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
		model: ObjectModel {
			ListSwitch {
				id: enableModbusTcp

				//% "Enable Modbus/TCP"
				text: qsTrId("settings_modbus_enable_modbus_tcp")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Services/Modbus"
			}

			ListLabel {
				//% "No errors reported"
				text: lastError.isValid ? lastError.value : qsTrId("settings_modbus_no_errors")
				allowed: enableModbusTcp.checked
				horizontalAlignment: Text.AlignHCenter
			}

			ListTextItem {
				//% "Time of last error"
				text: qsTrId("settings_modbus_time_of_last_error")
				secondaryText: timestamp.isValid ? Qt.formatDateTime(new Date(timestamp.value * 1000), "yyyy-MM-dd hh:mm:ss") : ""
				allowed: enableModbusTcp.checked && lastError.isValid
			}

			ListButton {
				text: CommonWords.clear_error_action
				secondaryText: CommonWords.press_to_clear
				allowed: enableModbusTcp.checked && lastError.isValid
				onClicked: {
					lastError.setValue(undefined)
					timestamp.setValue(undefined)
				}
			}

			ListNavigationItem {
				//% "Available services"
				text: qsTrId("settings_modbus_available_services")
				allowed: enableModbusTcp.checked
				onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsModbusTcpServices.qml", { title: text })
			}
		}
	}
}

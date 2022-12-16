/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	DataPoint {
		id: lastError
		source: "com.victronenergy.modbustcp/LastError/Message"
	}

	DataPoint {
		id: timestamp
		source: "com.victronenergy.modbustcp/LastError/Timestamp"
	}

	SettingsListView {
		model: ObjectModel {
			SettingsListSwitch {
				id: enableModbusTcp

				//% "Enable Modbus/TCP"
				text: qsTrId("settings_modbus_enable_modbus_tcp")
				source: "com.victronenergy.settings/Settings/Services/Modbus"
			}

			SettingsLabel {
				//% "No errors reported"
				text: lastError.valid ? lastError.value : qsTrId("settings_modbus_no_errors")
				visible: enableModbusTcp.checked
				horizontalAlignment: Text.AlignHCenter
			}

			SettingsListTextItem {
				//% "Time of last error"
				text: qsTrId("settings_modbus_time_of_last_error")
				secondaryText: timestamp.valid ? Qt.formatDateTime(new Date(timestamp.value * 1000), "yyyy-MM-dd hh:mm:ss") : ""
				visible: enableModbusTcp.checked && lastError.valid
			}

			SettingsListButton {
				//% "Clear error"
				text: qsTrId("settings_modbus_clear_error")
				//% "Press to clear"
				button.text: qsTrId("settings_modbus_press_to_clear")
				visible: enableModbusTcp.checked && lastError.valid
				onClicked: {
					lastError.setValue(undefined)
					timestamp.setValue(undefined)
				}
			}

			SettingsListNavigationItem {
				//% "Available services"
				text: qsTrId("settings_modbus_available_services")
				visible: enableModbusTcp.checked
				onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsModbusTcpServices.qml", { title: text })
			}
		}
	}
}

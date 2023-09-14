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

	GradientListView {
		model: ObjectModel {
			ListSwitch {
				id: enableModbusTcp

				//% "Enable Modbus/TCP"
				text: qsTrId("settings_modbus_enable_modbus_tcp")
				dataSource: "com.victronenergy.settings/Settings/Services/Modbus"
			}

			ListLabel {
				//% "No errors reported"
				text: lastError.valid ? lastError.value : qsTrId("settings_modbus_no_errors")
				visible: enableModbusTcp.checked
				horizontalAlignment: Text.AlignHCenter
			}

			ListTextItem {
				//% "Time of last error"
				text: qsTrId("settings_modbus_time_of_last_error")
				secondaryText: timestamp.valid ? Qt.formatDateTime(new Date(timestamp.value * 1000), "yyyy-MM-dd hh:mm:ss") : ""
				visible: enableModbusTcp.checked && lastError.valid
			}

			ListButton {
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

			Component {
				id: pageSettingsModbusTcpServices

				PageSettingsModbusTcpServices { }
			}

			ListNavigationItem {
				//% "Available services"
				text: qsTrId("settings_modbus_available_services")
				visible: enableModbusTcp.checked
				onClicked: Global.pageManager.pushPage(pageSettingsModbusTcpServices, { title: text })
			}
		}
	}
}

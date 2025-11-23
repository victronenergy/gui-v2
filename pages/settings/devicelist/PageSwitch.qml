/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

DevicePage {
	id: root

	title: 	{
		if (device.customName) {
			return device.customName
		} else if (device.deviceInstance >= 0 && device.productName) {
			return `${device.productName} (${device.deviceInstance})`
		} else {
			return ""
		}
	}

	settingsHeader: SettingsColumn {
		width: parent?.width ?? 0
		bottomPadding: spacing

		ListText {
			//% "Module state"
			text: qsTrId("settings_module_state")
			dataItem.uid: root.serviceUid + "/State"
			secondaryText: VenusOS.switch_deviceStateToText(dataItem.value)
		}

		ListQuantity {
			//% "Module Voltage"
			text: qsTrId("settings_module_voltage")
			dataItem.uid: root.serviceUid + "/ModuleVoltage"
			preferredVisible: dataItem.valid
			unit: VenusOS.Units_Volt_DC
			precision: 1
		}
	}
	settingsModel: SwitchableOutputModel {
		sourceModel: VeQItemTableModel {
			uids: [ root.serviceUid + "/SwitchableOutput" ]
			flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
		}
	}
	settingsDelegate: SwitchableOutputListDelegate {}
	showSwitches: false
}

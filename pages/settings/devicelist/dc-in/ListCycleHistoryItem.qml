/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Column {
	id: root

	property int cycle
	property string bindPrefix

	PrimaryListLabel {
		text: cycle == 0
				//% "Active cycle"
			  ? qsTrId("cycle_history_active")
				//: %1 = cycle number
				//% "Cycle %1"
			  : qsTrId("cycle_history_num").arg(cycle)
	}

	ListTextItem {
		text: CommonWords.status
		dataItem.uid: root.bindPrefix + "/TerminationReason"
		secondaryText: {
			switch (dataItem.value) {
			case 0: return CommonWords.error
			//% "Completed"
			case 1: return qsTrId("cycle_history_completed")
			//% "DC Disconnect"
			case 2: return qsTrId("cycle_history_dc_disconnect")
			//% "Powered off"
			case 3: return qsTrId("cycle_history_powered_off")
			//% "Function change"
			case 4: return qsTrId("cycle_history_function_change")
			//% "Firmware update"
			case 5: return qsTrId("cycle_history_firmware_update")
			//% "Watchdog"
			case 6: return qsTrId("cycle_history_watchdog")
			//% "Software reset"
			case 7: return qsTrId("cycle_history_software_reset")
			case undefined: return CommonWords.unknown_status
			//% "Incomplete"
			default: return qsTrId("cycle_history_incomplete")
			}
		}
	}

	ListTextItem {
		//% "Elapsed time"
		text: qsTrId("cycle_history_elapsed_time")
		secondaryText: Utils.secondsToString(Units.sumRealNumbersList([bulkTime.value, absorptionTime.value, reconditionTime.value, floatTime.value, storageTime.value]), true)

		VeQuickItem { id: bulkTime; uid: root.bindPrefix + "/BulkTime" }
		VeQuickItem { id: absorptionTime; uid: root.bindPrefix + "/AbsorptionTime" }
		VeQuickItem { id: reconditionTime; uid: root.bindPrefix + "/ReconditionTime" }
		VeQuickItem { id: floatTime; uid: root.bindPrefix + "/FloatTime" }
		VeQuickItem { id: storageTime; uid: root.bindPrefix + "/StorageTime" }
	}

	ListQuantityGroup {
		//% "Charge / maintain (Ah)"
		text: qsTrId("cycle_history_charge_maintain_ah")
		textModel: [
			{ value: Units.sumRealNumbersList([bulkCharge.value, absorptionCharge.value]), precision: 0, unit: VenusOS.Units_AmpHour },
			{ value: Units.sumRealNumbersList([reconditionCharge.value, floatCharge.value, storageCharge.value]), precision: 0, unit: VenusOS.Units_AmpHour },
		]

		VeQuickItem { id: bulkCharge; uid: root.bindPrefix + "/BulkCharge" }
		VeQuickItem { id: absorptionCharge; uid: root.bindPrefix + "/AbsorptionCharge" }
		VeQuickItem { id: reconditionCharge; uid: root.bindPrefix + "/ReconditionCharge" }
		VeQuickItem { id: floatCharge; uid: root.bindPrefix + "/FloatCharge" }
		VeQuickItem { id: storageCharge; uid: root.bindPrefix + "/StorageCharge" }
	}

	ListQuantityGroup {
		//% "Battery (V<sub>start</sub>/V<sub>end</sub>)"
		text: qsTrId("cycle_history_battery_voltage")
		primaryLabel.textFormat: Text.RichText
		textModel: [
			{ value: startVoltage.value, unit: VenusOS.Units_Volt_DC },
			{ value: endVoltage.value, unit: VenusOS.Units_Volt_DC },
		]

		VeQuickItem { id: startVoltage; uid: root.bindPrefix + "/StartVoltage" }
		VeQuickItem { id: endVoltage; uid: root.bindPrefix + "/EndVoltage" }
	}

	ListTextItem {
		text: CommonWords.error
		dataItem.uid: root.bindPrefix + "/Error"
		secondaryText: dataItem.isValid ? ChargerError.description(dataItem.value) : dataItem.invalidText
	}
}

/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

SettingsColumn {
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

	ListText {
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

	ListText {
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
		id: chargeMaintainGroup

		readonly property real chargeTotal1: Units.sumRealNumbersList([bulkCharge.value, absorptionCharge.value])
		readonly property real chargeTotal2: Units.sumRealNumbersList([reconditionCharge.value, floatCharge.value, storageCharge.value])

		//% "Charge / maintain (Ah)"
		text: qsTrId("cycle_history_charge_maintain_ah")
		model: QuantityObjectModel {
			QuantityObject { object: chargeMaintainGroup; key: "chargeTotal1"; unit: VenusOS.Units_AmpHour; precision: 0 }
			QuantityObject { object: chargeMaintainGroup; key: "chargeTotal2"; unit: VenusOS.Units_AmpHour; precision: 0 }
		}

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
		model: QuantityObjectModel {
			QuantityObject { object: startVoltage; unit: VenusOS.Units_Volt_DC }
			QuantityObject { object: endVoltage; unit: VenusOS.Units_Volt_DC }
		}

		VeQuickItem { id: startVoltage; uid: root.bindPrefix + "/StartVoltage" }
		VeQuickItem { id: endVoltage; uid: root.bindPrefix + "/EndVoltage" }
	}

	ListText {
		text: CommonWords.error
		dataItem.uid: root.bindPrefix + "/Error"
		secondaryText: dataItem.valid ? ChargerError.description(dataItem.value) : dataItem.invalidText
	}
}

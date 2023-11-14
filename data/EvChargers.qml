/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import "common"

QtObject {
	id: root

	property real power: NaN
	property real energy: NaN

	property DeviceModel model: DeviceModel {
		modelId: "evChargers"
	}

	readonly property var maxCurrentPresets: [6, 8, 10, 14, 16, 24, 32].map(function(v) { return { value: v } })

	function addCharger(evCharger) {
		if (model.addDevice(evCharger)) {
			updateTotals()
		}
	}

	function removeCharger(evCharger) {
		if (model.removeDevice(evCharger.serviceUid)) {
			updateTotals()
		}
	}

	function updateTotals() {
		let totalPower = NaN
		let totalEnergy = NaN
		for (let i = 0; i < model.count; ++i) {
			const evCharger = model.deviceAt(i)
			const p = evCharger.power
			if (!isNaN(p)) {
				if (isNaN(totalPower)) {
					totalPower = 0
				}
				totalPower += p
			}
			const e = evCharger.energy
			if (!isNaN(e)) {
				if (isNaN(totalEnergy)) {
					totalEnergy = 0
				}
				totalEnergy += e
			}
		}
		power = totalPower
		energy = totalEnergy
	}

	function reset() {
		model.clear()
		power = NaN
	}

	function chargerStatusToText(status) {
		switch (status) {
		case VenusOS.Evcs_Status_Disconnected:
			//% "Unplugged"
			return qsTrId("evchargers_status_disconnected")
		case VenusOS.Evcs_Status_Connected:
			//% "Connected"
			return qsTrId("evchargers_status_connected")
		case VenusOS.Evcs_Status_Charging:
			return CommonWords.charging
		case VenusOS.Evcs_Status_Charged:
			//% "Charged"
			return qsTrId("evchargers_status_charged")
		case VenusOS.Evcs_Status_WaitingForSun:
			//% "Waiting for sun"
			return qsTrId("evchargers_status_waiting_for_sun")
		case VenusOS.Evcs_Status_WaitingForRFID:
			//% "Waiting for RFID"
			return qsTrId("evchargers_status_waiting_for_rfid")
		case VenusOS.Evcs_Status_WaitingForStart:
			//% "Waiting for start"
			return qsTrId("evchargers_status_waiting_for_start")
		case VenusOS.Evcs_Status_LowStateOfCharge:
			//% "Low state of charge"
			return qsTrId("evchargers_status_low_status_of_charge")
		case VenusOS.Evcs_Status_GroundTestError:
			//% "Ground test error"
			return qsTrId("evchargers_status_ground_test_error")
		case VenusOS.Evcs_Status_WeldedContactsError:
			//% "Welded contacts error"
			return qsTrId("evchargers_status_welded_contacts_error")
		case VenusOS.Evcs_Status_CpInputTestError:
			//% "CP input test error"
			return qsTrId("evchargers_status_cp_input_test_error")
		case VenusOS.Evcs_Status_ResidualCurrentDetected:
			//% "Residual current detected"
			return qsTrId("evchargers_status_residual_current_detected")
		case VenusOS.Evcs_Status_UndervoltageDetected:
			//% "Undervoltage detected"
			return qsTrId("evchargers_status_undervoltage_detected")
		case VenusOS.Evcs_Status_OvervoltageDetected:
			//% "Overvoltage detected"
			return qsTrId("evchargers_status_overvoltage_detected")
		case VenusOS.Evcs_Status_OverheatingDetected:
			//% "Overheating detected"
			return qsTrId("evchargers_status_overheating_detected")
		case VenusOS.Evcs_Status_ChargingLimit:
			//% "Charging limit"
			return qsTrId("evchargers_status_charging_limit")
		case VenusOS.Evcs_status_StartCharging:
			//% "Start charging"
			return qsTrId("evchargers_status_start_charging")
		case VenusOS.Evcs_status_SwitchingToThreePhase:
			//% "Switching to 3-phase"
			return qsTrId("evchargers_status_switching_to_three_phase")
		case VenusOS.Evcs_status_SwitchingToSinglePhase:
			//% "Switching to single phase"
			return qsTrId("evchargers_status_switching_to_single_phase")
		default:
			return ""
		}
	}

	function chargerModeToText(mode) {
		switch (mode) {
		case VenusOS.Evcs_Mode_Manual:
			return CommonWords.manual
		case VenusOS.Evcs_Mode_Auto:
			return CommonWords.auto
		case VenusOS.Evcs_Mode_Scheduled:
			//% "Scheduled"
			return qsTrId("evchargers_mode_scheduled")
		default:
			return ""
		}
	}

	Component.onCompleted: Global.evChargers = root
}

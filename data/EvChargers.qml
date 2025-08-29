/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	readonly property real power: model.totalPower
	readonly property real current: model.totalCurrent
	readonly property real energy: model.totalEnergy

	readonly property int acInputPositionCount: model.inputCount   // Chargers with input position, i.e. connected to (non-essential) AC loads
	readonly property real acInputPositionPower: model.inputPower // The total power for chargers with an input position
	readonly property int acOutputPositionCount: model.outputCount  // Chargers with output position, i.e. connected to Essential loads
	readonly property real acOutputPositionPower: model.outputPower // The total power for chargers with an output position

	readonly property EvChargerDeviceModel model: EvChargerDeviceModel {}

	readonly property var maxCurrentPresets: [6, 8, 10, 14, 16, 24, 32].map(function(v) { return { value: v } })

	readonly property var modeOptionModel: [
		{
			display: root.chargerModeToText(VenusOS.Evcs_Mode_Manual),
			value: VenusOS.Evcs_Mode_Manual,
			//% "Start and stop the process yourself. Use this for quick charges and close monitoring."
			caption: qsTrId("evcs_manual_caption")
		},
		{
			display: root.chargerModeToText(VenusOS.Evcs_Mode_Auto),
			value: VenusOS.Evcs_Mode_Auto,
			//% "Starts and stops based on the battery charge level. Optimal for overnight and extended charges to avoid overcharging."
			caption: qsTrId("evcs_auto_caption")
		},
		{
			display: root.chargerModeToText(VenusOS.Evcs_Mode_Scheduled),
			value: VenusOS.Evcs_Mode_Scheduled,
			//% "Lower electricity rates during off-peak hours or if you want to ensure that your EV is fully charged and ready to go at a specific time."
			caption: qsTrId("evcs_scheduled_caption")
		}
	]

	function chargerStatusToText(status) {
		switch (status) {
		case VenusOS.Evcs_Status_Disconnected:
			//% "Disconnected"
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
			//% "Low SOC"
			return qsTrId("evchargers_status_low_state_of_charge")
		case VenusOS.Evcs_Status_GroundTestError:
			//% "Ground test error"
			return qsTrId("evchargers_status_ground_test_error")
		case VenusOS.Evcs_Status_WeldedContactsError:
			//% "Welded contacts test error (shorted)"
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
		case VenusOS.Evcs_Status_StartCharging:
			//% "Start charging"
			return qsTrId("evchargers_status_start_charging")
		case VenusOS.Evcs_Status_SwitchingToThreePhase:
			//% "Switching to 3 phase"
			return qsTrId("evchargers_status_switching_to_three_phase")
		case VenusOS.Evcs_Status_SwitchingToSinglePhase:
			//% "Switching to 1 phase"
			return qsTrId("evchargers_status_switching_to_single_phase")
		case VenusOS.Evcs_Status_StopCharging:
			//% "Stop charging"
			return qsTrId("evchargers_status_stop_charging")
		default:
			if (status > VenusOS.Evcs_Status_OverheatingDetected && status < VenusOS.Evcs_Status_ChargingLimit) {
				//% "Reserved"
				return qsTrId("evchargers_status_reserved")
			} else {
				//% "Unknown"
				return qsTrId("evchargers_status_unknown")
			}
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

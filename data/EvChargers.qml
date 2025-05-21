/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	property real power: NaN
	property real current: NaN
	property real energy: NaN

	property int acInputPositionCount   // Chargers with input position, i.e. connected to (non-essential) AC loads
	property real acInputPositionPower: NaN // The total power for chargers with an input position
	property int acOutputPositionCount  // Chargers with output position, i.e. connected to Essential loads
	property real acOutputPositionPower: NaN // The total power for chargers with an output position

	property DeviceModel model: DeviceModel {
		modelId: "evChargers"
	}

	readonly property var maxCurrentPresets: [6, 8, 10, 14, 16, 24, 32].map(function(v) { return { value: v } })

	readonly property var modeOptionModel: [
		{
			display: chargerModeToText(VenusOS.Evcs_Mode_Manual),
			value: VenusOS.Evcs_Mode_Manual,
			//% "Start and stop the process yourself. Use this for quick charges and close monitoring."
			caption: qsTrId("evcs_manual_caption")
		},
		{
			display: Global.evChargers.chargerModeToText(VenusOS.Evcs_Mode_Auto),
			value: VenusOS.Evcs_Mode_Auto,
			//% "Starts and stops based on the battery charge level. Optimal for overnight and extended charges to avoid overcharging."
			caption: qsTrId("evcs_auto_caption")
		},
		{
			display: Global.evChargers.chargerModeToText(VenusOS.Evcs_Mode_Scheduled),
			value: VenusOS.Evcs_Mode_Scheduled,
			//% "Lower electricity rates during off-peak hours or if you want to ensure that your EV is fully charged and ready to go at a specific time."
			caption: qsTrId("evcs_scheduled_caption")
		}
	]

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
		_measurementUpdates.start()
	}

	function _doUpdateTotals() {
		let totalPower = NaN
		let totalEnergy = NaN
		let overallCurrent = NaN // current cannot be summed, so it is NaN when > 1 charger

		let totalInputCount = 0
		let totalInputPower = NaN
		let totalOutputCount = 0
		let totalOutputPower = NaN

		for (let i = 0; i < model.count; ++i) {
			const evCharger = model.deviceAt(i)
			totalPower = Units.sumRealNumbers(totalPower, evCharger.power)
			totalEnergy = Units.sumRealNumbers(totalEnergy, evCharger.energy)
			if (model.count === 1) {
				overallCurrent = evCharger.current
			}
			if (evCharger.position === VenusOS.AcPosition_AcInput) {
				totalInputCount++
				totalInputPower = Units.sumRealNumbers(totalInputPower, evCharger.power)
			} else if (evCharger.position === VenusOS.AcPosition_AcOutput) {
				totalOutputCount++
				totalOutputPower = Units.sumRealNumbers(totalOutputPower, evCharger.power)
			}
		}
		power = totalPower
		current = overallCurrent
		energy = totalEnergy
		acInputPositionCount = totalInputCount
		acInputPositionPower = totalInputPower
		acOutputPositionCount = totalOutputCount
		acOutputPositionPower = totalOutputPower
	}

	function reset() {
		model.clear()
		power = NaN
	}

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

	// Only update the totals periodically (and only when they change) to avoid excessive changes,
	// especially on multi-phase systems.
	readonly property Timer _measurementUpdates: Timer {
		interval: 1000
		onTriggered: root._doUpdateTotals()
	}

	Component.onCompleted: Global.evChargers = root
}

/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	// The "first" inverter/charger is from one of com.victronenergy.vebus, com.victronenergy.acsystem
	// or com.victronenergy.inverter (in that order of preference). If there is more than one service
	// for a particular type, the one with the lowest device instance will be used.
	readonly property var firstObject: veBusDevices.firstObject || acSystemDevices.firstObject || inverterDevices.firstObject

	// Devices from com.victronenergy.vebus
	property DeviceModel veBusDevices: DeviceModel {
		modelId: "veBusDevices"
		sortBy: BaseDeviceModel.SortByDeviceInstance
		onCountChanged: {
			Qt.callLater(root.refreshNominalInverterPower)
		}
	}

	// Devices from com.victronenergy.acsystem
	property DeviceModel acSystemDevices: DeviceModel {
		modelId: "acSystemDevices"
		sortBy: BaseDeviceModel.SortByDeviceInstance
		onCountChanged: {
			Qt.callLater(root.refreshNominalInverterPower)
		}
	}

	// Devices from com.victronenergy.inverter
	// (Inverter RS and Phoenix Inverter, which do not have AC inputs)
	property DeviceModel inverterDevices: DeviceModel {
		modelId: "inverterDevices"
		sortBy: BaseDeviceModel.SortByDeviceInstance
		onCountChanged: {
			Qt.callLater(root.refreshNominalInverterPower)
		}
	}

	// Devices from com.victronenergy.charger
	property DeviceModel chargerDevices: DeviceModel {
		modelId: "chargerDevices"
		sortBy: BaseDeviceModel.SortByDeviceInstance
	}

	property real totalNominalInverterPower: NaN

	readonly property var rsAlarms: [
		{ text: CommonWords.low_state_of_charge, alarmSuffix: "/LowSoc", pathSuffix: "/Settings/AlarmLevel/LowSoc" },
		{ text: CommonWords.low_battery_voltage, alarmSuffix: "/LowVoltage", pathSuffix: "/Settings/AlarmLevel/LowVoltage" },
		{ text: CommonWords.high_battery_voltage, alarmSuffix: "/HighVoltage", pathSuffix: "/Settings/AlarmLevel/HighVoltage" },
		{ text: CommonWords.high_temperature, alarmSuffix: "/HighTemperature", pathSuffix: "/Settings/AlarmLevel/HighTemperature" },
		//% "Low AC OUT voltage"
		{ text: qsTrId("rs_alarm_low_ac_out_voltage"), alarmSuffix: "/LowVoltageAcOut", pathSuffix: "/Settings/AlarmLevel/LowVoltageAcOut" },
		//% "High AC OUT voltage"
		{ text: qsTrId("rs_alarm_high_ac_out_voltage"), alarmSuffix: "/HighVoltageAcOut", pathSuffix: "/Settings/AlarmLevel/HighVoltageAcOut" },
		{ text: CommonWords.alarm_setting_overload, alarmSuffix: "/Overload", pathSuffix: "/Settings/AlarmLevel/Overload" },
		{ text: CommonWords.alarm_setting_dc_ripple, alarmSuffix: "/Ripple", pathSuffix: "/Settings/AlarmLevel/Ripple" },
		//% "Short circuit"
		{ text: qsTrId("rs_alarm_short_circuit"), alarmSuffix: "/ShortCircuit", pathSuffix: "/Settings/AlarmLevel/ShortCircuit" }
	]

	function refreshNominalInverterPower() {
		// Only vebus and multi devices have /NominalInverterPower
		totalNominalInverterPower = Units.sumRealNumbers(_totalNominalInverterPower(veBusDevices), _totalNominalInverterPower(acSystemDevices))
	}

	function _totalNominalInverterPower(model) {
		let total = NaN
		for (let i = 0; i < model.count; ++i) {
			const device = model.deviceAt(i)
			const value = device.nominalInverterPower
			if (!isNaN(value)) {
				total = isNaN(total) ? value : total + value
			}
		}
		return total
	}

	function inverterChargerModeToText(m) {
		switch (m) {
		case VenusOS.InverterCharger_Mode_On:
			return CommonWords.onOrOff(1)
		case VenusOS.InverterCharger_Mode_ChargerOnly:
			//% "Charger only"
			return qsTrId("inverterCharger_mode_charger_only")
		case VenusOS.InverterCharger_Mode_InverterOnly:
			//% "Inverter only"
			return qsTrId("inverterCharger_mode_inverter_only")
		case VenusOS.InverterCharger_Mode_Off:
			return CommonWords.onOrOff(0)
		case VenusOS.InverterCharger_Mode_Passthrough:
			//% "Passthrough"
			return qsTrId("inverterCharger_mode_passthrough")
		default:
			return ""
		}
	}

	function inverterModeToText(m) {
		switch (m) {
		case VenusOS.Inverter_Mode_On:
			return CommonWords.on
		case VenusOS.Inverter_Mode_Eco:
			return CommonWords.inverter_mode_eco
		case VenusOS.Inverter_Mode_Off:
			return CommonWords.off
		default:
			return ""
		}
	}

	Component.onCompleted: Global.inverterChargers = root
}

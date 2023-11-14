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
	property real current: NaN

	property DeviceModel model: DeviceModel {
		modelId: "dcInputs"
	}

	function addInput(input) {
		if (model.addDevice(input)) {
			updateTotals()
		}
	}

	function removeInput(input) {
		if (model.removeDevice(input.serviceUid)) {
			updateTotals()
		}
	}

	function updateTotals() {
		let totalPower = NaN
		let totalCurrent = NaN
		for (let i = 0; i < model.count; ++i) {
			const input = model.deviceAt(i)
			const p = input.power
			if (!isNaN(p)) {
				if (isNaN(totalPower)) {
					totalPower = 0
				}
				totalPower += p
			}
			const c = input.current
			if (!isNaN(c)) {
				if (isNaN(totalCurrent)) {
					totalCurrent = 0
				}
				totalCurrent += c
			}
		}
		power = totalPower
		current = totalCurrent
	}

	function reset() {
		model.clear()
		power = NaN
		current = NaN
	}

	function inputType(serviceType, monitorMode) {
		switch (serviceType) {
		case "alternator":
			return VenusOS.DcInputs_InputType_Alternator
		case "fuelcell":
			return VenusOS.DcInputs_InputType_FuelCell
		case "dcload":
			return VenusOS.DcInputs_InputType_DcLoad
		case "dcsystem":
			return VenusOS.DcInputs_InputType_DcSystem
		case "dcsource":
			// use the monitor mode to determine a sub-type
			break
		default:
			break
		}

		try {
			monitorMode = parseInt(monitorMode)
		} catch (e) {
			console.warn("Defaulting to DC generator type, invalid monitor mode specified!", monitorMode)
			return VenusOS.DcInputs_InputType_DcGenerator
		}

		switch (monitorMode) {
		case -1:
			return VenusOS.DcInputs_InputType_DcGenerator
		case -2:
			return VenusOS.DcInputs_InputType_AcCharger
		case -3:
			return VenusOS.DcInputs_InputType_DcCharger
		case -4:
			return VenusOS.DcInputs_InputType_WaterGenerator
		case -7:
			return VenusOS.DcInputs_InputType_ShaftGenerator
		case -8:
			return VenusOS.DcInputs_InputType_Wind
		default:
			return VenusOS.DcInputs_InputType_DcLoad
		}
	}

	function inputTypeToText(type) {
		switch (type) {
		case VenusOS.DcInputs_InputType_AcCharger:
			//% "AC charger"
			return qsTrId("dcInputs_ac_charger")
		case VenusOS.DcInputs_InputType_Alternator:
			//% "Alternator"
			return qsTrId("dcInputs_alternator")
		case VenusOS.DcInputs_InputType_DcCharger:
			//% "DC charger"
			return qsTrId("dcInputs_dccharger")
		case VenusOS.DcInputs_InputType_DcGenerator:
			//% "DC generator"
			return qsTrId("dcInputs_dc_generator")
		case VenusOS.DcInputs_InputType_DcLoad:
			//: A generic DC load device
			//% "DC load"
			return qsTrId("dcInputs_dc_load")
		case VenusOS.DcInputs_InputType_DcSystem:
			//% "DC system"
			return qsTrId("dcInputs_dc_system")
		case VenusOS.DcInputs_InputType_FuelCell:
			//% "Fuel cell"
			return qsTrId("dcInputs_fuelcell")
		case VenusOS.DcInputs_InputType_ShaftGenerator:
			//% "Shaft generator"
			return qsTrId("dcInputs_shaft_generator")
		case VenusOS.DcInputs_InputType_WaterGenerator:
			//% "Water generator"
			return qsTrId("dcInputs_water_generator")
		case VenusOS.DcInputs_InputType_Wind:
			//% "Wind charger"
			return qsTrId("dcInputs_wind_charger")
		}
	}

	Component.onCompleted: Global.dcInputs = root
}

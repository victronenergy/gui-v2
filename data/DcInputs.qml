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
	readonly property real maximumPower: _maximumPower.isValid ? _maximumPower.value : NaN

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

	// TODO these provide names that are not only for DC inputs, e.g. "dcsystem", so should move
	// this and inputTypeToText() to Global or somewhere else.
	function inputType(serviceUid, monitorMode) {
		const serviceType = BackendConnection.type === BackendConnection.MqttSource
					? serviceUid.split("/")[1] || ""
					: serviceUid.split(".")[2] || ""
		switch (serviceType) {
		case "alternator":
			return VenusOS.DcInputs_InputType_Alternator
		case "fuelcell":
			return VenusOS.DcInputs_InputType_FuelCell
		case "dcsource":
			// use the monitor mode to determine a sub-type
			break
		case "dcsystem":
			return VenusOS.DcInputs_InputType_DcSystem
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
			// Generic DC input = DC generator
			return VenusOS.DcInputs_InputType_DcGenerator
		}
	}

	function inputTypeIcon(type) {
		switch (type) {
		case VenusOS.DcInputs_InputType_Alternator:
			return "qrc:/images/alternator.svg"
		case VenusOS.DcInputs_InputType_DcGenerator:
			return "qrc:/images/generator.svg"
		case VenusOS.DcInputs_InputType_Wind:
			return "qrc:/images/wind.svg"
		default:
			return "qrc:/images/icon_dc_24.svg"
		}
	}

	readonly property VeQuickItem _maximumPower: VeQuickItem {
		uid: Global.systemSettings.serviceUid + "/Settings/Gui/Gauges/Dc/Input/Power/Max"
	}

	Component.onCompleted: Global.dcInputs = root
}

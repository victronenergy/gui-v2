/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	// The "first" inverter/charger is from one of com.victronenergy.vebus, com.victronenergy.multi
	// or com.victronenergy.inverter (in that order of preference). If there is more than service
	// for a particular type, the one with the lowest device instance will be used.
	property var first

	// Devices from com.victronenergy.vebus
	property DeviceModel veBusDevices: DeviceModel {
		modelId: "veBusDevices"
		onCountChanged: {
			Qt.callLater(root._refreshFirst)
			Qt.callLater(root.refreshNominalInverterPower)
		}
	}

	// Devices from com.victronenergy.multi (Multi RS)
	property DeviceModel multiDevices: DeviceModel {
		modelId: "multiDevices"
		onCountChanged: {
			Qt.callLater(root._refreshFirst)
			Qt.callLater(root.refreshNominalInverterPower)
		}
	}

	// Devices from com.victronenergy.inverter
	// (Inverter RS and Phoenix Inverter, which do not have AC inputs)
	property DeviceModel inverterDevices: DeviceModel {
		modelId: "inverterDevices"
		onCountChanged: {
			Qt.callLater(root._refreshFirst)
			Qt.callLater(root.refreshNominalInverterPower)
		}
	}

	property real totalNominalInverterPower: NaN

	function refreshNominalInverterPower() {
		// Only vebus and multi devices have /NominalInverterPower
		totalNominalInverterPower = Units.sumRealNumbers(_totalNominalInverterPower(veBusDevices), _totalNominalInverterPower(multiDevices))
	}

	function _refreshFirst() {
		first = veBusDevices.firstObject || multiDevices.firstObject || inverterDevices.firstObject
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
		default:
			return ""
		}
	}

	Component.onCompleted: Global.inverterChargers = root
}

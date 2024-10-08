/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	property DeviceModel model: DeviceModel {
		modelId: "environmentInputs"
	}

	readonly property ListModel _temperatureDetails: ListModel {
		ListElement {
			description: QT_TR_NOOP("Battery")
			temperatureGaugeMinimum: -20
			temperatureGaugeMaximum: 60
			temperatureGaugeStep: 10
		}
		ListElement {
			description: QT_TR_NOOP("Fridge")
			temperatureGaugeMinimum: 0
			temperatureGaugeMaximum: 20
			temperatureGaugeStep: 5
		}
		ListElement {
			description: QT_TR_NOOP("Generic")
			temperatureGaugeMinimum: -40
			temperatureGaugeMaximum: 60
			temperatureGaugeStep: 10
		}
		ListElement {
			description: QT_TR_NOOP("Room")
			temperatureGaugeMinimum: 5
			temperatureGaugeMaximum: 35
			temperatureGaugeStep: 10
		}
		ListElement {
			description: QT_TR_NOOP("Outdoor")
			temperatureGaugeMinimum: -40
			temperatureGaugeMaximum: 60
			temperatureGaugeStep: 10
		}
		ListElement {
			description: QT_TR_NOOP("Water Heater")
			temperatureGaugeMinimum: 0
			temperatureGaugeMaximum: 100
			temperatureGaugeStep: 10
		}
		ListElement {
			description: QT_TR_NOOP("Freezer")
			temperatureGaugeMinimum: -30
			temperatureGaugeMaximum: 0
			temperatureGaugeStep: 5
		}
	}

	function addInput(input) {
		model.addDevice(input)
	}

	function removeInput(input) {
		model.removeDevice(input.serviceUid)
	}

	function reset() {
		model.clear()
	}

	function temperatureTypeToText(temperatureType) {
		return _validTemperatureType(temperatureType)
				? qsTrId(_temperatureDetails.get(temperatureType).description)
				: //% "Unknown"
				  qsTrId("temperature_type_unknown")
	}

	function temperatureGaugeMinimum(temperatureType) {
		return _validTemperatureType(temperatureType)
				? (_temperatureDetails.get(temperatureType).temperatureGaugeMinimum)
				: (_temperatureDetails.get(VenusOS.Temperature_DeviceType_Generic).temperatureGaugeMinimum)
	}

	function temperatureGaugeMaximum(temperatureType) {
		return _validTemperatureType(temperatureType)
				? (_temperatureDetails.get(temperatureType).temperatureGaugeMaximum)
				: (_temperatureDetails.get(VenusOS.Temperature_DeviceType_Generic).temperatureGaugeMaximum)
	}

	function temperatureGaugeStepSize(temperatureType) {
		return _validTemperatureType(temperatureType)
				? (_temperatureDetails.get(temperatureType).temperatureGaugeStep)
				: (_temperatureDetails.get(VenusOS.Temperature_DeviceType_Generic).temperatureGaugeStep)
	}

	function _validTemperatureType(temperatureType) {
		return (temperatureType >= 0) && (temperatureType < _temperatureDetails.count)
	}

	Component.onCompleted: Global.environmentInputs = root
}

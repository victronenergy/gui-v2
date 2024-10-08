/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Device {
	id: input

	readonly property real temperature: _temperature.isValid ? _temperature.value : NaN
	readonly property real humidity: _humidity.isValid ? _humidity.value : NaN
	readonly property int temperatureType: _temperatureType.isValid ? _temperatureType.value : VenusOS.Temperature_DeviceType_Generic

	readonly property VeQuickItem _temperature: VeQuickItem {
		uid: serviceUid + "/Temperature"
	}
	readonly property VeQuickItem _humidity: VeQuickItem {
		uid: serviceUid + "/Humidity"
	}
	readonly property VeQuickItem _temperatureType: VeQuickItem {
		uid: serviceUid + "/TemperatureType"
	}
	readonly property VeQuickItem _status: VeQuickItem {
		uid: serviceUid + "/Status"
	}

	onValidChanged: {
		if (valid) {
			Global.environmentInputs.addInput(input)
		} else {
			Global.environmentInputs.removeInput(input)
		}
	}
}

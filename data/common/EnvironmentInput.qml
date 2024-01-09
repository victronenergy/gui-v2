/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.Veutil
import Victron.VenusOS

Device {
	id: input

	readonly property real temperature_celsius: _veTemperature.value === undefined ? NaN : _veTemperature.value
	readonly property real humidity: _veHumidity.value === undefined ? NaN : _veHumidity.value

	readonly property VeQuickItem _veTemperature: VeQuickItem {
		uid: serviceUid + "/Temperature"
	}
	readonly property VeQuickItem _veHumidity: VeQuickItem {
		uid: serviceUid + "/Humidity"
	}
	readonly property VeQuickItem _status: VeQuickItem {
		uid: serviceUid + "/Status"
	}

	valid: deviceInstance >= 0 && _status.value === VenusOS.EnvironmentInput_Status_Ok
	onValidChanged: {
		if (valid) {
			Global.environmentInputs.addInput(input)
		} else {
			Global.environmentInputs.removeInput(input)
		}
	}
}

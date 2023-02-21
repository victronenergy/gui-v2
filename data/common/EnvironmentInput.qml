/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQuick
import Victron.Veutil
import Victron.VenusOS
import "/components/Utils.js" as Utils

QtObject {
	id: input

	property string serviceUid

	readonly property string customName: _veCustomName.value || ""
	readonly property string productName: _veCustomName.value || ""
	readonly property real temperature_celsius: _veTemperature.value === undefined ? NaN : _veTemperature.value
	readonly property real humidity: _veHumidity.value === undefined ? NaN : _veHumidity.value

	readonly property VeQuickItem _veCustomName: VeQuickItem {
		uid: serviceUid + "/CustomName"
	}
	readonly property VeQuickItem _veProductName: VeQuickItem {
		uid: serviceUid + "/ProductName"
	}
	readonly property VeQuickItem _veTemperature: VeQuickItem {
		uid: serviceUid + "/Temperature"
	}
	readonly property VeQuickItem _veHumidity: VeQuickItem {
		uid: serviceUid + "/Humidity"
	}
}

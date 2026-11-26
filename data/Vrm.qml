/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	readonly property string serviceUid: BackendConnection.serviceUidForType("vrm")
	readonly property double heartbeat: _heartbeat.value ?? 0
	readonly property int weatherCondition: _weatherCondition.value ?? VenusOS.WeatherCondition_Unknown

	readonly property VeQuickItem _heartbeat : VeQuickItem {
		uid: root.serviceUid + "/Heartbeat" // UNIX timestamp of last update
	}

	readonly property VeQuickItem _weatherCondition : VeQuickItem {
		uid: root.serviceUid + "/Weather/Condition"
	}
}

/*
 * Copyright (C) 2024 Victron Energy B.V.
 * See LICENSE.txt for license information.
*/

import QtTest

TestCase {
	name: "BackendConnection"

	function test_backendConnectionServiceUidFromName() {
		const deviceInstance = 1
		const serviceType = "com.victronenergy.battery.lynxparallel" + deviceInstance

		compare(dbusBackend.serviceUidFromName(serviceType, deviceInstance), "dbus/com.victronenergy.battery.lynxparallel1")

		compare(mqttBackend.serviceUidFromName(serviceType, deviceInstance), "mqtt/battery/1")
	}
}

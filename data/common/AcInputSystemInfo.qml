/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	property string bindPrefix
	readonly property bool connected: _connected.value === 1
	readonly property int deviceInstance: _deviceInstance.value === undefined ? -1 : _deviceInstance.value
	readonly property string serviceType: _serviceType.value || "" // e.g. "vebus"
	readonly property string serviceName: _serviceName.value || "" // e.g. com.victronenergy.vebus.ttyO, com.victronenergy.grid.ttyO

	readonly property VeQuickItem _connected: VeQuickItem {
		uid: root.bindPrefix + "/Connected"
	}

	readonly property VeQuickItem _deviceInstance: VeQuickItem {
		uid: root.bindPrefix + "/DeviceInstance"
	}

	readonly property VeQuickItem _serviceName: VeQuickItem {
		uid: root.bindPrefix + "/ServiceName"
	}

	readonly property VeQuickItem _serviceType: VeQuickItem {
		uid: root.bindPrefix + "/ServiceType"
	}
}

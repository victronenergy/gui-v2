/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

//
// An AC input's metadata, from com.victronenergy.system/Ac/In/<1|2>.
//
QtObject {
	id: root

	property string bindPrefix
	property bool isActiveInput
	readonly property bool connected: _connected.value === 1
	readonly property int deviceInstance: _deviceInstance.value === undefined ? -1 : _deviceInstance.value
	readonly property string serviceType: _serviceType.value || "" // e.g. "vebus"
	readonly property string serviceName: _serviceName.value || "" // e.g. com.victronenergy.vebus.ttyO, com.victronenergy.grid.ttyO
	readonly property int source: _source.value === undefined ? VenusOS.AcInputs_InputSource_NotAvailable : _source.value

	readonly property VeQuickItem _connected: VeQuickItem {
		uid: root.bindPrefix ? root.bindPrefix + "/Connected" : ""
	}

	readonly property VeQuickItem _deviceInstance: VeQuickItem {
		uid: root.bindPrefix ? root.bindPrefix + "/DeviceInstance" : ""
	}

	readonly property VeQuickItem _serviceName: VeQuickItem {
		uid: root.bindPrefix ? root.bindPrefix + "/ServiceName" : ""
	}

	readonly property VeQuickItem _serviceType: VeQuickItem {
		uid: root.bindPrefix ? root.bindPrefix + "/ServiceType" : ""
	}

	readonly property VeQuickItem _source: VeQuickItem {
		uid: root.bindPrefix ? root.bindPrefix + "/Source" : ""
	}
}

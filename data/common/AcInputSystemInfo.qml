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

	required property int inputIndex
	readonly property string bindPrefix: Global.system.serviceUid + "/Ac/In/" + inputIndex
	property bool isActiveInput
	readonly property bool connected: _connected.value === 1
	readonly property int deviceInstance: _deviceInstance.value === undefined ? -1 : _deviceInstance.value
	readonly property string serviceType: _serviceType.value || "" // e.g. "vebus"
	readonly property string serviceName: _serviceName.value || "" // e.g. com.victronenergy.vebus.ttyO, com.victronenergy.grid.ttyO
	readonly property int source: _source.value === undefined ? VenusOS.AcInputs_InputSource_NotAvailable : _source.value
	readonly property real minimumCurrent: _minimumCurrent.value === undefined ? NaN : Global.acInputs.clampMeasurement(_minimumCurrent.value)
	readonly property real maximumCurrent: _maximumCurrent.value === undefined ? NaN : Global.acInputs.clampMeasurement(_maximumCurrent.value)

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

	readonly property VeQuickItem _minimumCurrent: VeQuickItem {
		uid: Global.systemSettings.serviceUid + "/Settings/Gui/Gauges/Ac/In/%1/Current/Min".arg(root.inputIndex)
	}

	readonly property VeQuickItem _maximumCurrent: VeQuickItem {
		uid: Global.systemSettings.serviceUid + "/Settings/Gui/Gauges/Ac/In/%1/Current/Max".arg(root.inputIndex)
	}
}

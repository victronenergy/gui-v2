/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

//
// An AC input's metadata, from com.victronenergy.system/Ac/In/<1|2>.
//
AcInputInfo {
	id: root

	required property int inputIndex
	required property string bindPrefix
	required property string settingsServiceUid

	// The service name of the device, e.g. "com.victronenergy.vebus.ttyO" or "com.victronenergy.grid.ttyO".
	readonly property string serviceName: _serviceName.value || ""

	signal serviceInfoChanged

	valid: deviceInstance >= 0 && serviceType.length && serviceName.length
	connected: !!_connected.value
	deviceInstance: _deviceInstance.valid ? _deviceInstance.value : -1
	serviceType: _serviceType.value || ""
	source: _source.valid ? _source.value : VenusOS.AcInputs_InputSource_NotAvailable
	minimumCurrent: _minimumCurrent.valid ? _minimumCurrent.value : NaN
	maximumCurrent: _maximumCurrent.valid ? _maximumCurrent.value : NaN

	readonly property VeQuickItem _connected: VeQuickItem {
		uid: root.bindPrefix ? root.bindPrefix + "/Connected" : ""
	}

	readonly property VeQuickItem _deviceInstance: VeQuickItem {
		uid: root.bindPrefix ? root.bindPrefix + "/DeviceInstance" : ""
		onValueChanged: Qt.callLater(root.serviceInfoChanged)
	}

	readonly property VeQuickItem _serviceName: VeQuickItem {
		uid: root.bindPrefix ? root.bindPrefix + "/ServiceName" : ""
		onValueChanged: Qt.callLater(root.serviceInfoChanged)
	}

	readonly property VeQuickItem _serviceType: VeQuickItem {
		uid: root.bindPrefix ? root.bindPrefix + "/ServiceType" : ""
		onValueChanged: Qt.callLater(root.serviceInfoChanged)
	}

	readonly property VeQuickItem _source: VeQuickItem {
		uid: root.bindPrefix ? root.bindPrefix + "/Source" : ""
		onValueChanged: Qt.callLater(root.serviceInfoChanged)
	}

	readonly property VeQuickItem _minimumCurrent: VeQuickItem {
		uid: root.settingsServiceUid + "/Settings/Gui/Gauges/Ac/In/%1/Current/Min".arg(root.inputIndex)
	}

	readonly property VeQuickItem _maximumCurrent: VeQuickItem {
		uid: root.settingsServiceUid + "/Settings/Gui/Gauges/Ac/In/%1/Current/Max".arg(root.inputIndex)
	}
}

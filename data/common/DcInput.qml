/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil

Device {
	id: input

	readonly property int inputType: Global.dcInputs.inputType(serviceType, monitorMode)
	readonly property string serviceType: BackendConnection.type === BackendConnection.MqttSource
				? serviceUid.split("/")[1] || ""
				: serviceUid.split(".")[2] || ""

	readonly property real voltage: _voltage.value === undefined ? NaN : _voltage.value
	readonly property real current: _current.value === undefined ? NaN : _current.value
	readonly property real power: isNaN(voltage) || isNaN(current) ? NaN : voltage * current
	readonly property real temperature_celsius: _temperature.value === undefined ? NaN : _temperature.value
	readonly property int monitorMode: _monitorMode.value === undefined ? -1 : _monitorMode.value

	property bool _completed

	readonly property VeQuickItem _voltage: VeQuickItem {
		uid: input.serviceUid + "/Dc/0/Voltage"
	}

	readonly property VeQuickItem _current: VeQuickItem {
		uid: input.serviceUid + "/Dc/0/Current"
	}

	readonly property VeQuickItem _temperature: VeQuickItem {
		uid: input.serviceUid + "/Dc/0/Temperature"
	}

	readonly property VeQuickItem _monitorMode: VeQuickItem {
		uid: input.serviceUid + "/Settings/MonitorMode"
	}

	onValidChanged: {
		if (!!Global.dcInputs) {
			if (valid) {
				Global.dcInputs.addInput(input)
			} else {
				Global.dcInputs.removeInput(input)
			}
		}
	}

	function _updateTotals() {
		if (_completed && !!Global.dcInputs) {
			Qt.callLater(Global.dcInputs.updateTotals)
		}
	}

	onVoltageChanged: _updateTotals()
	onCurrentChanged: _updateTotals()
	onPowerChanged: _updateTotals()

	Component.onCompleted: {
		_completed = true
	}
}

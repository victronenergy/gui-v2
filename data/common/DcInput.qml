/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

DcDevice {
	id: input

	readonly property int inputType: Global.dcInputs.inputType(serviceUid, monitorMode)
	readonly property real temperature_celsius: _temperature.value === undefined ? NaN : _temperature.value
	readonly property int monitorMode: _monitorMode.value === undefined ? -1 : _monitorMode.value

	property bool _completed

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

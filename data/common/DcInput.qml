/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil
import "/components/Utils.js" as Utils

Device {
	id: input

	property int source: VenusOS.DcInputs_InputType_DcGenerator

	readonly property real voltage: _voltage.value === undefined ? NaN : _voltage.value
	readonly property real current: _current.value === undefined ? NaN : _current.value
	readonly property real power: isNaN(voltage) || isNaN(current) ? NaN : voltage * current
	readonly property real temperature_celsius: _temperature.value === undefined ? NaN : _temperature.value
	readonly property int monitorMode: _monitorMode.value === undefined ? -1 : _monitorMode.value

	property bool _completed

	readonly property var allMonitorModes: ({
		"-1": VenusOS.DcInputs_InputType_DcGenerator,
		// -2 AC charger
		// -3 DC charger
		// -4 Water generator
		// -7 Shaft generator
		// -8 Wind charger
		"-8": VenusOS.DcInputs_InputType_Wind,
	})

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

	property bool _valid: deviceInstance.value !== undefined
	on_ValidChanged: {
		if (_valid) {
			Global.dcInputs.addInput(input)
		} else {
			Global.dcInputs.removeInput(input)
		}
	}

	function _updateTotals() {
		if (_completed) {
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

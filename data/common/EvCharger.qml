/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Device {
	id: evCharger

	readonly property int status: _status.value === undefined ? -1 : _status.value
	readonly property int mode: _mode.value === undefined ? -1 : _mode.value
	readonly property bool connected: _connected.value === 1
	readonly property int chargingTime: _chargingTime.value || 0

	readonly property real energy: _energy.numberValue
	readonly property real power: _power.numberValue
	readonly property real current: _current.numberValue
	readonly property real maxCurrent: _maxCurrent.numberValue

	readonly property ListModel phases: ListModel {
		Component.onCompleted: {
			const properties = [_phase1Power, _phase2Power, _phase3Power]
			for (let i = 0; i < properties.length; ++i) {
				append({ name: "L" + (i + 1), power: properties[i].numberValue })
			}
		}
	}

	readonly property VeQuickItem _energy: VeQuickItem {
		uid: evCharger.serviceUid + "/Ac/Energy/Forward"
	}

	readonly property VeQuickItem _phase1Power: VeQuickItem {
		uid: evCharger.serviceUid + "/Ac/L1/Power"
		onValueChanged: if (phases.count > 0) phases.setProperty(0, "power", numberValue)
	}
	readonly property VeQuickItem _phase2Power: VeQuickItem {
		uid: evCharger.serviceUid + "/Ac/L2/Power"
		onValueChanged: if (phases.count > 1) phases.setProperty(1, "power", numberValue)
	}
	readonly property VeQuickItem _phase3Power: VeQuickItem {
		uid: evCharger.serviceUid + "/Ac/L3/Power"
		onValueChanged: if (phases.count > 2) phases.setProperty(2, "power", numberValue)
	}

	readonly property VeQuickItem _power: VeQuickItem {
		uid: evCharger.serviceUid + "/Ac/Power"
		onValueChanged: Qt.callLater(Global.evChargers.updateTotals)
	}

	readonly property VeQuickItem _chargingTime: VeQuickItem {
		uid: evCharger.serviceUid + "/ChargingTime"
	}

	readonly property VeQuickItem _connected: VeQuickItem {
		uid: evCharger.serviceUid + "/Connected"
	}

	readonly property VeQuickItem _current: VeQuickItem {
		uid: evCharger.serviceUid + "/Current"
		onValueChanged: Qt.callLater(Global.evChargers.updateTotals)
	}

	readonly property VeQuickItem _maxCurrent: VeQuickItem {
		uid: evCharger.serviceUid + "/MaxCurrent"
	}

	readonly property VeQuickItem _mode: VeQuickItem {
		uid: evCharger.serviceUid + "/Mode"
	}

	readonly property VeQuickItem _status: VeQuickItem {
		uid: evCharger.serviceUid + "/Status"
	}

	onValidChanged: {
		if (!!Global.evChargers) {
			if (valid) {
				Global.evChargers.addCharger(evCharger)
			} else {
				Global.evChargers.removeCharger(evCharger)
			}
		}
	}
}

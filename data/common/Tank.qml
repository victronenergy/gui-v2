/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil
import "/components/Utils.js" as Utils

QtObject {
	id: tank

	property string serviceUid

	readonly property int type: _type.value === undefined ? -1 : _type.value
	readonly property string name: _customName.value || ""
	readonly property int level: _level.value === undefined ? 0 : _level.value
	property real remaining: NaN
	property real capacity: NaN

	readonly property VeQuickItem _status: VeQuickItem {
		uid: serviceUid + "/Status"
		onValueChanged: Qt.callLater(tank._reset)
	}
	readonly property VeQuickItem _type: VeQuickItem {
		uid: serviceUid + "/FluidType"
		onValueChanged: Qt.callLater(tank._reset)
	}
	readonly property VeQuickItem _customName: VeQuickItem {
		uid: serviceUid + "/CustomName"
	}
	readonly property VeQuickItem _level: VeQuickItem {
		uid: serviceUid + "/Level"
	}
	readonly property VeQuickItem _remaining: VeQuickItem {
		function _update() {
			tank.remaining = value === undefined ? NaN : value
			if (tank.type >= 0) {
				Global.tanks.updateTankModelTotals(tank.type)
			}
		}
		uid: serviceUid + "/Remaining"
		onValueChanged: _update()
		Component.onCompleted: _update()
	}
	readonly property VeQuickItem _capacity: VeQuickItem {
		function _update() {
			tank.capacity = value === undefined ? NaN : value
			if (tank.type >= 0) {
				Global.tanks.updateTankModelTotals(tank.type)
			}
		}
		uid: serviceUid + "/Capacity"
		onValueChanged: _update()
		Component.onCompleted: _update()
	}

	function _reset() {
		const hasType = _type.value !== undefined && _type.value >= 0
		const valid = hasType && _status.value === VenusOS.Tank_Status_Ok
		if (valid) {
			Global.tanks.addTank(tank)
		} else if (hasType) {
			Global.tanks.removeTank(tank)
		}
	}
}

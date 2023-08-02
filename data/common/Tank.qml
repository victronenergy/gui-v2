/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil
import "/components/Utils.js" as Utils

Device {
	id: tank

	readonly property int type: _type.value === undefined ? -1 : _type.value
	readonly property int level: _level.value === undefined ? 0 : _level.value
	property real remaining: NaN
	property real capacity: NaN

	readonly property VeQuickItem _status: VeQuickItem {
		uid: serviceUid + "/Status"
	}
	readonly property VeQuickItem _type: VeQuickItem {
		uid: serviceUid + "/FluidType"
	}
	readonly property VeQuickItem _level: VeQuickItem {
		uid: serviceUid + "/Level"
	}
	readonly property VeQuickItem _remaining: VeQuickItem {
		function _update() {
			tank.remaining = value === undefined ? NaN : value
			if (tank.type >= 0 && !!Global.tanks) {
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
			if (tank.type >= 0 && !!Global.tanks) {
				Global.tanks.updateTankModelTotals(tank.type)
			}
		}
		uid: serviceUid + "/Capacity"
		onValueChanged: _update()
		Component.onCompleted: _update()
	}

	property bool _valid: deviceInstance.value !== undefined && type >= 0
	on_ValidChanged: {
		if (!!Global.tanks) {
			if (_valid) {
				Global.tanks.addTank(tank)
			} else if (tank.type >= 0) {
				Global.tanks.removeTank(tank)
			}
		}
	}
}

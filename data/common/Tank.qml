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

	readonly property int status: _status.value === undefined ? -1 : _status.value
	readonly property int type: _type.value === undefined ? -1 : _type.value
	readonly property string name: _customName.value || ""
	readonly property int level: _level.value === undefined ? 0 : _level.value
	property real remaining: NaN
	property real capacity: NaN

	property var _tankModel
	onTypeChanged: {
		if (_tankModel) {
			Global.tanks.removeTank(_tankModel, tank)
			_tankModel = null
		}
		if (type >= 0) {
			Global.tanks.addTank(tank)
			_tankModel = Global.tanks.tankModel(type)
		}
	}

	readonly property VeQuickItem _status: VeQuickItem {
		uid: serviceUid + "/Status"
	}
	readonly property VeQuickItem _type: VeQuickItem {
		uid: serviceUid + "/FluidType"
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
}

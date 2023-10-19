/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil
import "/components/Utils.js" as Utils
import "/components/Gauges.js" as Gauges

Device {
	id: tank

	readonly property int type: _type.value === undefined ? -1 : _type.value
	readonly property int status: _status.value === undefined ? VenusOS.Tank_Status_Unknown : _status.value
	readonly property real temperature: _temperature.value === undefined ? NaN : _temperature.value
	readonly property int level: _level.value === undefined ? 0 : _level.value
	property real remaining: NaN
	property real capacity: NaN

	readonly property VeQuickItem _status: VeQuickItem {
		uid: serviceUid + "/Status"
	}
	readonly property VeQuickItem _temperature: VeQuickItem {
		uid: serviceUid + "/Temperature"
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

	valid: deviceInstance >= 0 && type >= 0
	onValidChanged: {
		if (!!Global.tanks) {
			if (valid) {
				if (!_invalidationTimer.running) {
					Global.tanks.addTank(tank)
				} else {
					_remaining._update()
					_capacity._update()
				}
			} else {
				_invalidationTimer.start()
			}
		}
	}

	// If the tank remains invalid for more than 5 seconds, remove it.
	property Timer _invalidationTimer: Timer {
		interval: 5000
		onTriggered: {
			if (!tank.valid && tank.type >= 0) {
				Global.tanks.removeTank(tank)
			}
		}
	}

	description: {
		if (customName.length > 0) {
			return customName
		}
		if (type >= 0 && deviceInstance >= 0) {
			const fluidType = Gauges.tankProperties(type).name
			//: Tank desription. %1 = tank type (e.g. Fuel, Fresh water), %2 = tank device instance (a number)
			//% "%1 tank (%2)"
			return qsTrId("tank_description").arg(fluidType).arg(deviceInstance)
		}
		return name
	}
}

/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil
import Victron.Utils
import Victron.Gauges

Device {
	id: tank

	readonly property int type: _type.value === undefined ? -1 : _type.value
	readonly property int status: _status.value === undefined ? VenusOS.Tank_Status_Unknown : _status.value
	readonly property real temperature: _temperature.value === undefined ? NaN : _temperature.value
	property int level
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
		onValueChanged: Qt.callLater(tank._updateMeasurements)
		Component.onCompleted: Qt.callLater(tank._updateMeasurements)
	}
	readonly property VeQuickItem _remaining: VeQuickItem {
		uid: serviceUid + "/Remaining"
		onValueChanged: Qt.callLater(tank._updateMeasurements)
		Component.onCompleted: Qt.callLater(tank._updateMeasurements)
	}
	readonly property VeQuickItem _capacity: VeQuickItem {
		uid: serviceUid + "/Capacity"
		onValueChanged: Qt.callLater(tank._updateMeasurements)
		Component.onCompleted: Qt.callLater(tank._updateMeasurements)
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
			if (!tank.isValid && tank.type >= 0) {
				Global.tanks.removeTank(tank)
			}
		}
	}

	function _updateMeasurements() {
		let remainingValue = _remaining.value === undefined ? NaN : _remaining.value
		let levelValue = _level.value === undefined ? NaN : _level.value    // 0 - 100
		let capacityValue = _capacity.value === undefined ? NaN : _capacity.value
		if ( (isNaN(remainingValue) || isNaN(levelValue)) && !isNaN(capacityValue) ) {
			if (isNaN(remainingValue)) {
				remainingValue = capacityValue * (levelValue / 100)
			} else if (isNaN(levelValue)) {
				levelValue = remainingValue / capacityValue * 100
			}
		}
		capacity = capacityValue
		remaining = remainingValue
		level = levelValue
		if (tank.type >= 0 && !!Global.tanks) {
			Global.tanks.updateTankModelTotals(tank.type)
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

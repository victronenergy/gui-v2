/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Gauges

Device {
	id: tank

	readonly property int type: _type.value === undefined ? -1 : _type.value
	readonly property int status: _status.value === undefined ? VenusOS.Tank_Status_Unknown : _status.value
	readonly property real temperature: _temperature.value === undefined ? NaN : _temperature.value
	property real level: NaN
	property real remaining: NaN
	property real capacity: NaN

	property DeviceModel _tankModel

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

	onValidChanged: Qt.callLater(tank._updateModel)
	onTypeChanged: Qt.callLater(tank._updateModel) // if type changes, move tank to the correct model

	function _updateModel() {
		if (valid && type >= 0) {
			if (_tankModel && _tankModel.type !== type) {
				_tankModel.removeDevice(tank.serviceUid)
			}
			_tankModel = Global.tanks.tankModel(type)
			_tankModel.addDevice(tank)
		} else {
			if (_tankModel) {
				_tankModel.removeDevice(tank.serviceUid)
			}
			_tankModel = null
		}
	}

	function _updateMeasurements() {
		let remainingValue = _remaining.value === undefined ? NaN : _remaining.value
		let levelValue = _level.value === undefined ? NaN : _level.value    // 0 - 100
		let capacityValue = _capacity.value === undefined ? NaN : _capacity.value

		// If there is no /Level, calculate it from other values.
		if (isNaN(levelValue) && !isNaN(capacityValue) && !isNaN(remainingValue)) {
			if (capacityValue > 0) {
				levelValue = remainingValue / capacityValue * 100
			}
		}

		// If there is no /Remaining, calculate from other values.
		if (isNaN(remainingValue) && !isNaN(levelValue) && !isNaN(capacityValue)) {
			remainingValue = capacityValue * (levelValue / 100)
		}

		capacity = capacityValue
		remaining = remainingValue
		level = levelValue
		if (tank.type >= 0 && !!Global.tanks) {
			Global.tanks.updateTankModelTotals(tank.type)
		}
	}

	name: {
		if (customName.length > 0) {
			return customName
		} else if (type >= 0 && deviceInstance >= 0) {
			//: Tank desription. %1 = tank type (e.g. Fuel, Fresh water), %2 = tank device instance (a number)
			//% "%1 tank (%2)"
			return qsTrId("tank_description").arg(Gauges.tankProperties(type).name).arg(deviceInstance)
		} else {
			return productName
		}
	}
}

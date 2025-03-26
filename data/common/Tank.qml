/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

BaseTankDevice {
	id: tank

	readonly property int status: _status.valid ? _status.value : VenusOS.Tank_Status_Unknown
	readonly property real temperature: _temperature.valid ? _temperature.value : NaN

	property TankModel _tankModel

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
		uid: serviceUid + "/Remaining"
	}
	readonly property VeQuickItem _capacity: VeQuickItem {
		uid: serviceUid + "/Capacity"
	}

	// Use a Device object to fetch the /DeviceInstance, /CustomName and /ProductName details.
	readonly property Device _device: Device {
		id: device
		serviceUid: tank.serviceUid
	}
	readonly property TankDescription _description: TankDescription {
		id: tankDescription
		device: tank._device
	}

	deviceInstance: device.deviceInstance
	productId: device.productId
	productName: device.productName
	customName: device.customName
	name: _description.description
	type: _type.valid ? _type.value : -1
	level: _level.valid ? _level.value : NaN
	capacity: _capacity.valid ? _capacity.value : NaN
	remaining: _remaining.valid ? _remaining.value : NaN

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
}

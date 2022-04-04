/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import Victron.Velib
import "/components/Utils.js" as Utils

Item {
	id: root

	enum TankType {
		Fuel = 0,
		FreshWater = 1,
		WasteWater = 2,
		LiveWell = 3,
		Oil = 4,
		BlackWater = 5,
		Gasoline = 6
	}

	enum Status {
		OK = 0,
		Disconnected = 1,
		ShortCircuited = 2,
		Unknown = 3
	}

	readonly property var tankTypes: [
		Tanks.TankType.Fuel,
		Tanks.TankType.FreshWater,
		Tanks.TankType.WasteWater,
		Tanks.TankType.LiveWell,
		Tanks.TankType.Oil,
		Tanks.TankType.BlackWater,
		Tanks.TankType.Gasoline
	]

	readonly property ListModel fuelTanks: ListModel {
		readonly property int type: Tanks.TankType.Fuel
		property real totalCapacity
		property real totalRemaining
		property int unit: Units.PhysicalQuantity.CubicMeters
		objectName: "Fuel"
	}
	readonly property ListModel freshWaterTanks: ListModel {
		readonly property int type: Tanks.TankType.FreshWater
		property real totalCapacity
		property real totalRemaining
		property int unit: Units.PhysicalQuantity.CubicMeters
		objectName: "FreshWater"
	}
	readonly property ListModel wasteWaterTanks: ListModel {
		readonly property int type: Tanks.TankType.WasteWater
		property real totalCapacity
		property real totalRemaining
		property int unit: Units.PhysicalQuantity.CubicMeters
		objectName: "WasteWater"
	}
	readonly property ListModel liveWellTanks: ListModel {
		readonly property int type: Tanks.TankType.LiveWell
		property real totalCapacity
		property real totalRemaining
		property int unit: Units.PhysicalQuantity.CubicMeters
		objectName: "LiveWell"
	}
	readonly property ListModel oilTanks: ListModel {
		readonly property int type: Tanks.TankType.Oil
		property real totalCapacity
		property real totalRemaining
		property int unit: Units.PhysicalQuantity.CubicMeters
		objectName: "Oil"
	}
	readonly property ListModel blackWaterTanks: ListModel {
		readonly property int type: Tanks.TankType.BlackWater
		property real totalCapacity
		property real totalRemaining
		property int unit: Units.PhysicalQuantity.CubicMeters
		objectName: "BlackWater"
	}
	readonly property ListModel gasolineTanks: ListModel {
		readonly property int type: Tanks.TankType.Gasoline
		property real totalCapacity
		property real totalRemaining
		property int unit: Units.PhysicalQuantity.CubicMeters
		objectName: "Gasoline"
	}

	readonly property int totalTankCount: fuelTanks.count
			+ freshWaterTanks.count
			+ wasteWaterTanks.count
			+ liveWellTanks.count
			+ oilTanks.count
			+ blackWaterTanks.count
			+ gasolineTanks.count

	function tankModel(type) {
		switch (type) {
		case Tanks.TankType.Fuel:
			return fuelTanks
		case Tanks.TankType.FreshWater:
			return freshWaterTanks
		case Tanks.TankType.WasteWater:
			return wasteWaterTanks
		case Tanks.TankType.LiveWell:
			return liveWellTanks
		case Tanks.TankType.Oil:
			return oilTanks
		case Tanks.TankType.BlackWater:
			return blackWaterTanks
		case Tanks.TankType.Gasoline:
			return gasolineTanks
		}
		console.warn("Unknown tank type", type)
		return null
	}

	property var _tanks: []

	function _getTanks() {
		const childIds = veDBus.childIds

		let tankIds = []
		for (let i = 0; i < childIds.length; ++i) {
			let id = childIds[i]
			if (id.startsWith('com.victronenergy.tank.')) {
				tankIds.push(id)
			}
		}

		if (Utils.arrayCompare(_tanks, tankIds)) {
			_tanks = tankIds
		}
	}

	function _updateTotals(type) {
		if (type < 0) {
			return
		}
		const model = tankModel(type)
		let totalRemaining = 0
		let totalCapacity = 0
		for (let i = 0; i < tankObjects.count; ++i) {
			const tank = tankObjects.objectAt(i)
			if (tank.type === type) {
				if (!isNaN(tank.remaining)) {
					totalRemaining += tank.remaining
				}
				if (!isNaN(tank.capacity)) {
					totalCapacity += tank.capacity
				}
			}
		}
		model.totalRemaining = totalRemaining
		model.totalCapacity = totalCapacity
	}

	function _updateTotal(type, prop, prevValue, newValue) {
		if (type < 0) {
			return
		}
		const model = tankModel(type)
		if (!isNaN(prevValue)) {
			model[prop] -= prevValue
		}
		if (!isNaN(newValue)) {
			model[prop] += newValue
		}
	}

	Connections {
		target: veDBus
		function onChildIdsChanged() { Qt.callLater(_getTanks) }
		Component.onCompleted: _getTanks()
	}

	Instantiator {
		id: tankObjects

		model: _tanks
		delegate: QtObject {
			id: tank

			property string uid: modelData
			property string dbusUid: "dbus/" + tank.uid

			property int status: -1
			property int type: -1
			property string name
			property int level
			property real remaining: NaN
			property real capacity: NaN

			property bool _valid: type >= 0
			on_ValidChanged: {
				const model = root.tankModel(type)
				const index = Utils.findIndex(model, tank)
				if (_valid && index < 0) {
					model.append({ tank: tank })
					root._updateTotals(tank.type)
				} else if (!_valid && index >= 0) {
					model.remove(index)
				}
			}

			property VeQuickItem _status: VeQuickItem {
				uid: dbusUid + "/Status"
				onValueChanged: tank.status = value === undefined ? -1 : value
			}
			property VeQuickItem _type: VeQuickItem {
				uid: dbusUid + "/FluidType"
				onValueChanged: tank.type = value === undefined ? -1 : value
			}
			property VeQuickItem _customName: VeQuickItem {
				uid: dbusUid + "/CustomName"
				onValueChanged: tank.name = value === undefined ? -1 : value
			}
			property VeQuickItem _level: VeQuickItem {
				uid: dbusUid + "/Level"
				onValueChanged: tank.level = value === undefined ? -1 : value
			}
			property VeQuickItem _remaining: VeQuickItem {
				uid: dbusUid + "/Remaining"
				onValueChanged: {
					const prevValue = tank.remaining
					tank.remaining = value === undefined ? -1 : value
					root._updateTotal(tank.type, "totalRemaining", prevValue, tank.remaining)
				}
			}

			property VeQuickItem _capacity: VeQuickItem {
				uid: dbusUid + "/Capacity"
				onValueChanged: {
					const prevValue = tank.remaining
					tank.capacity = value === undefined ? -1 : value
					root._updateTotal(tank.type, "totalCapacity", prevValue, tank.capacity)
				}
			}
		}
	}
}

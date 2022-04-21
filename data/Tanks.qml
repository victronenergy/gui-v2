/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import Victron.Velib
import "/components/Utils.js" as Utils

Item {
	id: root

	readonly property var tankTypes: [
		VenusOS.Tank_Type_Fuel,
		VenusOS.Tank_Type_FreshWater,
		VenusOS.Tank_Type_WasteWater,
		VenusOS.Tank_Type_LiveWell,
		VenusOS.Tank_Type_Oil,
		VenusOS.Tank_Type_BlackWater,
		VenusOS.Tank_Type_Gasoline
	]

	readonly property ListModel fuelTanks: ListModel {
		readonly property int type: VenusOS.Tank_Type_Fuel
		property real totalCapacity
		property real totalRemaining
		property int unit: VenusOS.Units_PhysicalQuantity_CubicMeters
		objectName: "Fuel"
	}
	readonly property ListModel freshWaterTanks: ListModel {
		readonly property int type: VenusOS.Tank_Type_FreshWater
		property real totalCapacity
		property real totalRemaining
		property int unit: VenusOS.Units_PhysicalQuantity_CubicMeters
		objectName: "FreshWater"
	}
	readonly property ListModel wasteWaterTanks: ListModel {
		readonly property int type: VenusOS.Tank_Type_WasteWater
		property real totalCapacity
		property real totalRemaining
		property int unit: VenusOS.Units_PhysicalQuantity_CubicMeters
		objectName: "WasteWater"
	}
	readonly property ListModel liveWellTanks: ListModel {
		readonly property int type: VenusOS.Tank_Type_LiveWell
		property real totalCapacity
		property real totalRemaining
		property int unit: VenusOS.Units_PhysicalQuantity_CubicMeters
		objectName: "LiveWell"
	}
	readonly property ListModel oilTanks: ListModel {
		readonly property int type: VenusOS.Tank_Type_Oil
		property real totalCapacity
		property real totalRemaining
		property int unit: VenusOS.Units_PhysicalQuantity_CubicMeters
		objectName: "Oil"
	}
	readonly property ListModel blackWaterTanks: ListModel {
		readonly property int type: VenusOS.Tank_Type_BlackWater
		property real totalCapacity
		property real totalRemaining
		property int unit: VenusOS.Units_PhysicalQuantity_CubicMeters
		objectName: "BlackWater"
	}
	readonly property ListModel gasolineTanks: ListModel {
		readonly property int type: VenusOS.Tank_Type_Gasoline
		property real totalCapacity
		property real totalRemaining
		property int unit: VenusOS.Units_PhysicalQuantity_CubicMeters
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
		case VenusOS.Tank_Type_Fuel:
			return fuelTanks
		case VenusOS.Tank_Type_FreshWater:
			return freshWaterTanks
		case VenusOS.Tank_Type_WasteWater:
			return wasteWaterTanks
		case VenusOS.Tank_Type_LiveWell:
			return liveWellTanks
		case VenusOS.Tank_Type_Oil:
			return oilTanks
		case VenusOS.Tank_Type_BlackWater:
			return blackWaterTanks
		case VenusOS.Tank_Type_Gasoline:
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

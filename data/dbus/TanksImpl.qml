/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import Victron.Velib
import "/components/Utils.js" as Utils

QtObject {
	id: root

	property var veDBus

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

	property Connections veDBusConn: Connections {
		target: veDBus
		function onChildIdsChanged() { Qt.callLater(_getTanks) }
	}

	property Instantiator tankObjects: Instantiator {
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
				const model = Global.tanks.tankModel(type)
				const index = Utils.findIndex(model, tank)
				if (_valid && index < 0) {
					Global.tanks.addTank(tank)
				} else if (!_valid && index >= 0) {
					Global.tanks.removeTank(type, index)
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
				onValueChanged: tank.name = value === undefined ? "" : value
			}
			property VeQuickItem _level: VeQuickItem {
				uid: dbusUid + "/Level"
				onValueChanged: tank.level = value === undefined ? NaN : value
			}
			property VeQuickItem _remaining: VeQuickItem {
				uid: dbusUid + "/Remaining"
				onValueChanged: {
					tank.remaining = value === undefined ? NaN : value
					if (tank._valid) {
						Global.tanks.updateTankModelTotals(tank.type)
					}
				}
			}
			property VeQuickItem _capacity: VeQuickItem {
				uid: dbusUid + "/Capacity"
				onValueChanged: {
					tank.capacity = value === undefined ? NaN : value
					if (tank._valid) {
						Global.tanks.updateTankModelTotals(tank.type)
					}
				}
			}
		}
	}

	Component.onCompleted: {
		_getTanks()
	}
}

/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import Victron.Velib
import "/components/Utils.js" as Utils

QtObject {
	id: root

	property var veServiceIds
	onVeServiceIdsChanged: Qt.callLater(_getTanks)

	property var _tanks: []

	function _getTanks() {
		let tankIds = []
		for (let i = 0; i < veServiceIds.length; ++i) {
			let id = veServiceIds[i]
			if (id.startsWith('tank.')) {
				tankIds.push(id)
			}
		}

		if (Utils.arrayCompare(_tanks, tankIds)) {
			_tanks = tankIds
		}
	}

	property Instantiator tankObjects: Instantiator {
		model: _tanks
		delegate: QtObject {
			id: tank

			property string uid: modelData
			property string mqttUid: "mqtt/" + tank.uid

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
				uid: mqttUid + "/Status"
				onValueChanged: tank.status = value === undefined ? -1 : value
			}
			property VeQuickItem _type: VeQuickItem {
				uid: mqttUid + "/FluidType"
				onValueChanged: tank.type = value === undefined ? -1 : value
			}
			property VeQuickItem _customName: VeQuickItem {
				uid: mqttUid + "/CustomName"
				onValueChanged: tank.name = value === undefined ? "" : value
			}
			property VeQuickItem _level: VeQuickItem {
				uid: mqttUid + "/Level"
				onValueChanged: tank.level = value === undefined ? NaN : value
			}
			property VeQuickItem _remaining: VeQuickItem {
				uid: mqttUid + "/Remaining"
				onValueChanged: {
					tank.remaining = value === undefined ? NaN : value
					if (tank._valid) {
						Global.tanks.updateTankModelTotals(tank.type)
					}
				}
			}
			property VeQuickItem _capacity: VeQuickItem {
				uid: mqttUid + "/Capacity"
				onValueChanged: {
					tank.capacity = value === undefined ? NaN : value
					if (tank._valid) {
						Global.tanks.updateTankModelTotals(tank.type)
					}
				}
			}
		}
	}
}

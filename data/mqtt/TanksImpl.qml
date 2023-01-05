/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil
import "/components/Utils.js" as Utils

QtObject {
	id: root

	readonly property Instantiator tankObjects: Instantiator {
		model: VeQItemTableModel {
			uids: ["mqtt/tank"]
			flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
		}
		delegate: QtObject {
			id: tank

			property string mqttUid: model.uid

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

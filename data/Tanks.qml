/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.Velib
import "/components/Utils.js" as Utils

Item {
	id: root

	enum TankType {
		Fuel = 0,
		FreshWater = 1,
		BlackWater = 5
	}

	property ListModel model: ListModel {}

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

	Connections {
		target: veDBus
		function onChildIdsChanged() { Qt.callLater(_getTanks) }
		Component.onCompleted: _getTanks()
	}

	Instantiator {
		model: _tanks
		delegate: QtObject {
			id: tank

			property string uid: modelData
			property string dbusUid: "dbus/" + tank.uid

			property int type: -1
			property int level: -1

			property bool _valid: type >= 0 && level >= 0
			on_ValidChanged: {
				const index = Utils.findIndex(root.model, tank)
				if (_valid && index < 0) {
					root.model.append({ tank: tank })
				} else if (!_valid && index >= 0) {
					root.model.remove(index)
				}
			}

			property VeQuickItem _type: VeQuickItem {
				uid: dbusUid + "/FluidType"
				onValueChanged: tank.type = value === undefined ? -1 : value
			}
			property VeQuickItem _level: VeQuickItem {
				uid: dbusUid + "/Level"
				onValueChanged: tank.level = value === undefined ? -1 : value
			}
		}
	}
}

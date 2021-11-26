/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.Velib

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

		let tanksIds = []
		for (let i = 0; i < childIds.length; ++i) {
			let id = childIds[i]
			if (id.startsWith('com.victronenergy.tank.')) {
				tanksIds.push(id)
			}
		}
		_tanks = tanksIds
	}

	Connections {
		target: veDBus
		function onChildIdsChanged() { _getTanks() }
		Component.onCompleted: _getTanks()
	}

	Instantiator {
		model: _tanks
		delegate: QtObject {
			id: tank

			property string uid: modelData
			property int type: -1
			property int level: -1

			property bool valid: type >= 0 && level >= 0
			onValidChanged: {
				let index = -1
				for (let i = 0; i < root.model.count; ++i) {
					if (root.model.get(i) === tank) {
						index = i
						break
					}
				}

				if (valid && index < 0) {
					root.model.append({ tank: tank })
				} else if (!valid && index >= 0) {
					root.model.remove(index)
				}
			}

			property VeQuickItem _tankType: VeQuickItem {
				uid: "dbus/" + tank.uid + "/FluidType"
				onValueChanged: tank.type = value || -1
			}
			property VeQuickItem _tankLevel: VeQuickItem {
				uid: "dbus/" + tank.uid + "/Level"
				onValueChanged: tank.level = value || -1
			}
		}
	}
}

/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.Velib
import "/components/Utils.js" as Utils

Item {
	id: root

	property ListModel model: ListModel {
		Component.onCompleted: {
			append({ name: "L1", power: 446 })
			append({ name: "L2", power: 225 })
			append({ name: "L3", power: NaN })
			_updateTotals()
		}
	}

	property real power

	function _updateTotals() {
		let totalPower = 0
		for (let i = 0; i < root.model.count; ++i) {
			totalPower += root.model.get(i).power || 0
		}
		Utils.updateMaximumValue("grid.power", totalPower)
		power = totalPower
	}

	Timer {
		running: true
		repeat: true
		interval: 10000 + (Math.random() * 10000)
		onTriggered: {
			root.model.setProperty(0, "power", Math.random() * 500)
			root.model.setProperty(1, "power", Math.random() * 300)
			root._updateTotals()
		}
	}
}

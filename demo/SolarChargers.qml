/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "/components/Utils.js" as Utils

Item {
	id: root

	property ListModel model: ListModel {
		Component.onCompleted: root.populate()
	}

	readonly property real power: isNaN(acPower) && isNaN(dcPower)
			? NaN
			: (isNaN(acPower) ? 0 : acPower) + (isNaN(dcPower) ? 0 : dcPower)
	property real acPower: NaN
	property real dcPower: NaN
	property var yieldHistory: [13400, 18500, 16200, 12100, 9300, 6600, 3200, 1040, 4400, 8800, 9300, 6600, 3200]

	onPowerChanged: Utils.updateMaximumValue("solarTracker.power", power / Math.max(1, model.count))

	function clear() {
		acPower = NaN
		dcPower = NaN
		model.clear()
	}

	function populate() {
		clear()
		acPower = 0
		dcPower = 0

		const chargerCount = Math.floor(Math.random() * 4) + 1
		for (let i = 0; i < chargerCount; ++i) {
			// Randomly distribute the charger power to AC/DC output
			let chargerPower = 50 + Math.floor(Math.random() * 200)
			let chargerAcPower = Math.random() * chargerPower
			let chargerDcPower = chargerPower - chargerAcPower
			root.acPower += chargerAcPower
			root.dcPower += chargerDcPower
			model.append({ "solarTracker": { "power": chargerPower } })
		}
	}
}

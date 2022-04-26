/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "/components/Utils.js" as Utils

QtObject {
	id: root

	// Model of all solar trackers for all solar chargers
	property ListModel model: ListModel {}

	// Overall solar power
	readonly property real power: isNaN(acPower) && isNaN(dcPower)
			? NaN
			: (isNaN(acPower) ? 0 : acPower) + (isNaN(dcPower) ? 0 : dcPower)
	property real acPower: NaN
	property real dcPower: NaN

	property var yieldHistory: []

	function addTracker(tracker) {
		model.append({ solarTracker: tracker })
	}

	function removeTracker(index) {
		model.remove(index)
	}

	function reset() {
		acPower = NaN
		dcPower = NaN
		model.clear()
	}

	onPowerChanged: {
		// Set max tracker power based on total number of trackers
		Utils.updateMaximumValue("solarTracker.power", power / Math.max(1, model.count))
	}

	Component.onCompleted: Global.solarChargers = root
}

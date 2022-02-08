/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "/components/Utils.js" as Utils

Item {
	id: root

	property ListModel model: ListModel {
		Component.onCompleted: root.populateModel()
	}

	property real voltage
	property real power
	property var yieldHistory: [13400, 18500, 16200, 12100, 9300, 6600, 3200, 1040, 4400, 8800, 9300, 6600, 3200]

	onPowerChanged: Utils.updateMaximumValue("solarTracker.power", power / Math.max(1, model.count))

	function populateModel() {
		voltage = 0
		power = 0
		model.clear()
		let dummyValuesCount = Math.floor(Math.random() * 5)
		for (let i = 0; i < dummyValuesCount; ++i) {
			let p = 50 + Math.floor(Math.random() * 200)
			let v = power / 10
			root.voltage += v
			root.power += p
			model.append({ "solarTracker": { "voltage": v, "power": p } })
		}
	}

	Connections {
		target: PageManager.navBar || null

		function onCurrentUrlChanged() {
			if (PageManager.navBar.currentUrl !== "qrc:/pages/OverviewPage.qml") {
				populateModel()
			}
		}
	}
}

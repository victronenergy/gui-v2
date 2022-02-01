/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

Item {
	id: root

	property ListModel model: ListModel {
		Component.onCompleted: root.populateModel()
	}

	property real voltage
	property real power

	function populateModel() {
		voltage = 0
		power = 0
		model.clear()
		let dummyValuesCount = Math.floor(Math.random() * 5) * 1.0
		for (let i = 0; i < dummyValuesCount; ++i) {
			let p = Math.floor(Math.random() * 200) * 1.0
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

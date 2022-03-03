/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "../data" as DBusData

Item {
	id: root

	property ListModel model: ListModel {
		Component.onCompleted: root.populate()
	}

	function populate() {
		model.clear()

		// Occasionally simulate what it looks like with only the battery
		const batteryOnly = Math.random() < 0.1
		if (batteryOnly) {
			return
		}

		const maxTankType = DBusData.Tanks.TankType.BlackWater
		for (let tankType = 0; tankType < maxTankType + 1; ++tankType) {
			var tankData = {
				type: tankType,
				level: Math.floor(Math.random() * 100),
			}
			model.append({ tank: tankData })
		}
	}

	Connections {
		target: PageManager.navBar || null

		function onCurrentUrlChanged() {
			if (PageManager.navBar.currentUrl !== "qrc:/pages/OverviewPage.qml") {
				populate()
			}
		}
	}
}

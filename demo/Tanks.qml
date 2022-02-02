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

	function populateModel() {
		model.clear()
		for (let tankType = 0; tankType < 6; ++tankType) {
			var tankData = {
				type: tankType,
				level: Math.floor(Math.random() * 100) * 1.0,
			}
			model.append({ tank: tankData })
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

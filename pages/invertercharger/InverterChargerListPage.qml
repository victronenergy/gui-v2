/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	//% "Inverter/Chargers"
	title: qsTrId("inverter_chargers_title")

	GradientListView {
		model: AggregateDeviceModel {
			sourceModels: [
				Global.inverterChargers.veBusDevices,
				Global.inverterChargers.multiDevices,
				Global.inverterChargers.inverterDevices
			]
		}

		delegate: ListNavigationItem {
			text: model.device.name
			secondaryText: Global.system.systemStateToText(model.device.state)

			onClicked: {
				if (model.device.serviceUid.indexOf('inverter') >= 0) {
					Global.pageManager.pushPage("/pages/invertercharger/OverviewInverterPage.qml",
							{ "serviceUid": model.device.serviceUid, "title": model.device.name })
				} else {
					Global.pageManager.pushPage("/pages/invertercharger/OverviewInverterChargerPage.qml",
							{ "inverterCharger": model.device })
				}
			}
		}
	}
}

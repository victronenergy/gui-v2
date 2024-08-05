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
				Global.inverterChargers.inverterDevices,
				Global.chargers.model,
				Global.acSystemDevices.model
			]
		}

		delegate: ListNavigationItem {
			text: model.device.name
			secondaryText: Global.system.systemStateToText(model.device.state)

			onClicked: {
				// Show page for chargers
				if (model.device.serviceUid.indexOf('charger') >= 0) {
					Global.pageManager.pushPage("/pages/settings/devicelist/PageAcCharger.qml",
							{ "bindPrefix": model.device.serviceUid, "title": model.device.name })
					return
				}

				// Show page for acsystem
				if (model.device.serviceUid.indexOf('acsystem') >= 0) {
					Global.pageManager.pushPage("/pages/settings/devicelist/rs/PageRsSystem.qml",
							{ "bindPrefix": model.device.serviceUid, "title": model.device.name })
					return
				}

				// Show page for inverter/charger
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

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
				Global.inverterChargers.acSystemDevices,
				Global.inverterChargers.inverterDevices,
				Global.inverterChargers.chargerDevices,
			]
		}

		delegate: ListNavigation {
			text: model.device.name
			secondaryText: Global.system.systemStateToText(stateItem.value)

			onClicked: {
				// Show page for chargers
				if (model.device.serviceUid.indexOf('charger') >= 0) {
					Global.pageManager.pushPage("/pages/settings/devicelist/PageAcCharger.qml",
							{ "bindPrefix": model.device.serviceUid, "title": model.device.name })
				} else {
					// Show page for inverter, vebus and acsystem services
					Global.pageManager.pushPage("/pages/invertercharger/OverviewInverterChargerPage.qml",
							{ "serviceUid": model.device.serviceUid, "title": model.device.name })
				}
			}

			VeQuickItem {
				id: stateItem
				uid: model.device.serviceUid + "/State"
			}
		}
	}
}

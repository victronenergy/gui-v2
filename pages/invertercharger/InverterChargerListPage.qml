/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	title: Services.system.chargerOnly
			  //% "Chargers"
			? qsTrId("inverter_chargers_chargers_title")
			  //% "Inverter/Chargers"
			: qsTrId("inverter_chargers_title")

	GradientListView {
		model: FilteredDeviceModel {
			serviceTypes: ["vebus", "acsystem", "inverter", "charger"]
		}
		delegate: ListNavigation {
			text: model.device.name
			secondaryText: VenusOS.system_stateToText(stateItem.value)

			onClicked: {
				// Show page for chargers
				if (BackendConnection.serviceTypeFromUid(model.device.serviceUid) === "charger") {
					Global.openDevicePage(model.device.serviceUid)
				} else {
					// Show page for inverter, vebus and acsystem services
					Global.pageManager.pushPage("/pages/invertercharger/OverviewInverterChargerPage.qml",
							{ "serviceUid": model.device.serviceUid })
				}
			}

			VeQuickItem {
				id: stateItem
				uid: model.device.serviceUid + "/State"
			}
		}
	}
}

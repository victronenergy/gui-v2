/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	//% "EV Charging Stations"
	title: qsTrId("evcs_charging_stations")

	GradientListView {
		id: settingsListView

		header: SettingsColumn {
			width: parent.width
			bottomPadding: settingsListView.spacing

			BaseListItem {
				width: parent.width
				height: summary.height

				QuantityTableSummary {
					id: summary

					width: parent.width - Theme.geometry_listItem_content_horizontalMargin
					model: [
						{
							title: "",
							text: CommonWords.total,
							unit: VenusOS.Units_None
						},
						{
							title: CommonWords.power_watts,
							value: Global.evChargers.power,
							unit: VenusOS.Units_Watt
						},
						{
							title: CommonWords.energy,
							value: Global.evChargers.energy,
							unit: VenusOS.Units_Energy_KiloWattHour
						}
					]
				}
			}
		}

		model: Global.evChargers.model
		delegate: ListQuantityGroupNavigation {
			id: evChargerDelegate

			readonly property string statusText: Global.evChargers.chargerStatusToText(model.device.status)

			text: model.device.name
			quantityModel: QuantityObjectModel {
				// Energy is only shown when charging.
				QuantityObject { object: model.device.status === VenusOS.Evcs_Status_Charging ? model.device : null; key: "energy"; unit: VenusOS.Units_Energy_KiloWattHour }
				QuantityObject { object: evChargerDelegate; key: "statusText" }
			}

			onClicked: Global.pageManager.pushPage("/pages/evcs/EvChargerPage.qml", { bindPrefix: model.device.serviceUid })
		}
	}
}

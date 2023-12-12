/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Units

Page {
	id: root

	//% "EV Charging Stations"
	title: qsTrId("evcs_charging_stations")

	GradientListView {
		header: Item {
			width: parent.width
			height: summary.height + Theme.geometry.gradientList.spacing

			ListItemBackground {
				height: summary.y + summary.height

				QuantityTableSummary {
					id: summary

					x: Theme.geometry.listItem.content.horizontalMargin
					width: parent.width - (2 * Theme.geometry.listItem.content.horizontalMargin)

					model: [
						{
							title: "",
							text: CommonWords.total,
							unit: Enums.Units_None
						},
						{
							title: CommonWords.power_watts,
							value: Global.evChargers.power,
							unit: Enums.Units_Watt
						},
						{
							title: CommonWords.energy,
							value: Global.evChargers.energy,
							unit: Enums.Units_Energy_KiloWattHour
						},
						{
							// Extra empty column to create spacing
							title: "",
							value: NaN,
							unit: Enums.Units_None
						},
					]
				}
			}
		}

		model: Global.evChargers.model
		delegate: ListNavigationItem {
			text: model.device.name
			secondaryText: {
				const statusText = Global.evChargers.chargerStatusToText(model.device.status)
				if (model.device.status === Enums.Evcs_Status_Charging) {
					const quantity = Units.getDisplayText(Enums.Units_Energy_KiloWattHour,
							model.device.energy,
							Units.defaultUnitPrecision(Enums.Units_Energy_KiloWattHour))
					return quantity.number + quantity.unit + " | " + statusText
				}
				return statusText
			}

			onClicked: Global.pageManager.pushPage("/pages/evcs/EvChargerPage.qml", { "evCharger": model.device })
		}
	}
}

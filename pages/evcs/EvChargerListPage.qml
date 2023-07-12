/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

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
							unit: VenusOS.Units_None
						},
						{
							title: CommonWords.power_watts,
							value: Global.evChargers.power,
							unit: VenusOS.Units_Watt
						},
						{
							title: CommonWords.energy_evcs,
							value: Global.evChargers.energy,
							unit: VenusOS.Units_Energy_KiloWattHour
						},
						{
							// Extra empty column to create spacing
							title: "",
							value: NaN,
							unit: VenusOS.Units_None
						},
					]
				}
			}
		}

		model: Global.evChargers.model
		delegate: ListNavigationItem {
			text: model.evCharger.name
			secondaryText: {
				const statusText = Global.evChargers.chargerStatusToText(model.evCharger.status)
				if (model.evCharger.status === VenusOS.Evcs_Status_Charging) {
					const energy = isNaN(model.evCharger.energy) ? "--" : model.evCharger.energy.toFixed(1)
					return energy + "kWh | " + statusText
				}
				return statusText
			}

			onClicked: Global.pageManager.pushPage("/pages/evcs/EvChargerPage.qml", { "evCharger": model.evCharger })
		}
	}
}

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
			height: summary.height + Theme.geometry_gradientList_spacing

			ListItemBackground {
				height: summary.y + summary.height

				QuantityTableSummary {
					id: summary

					x: Theme.geometry_listItem_content_horizontalMargin
					width: parent.width - (2 * Theme.geometry_listItem_content_horizontalMargin)

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
			text: model.device.name
			secondaryText: {
				const statusText = Global.evChargers.chargerStatusToText(model.device.status)
				if (model.device.status === VenusOS.Evcs_Status_Charging) {
					const quantity = Units.getDisplayText(VenusOS.Units_Energy_KiloWattHour,
							model.device.energy,
							Units.defaultUnitPrecision(VenusOS.Units_Energy_KiloWattHour))
					return quantity.number + quantity.unit + " | " + statusText
				}
				return statusText
			}

			onClicked: Global.pageManager.pushPage("/pages/evcs/EvChargerPage.qml", { "evCharger": model.device })
		}
	}
}

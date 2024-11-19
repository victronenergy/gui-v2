/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string bindPrefix

	GradientListView {
		model: ObjectModel {
			ListTextItem {
				//% "Capacity"
				text: qsTrId("lynxionsystem_capacity")
				dataItem.uid: root.bindPrefix + "/Capacity"
				allowed: defaultAllowed && dataItem.isValid
			}

			ListTextItem {
				//% "Batteries"
				text: qsTrId("lynxionsystem_batteries")
				dataItem.uid: root.bindPrefix + "/System/NrOfBatteries"
			}

			ListTextItem {
				//% "Parallel"
				text: qsTrId("lynxionsystem_parallel")
				dataItem.uid: root.bindPrefix + "/System/BatteriesParallel"
			}

			ListTextItem {
				//% "Series"
				text: qsTrId("lynxionsystem_series")
				dataItem.uid: root.bindPrefix + "/System/BatteriesSeries"
			}

			ListTextItem {
				//% "Cells per battery"
				text: qsTrId("lynxionsystem_cells_per_battery")
				dataItem.uid: root.bindPrefix + "/System/NrOfCellsPerBattery"
			}

			ListQuantityGroup {
				//% "Min/max cell voltage"
				text: qsTrId("lynxionsystem_min_max_cell_voltage")
				textModel: [
					{ value: minCellVoltage.value, unit: VenusOS.Units_Volt_DC, precision: 3 },
					{ value: maxCellVoltage.value, unit: VenusOS.Units_Volt_DC, precision: 3 },
				]
				allowed: minCellVoltage.isValid && maxCellVoltage.isValid

				VeQuickItem {
					id: minCellVoltage
					uid: root.bindPrefix + "/System/MinCellVoltage"
				}

				VeQuickItem {
					id: maxCellVoltage
					uid: root.bindPrefix + "/System/MaxCellVoltage"
				}
			}

			ListQuantityGroup {
				//% "Min/max cell temperature"
				text: qsTrId("lynxionsystem_min_max_cell_temperature")
				textModel: [
					{
						value: Global.systemSettings.convertFromCelsius(minCellTemperature.value),
						unit: Global.systemSettings.temperatureUnit
					},
					{
						value: Global.systemSettings.convertFromCelsius(maxCellTemperature.value),
						unit: Global.systemSettings.temperatureUnit
					}
				]
				allowed: minCellTemperature.isValid && maxCellTemperature.isValid

				VeQuickItem {
					id: minCellTemperature
					uid: root.bindPrefix + "/System/MinCellTemperature"
				}

				VeQuickItem {
					id: maxCellTemperature
					uid: root.bindPrefix + "/System/MaxCellTemperature"
				}
			}

			ListTextItem {
				//% "Balancing"
				text: qsTrId("lynxionsystem_balancing")
				dataItem.uid: root.bindPrefix + "/Balancing"
				allowed: defaultAllowed && dataItem.seen
				secondaryText: CommonWords.activeOrInactive(dataItem.value)
			}

			ListTextItem {
				//% "Balancer status"
				text: qsTrId("lynxionsystem_balancer_status")
				dataItem.uid: root.bindPrefix + "/Balancer/Status"
				allowed: defaultAllowed && dataItem.seen
				secondaryText: {
					switch (dataItem.value) {
					case VenusOS.Battery_Balancer_Balanced:
						//% "Balanced"
						return qsTrId("lynxionsystem_balancer_balanced")
					case VenusOS.Battery_Balancer_Balancing:
						//% "Balancing"
						return qsTrId("lynxionsystem_balancer_balancing")
					case VenusOS.Battery_Balancer_Imbalance:
						//% "Imbalance"
						return qsTrId("lynxionsystem_balancer_imbalance")
					case VenusOS.Battery_Balancer_Unknown:
					default:
						//% "Unknown"
						return qsTrId("lynxionsystem_balancer_unknown")
					}
				}
			}
		}
	}
}

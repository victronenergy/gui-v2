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
		model: VisibleItemModel {
			ListText {
				//% "Capacity"
				text: qsTrId("lynxionsystem_capacity")
				dataItem.uid: root.bindPrefix + "/Capacity"
				preferredVisible: dataItem.valid
			}

			ListText {
				text: CommonWords.batteries
				dataItem.uid: root.bindPrefix + "/System/NrOfBatteries"
			}

			ListText {
				//% "Parallel"
				text: qsTrId("lynxionsystem_parallel")
				dataItem.uid: root.bindPrefix + "/System/BatteriesParallel"
			}

			ListText {
				//% "Series"
				text: qsTrId("lynxionsystem_series")
				dataItem.uid: root.bindPrefix + "/System/BatteriesSeries"
			}

			ListText {
				//% "Cells per battery"
				text: qsTrId("lynxionsystem_cells_per_battery")
				dataItem.uid: root.bindPrefix + "/System/NrOfCellsPerBattery"
			}

			ListQuantityGroup {
				//% "Min/max cell voltage"
				text: qsTrId("lynxionsystem_min_max_cell_voltage")
				model: QuantityObjectModel {
					QuantityObject { object: minCellVoltage; unit: VenusOS.Units_Volt_DC; precision: 3 }
					QuantityObject { object: maxCellVoltage; unit: VenusOS.Units_Volt_DC; precision: 3 }
				}
				preferredVisible: minCellVoltage.valid && maxCellVoltage.valid

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
				model: QuantityObjectModel {
					QuantityObject { object: minCellTemperature; unit: Global.systemSettings.temperatureUnit }
					QuantityObject { object: maxCellTemperature; unit: Global.systemSettings.temperatureUnit }
				}
				preferredVisible: minCellTemperature.valid && maxCellTemperature.valid

				VeQuickItem {
					id: minCellTemperature
					uid: root.bindPrefix + "/System/MinCellTemperature"
					dataItem.sourceUnit: Units.unitToVeUnit(VenusOS.Units_Temperature_Celsius)
					dataItem.displayUnit: Units.unitToVeUnit(Global.systemSettings.temperatureUnit)
				}

				VeQuickItem {
					id: maxCellTemperature
					uid: root.bindPrefix + "/System/MaxCellTemperature"
					dataItem.sourceUnit: Units.unitToVeUnit(VenusOS.Units_Temperature_Celsius)
					dataItem.displayUnit: Units.unitToVeUnit(Global.systemSettings.temperatureUnit)
				}
			}

			ListText {
				//% "Balancing"
				text: qsTrId("lynxionsystem_balancing")
				dataItem.uid: root.bindPrefix + "/Balancing"
				preferredVisible: dataItem.seen
				secondaryText: CommonWords.activeOrInactive(dataItem.value)
			}

			ListText {
				//% "Balancer status"
				text: qsTrId("lynxionsystem_balancer_status")
				dataItem.uid: root.bindPrefix + "/Balancer/Status"
				preferredVisible: dataItem.seen
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

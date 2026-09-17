/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string bindPrefix

	VeQuickItem {
		id: capacityItem
		uid: root.bindPrefix + "/Capacity"
	}
	VeQuickItem {
		id: minCellVoltageItem
		uid: root.bindPrefix + "/System/MinCellVoltage"
	}
	VeQuickItem {
		id: maxCellVoltageItem
		uid: root.bindPrefix + "/System/MaxCellVoltage"
	}
	VeQuickItem {
		id: minCellTemperatureItem
		uid: root.bindPrefix + "/System/MinCellTemperature"
	}
	VeQuickItem {
		id: maxCellTemperatureItem
		uid: root.bindPrefix + "/System/MaxCellTemperature"
	}

	GradientListView {
		model: DelegateComponentModel {
			DelegateComponent {
				preferredVisible: capacityItem.valid
				ListText {
					//% "Capacity"
					text: qsTrId("lynxionsystem_capacity")
					dataItem.uid: root.bindPrefix + "/Capacity"
				}
			}

			DelegateComponent {
				ListText {
					text: CommonWords.batteries
					dataItem.uid: root.bindPrefix + "/System/NrOfBatteries"
				}
			}

			DelegateComponent {
				ListText {
					//% "Parallel"
					text: qsTrId("lynxionsystem_parallel")
					dataItem.uid: root.bindPrefix + "/System/BatteriesParallel"
				}
			}

			DelegateComponent {
				ListText {
					//% "Series"
					text: qsTrId("lynxionsystem_series")
					dataItem.uid: root.bindPrefix + "/System/BatteriesSeries"
				}
			}

			DelegateComponent {
				ListText {
					//% "Cells per battery"
					text: qsTrId("lynxionsystem_cells_per_battery")
					dataItem.uid: root.bindPrefix + "/System/NrOfCellsPerBattery"
				}
			}

			DelegateComponent {
				preferredVisible: minCellVoltageItem.valid && maxCellVoltageItem.valid
				ListQuantityGroup {
					//% "Min/max cell voltage"
					text: qsTrId("lynxionsystem_min_max_cell_voltage")
					model: QuantityObjectModel {
						QuantityObject { object: minCellVoltage; unit: VenusOS.Units_Volt_DC; decimals: 3 }
						QuantityObject { object: maxCellVoltage; unit: VenusOS.Units_Volt_DC; decimals: 3 }
					}

					VeQuickItem {
						id: minCellVoltage
						uid: root.bindPrefix + "/System/MinCellVoltage"
					}

					VeQuickItem {
						id: maxCellVoltage
						uid: root.bindPrefix + "/System/MaxCellVoltage"
					}
				}
			}

			DelegateComponent {
				preferredVisible: minCellTemperatureItem.valid && maxCellTemperatureItem.valid
				ListQuantityGroup {
					//% "Min/max cell temperature"
					text: qsTrId("lynxionsystem_min_max_cell_temperature")
					model: QuantityObjectModel {
						QuantityObject { object: minCellTemperature; unit: Global.systemSettings.temperatureUnit }
						QuantityObject { object: maxCellTemperature; unit: Global.systemSettings.temperatureUnit }
					}

					VeQuickItem {
						id: minCellTemperature
						uid: root.bindPrefix + "/System/MinCellTemperature"
						sourceUnit: Units.unitToVeUnit(VenusOS.Units_Temperature_Celsius)
						displayUnit: Units.unitToVeUnit(Global.systemSettings.temperatureUnit)
					}

					VeQuickItem {
						id: maxCellTemperature
						uid: root.bindPrefix + "/System/MaxCellTemperature"
						sourceUnit: Units.unitToVeUnit(VenusOS.Units_Temperature_Celsius)
						displayUnit: Units.unitToVeUnit(Global.systemSettings.temperatureUnit)
					}
				}
			}

			DelegateComponent {
				dataItem: VeQuickItem { uid: root.bindPrefix + "/Balancing" }
				preferredVisible: dataItem.seen
				ListText {
					//% "Balancing"
					text: qsTrId("lynxionsystem_balancing")
					dataItem.uid: root.bindPrefix + "/Balancing"
					secondaryText: CommonWords.activeOrInactive(dataItem.value)
				}
			}

			DelegateComponent {
				dataItem: VeQuickItem { uid: root.bindPrefix + "/Balancer/Status" }
				preferredVisible: dataItem.seen
				ListText {
					//% "Balancer status"
					text: qsTrId("lynxionsystem_balancer_status")
					dataItem.uid: root.bindPrefix + "/Balancer/Status"
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
}

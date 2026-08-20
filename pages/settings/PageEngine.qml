/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	required property string bindPrefix

	VeQuickItem {
		id: startsItem
		uid: root.bindPrefix + "/Engine/Starts"
	}
	VeQuickItem {
		id: starterVoltageItem
		uid: root.bindPrefix + "/StarterVoltage"
	}
	VeQuickItem {
		id: heatsinkTemperatureItem
		uid: root.bindPrefix + "/HeatsinkTemperature"
	}
	VeQuickItem {
		id: windingTemperatureItem
		uid: root.bindPrefix + "/Engine/WindingTemperature"
	}
	VeQuickItem {
		id: exhaustTemperatureItem
		uid: root.bindPrefix + "/Engine/ExhaustTemperature"
	}
	VeQuickItem {
		id: coolantTemperatureItem
		uid: root.bindPrefix + "/Engine/CoolantTemperature"
	}
	VeQuickItem {
		id: oilTemperatureItem
		uid: root.bindPrefix + "/Engine/OilTemperature"
	}
	VeQuickItem {
		id: oilPressureItem
		uid: root.bindPrefix + "/Engine/OilPressure"
	}
	VeQuickItem {
		id: loadItem
		uid: root.bindPrefix + "/Engine/Load"
	}

	GradientListView {
		model: DelegateComponentModel {
			DelegateComponent {
				ListQuantity {
					text: CommonWords.speed
					dataItem.uid: root.bindPrefix + "/Engine/Speed"
					unit: VenusOS.Units_RevolutionsPerMinute
				}
			}

			DelegateComponent {
				preferredVisible: loadItem.valid
				ListQuantity {
					//% "Load"
					text: qsTrId("page-engine_load")
					dataItem.uid: root.bindPrefix + "/Engine/Load"
					unit: VenusOS.Units_Percentage
				}
			}

			DelegateComponent {
				preferredVisible: oilPressureItem.valid
				ListQuantity {
					//% "Oil pressure"
					text: qsTrId("page-engine_oil_pressure")
					dataItem.uid: root.bindPrefix + "/Engine/OilPressure"
					unit: VenusOS.Units_Kilopascal
				}
			}

			DelegateComponent {
				preferredVisible: oilTemperatureItem.valid
				ListTemperature {
					//% "Oil temperature"
					text: qsTrId("page-engine_oil_temperature")
					dataItem.uid: root.bindPrefix + "/Engine/OilTemperature"
					decimals: 0
				}
			}

			DelegateComponent {
				preferredVisible: coolantTemperatureItem.valid
				ListTemperature {
					//% "Coolant temperature"
					text: qsTrId("page-engine_coolant_temperature")
					dataItem.uid: root.bindPrefix + "/Engine/CoolantTemperature"
					decimals: 0
				}
			}

			DelegateComponent {
				preferredVisible: exhaustTemperatureItem.valid
				ListTemperature {
					//% "Exhaust temperature"
					text: qsTrId("page-engine_exhaust_temperature")
					dataItem.uid: root.bindPrefix + "/Engine/ExhaustTemperature"
				}
			}

			DelegateComponent {
				preferredVisible: windingTemperatureItem.valid
				ListTemperature {
					//% "Winding temperature"
					text: qsTrId("page-engine_winding_temperature")
					dataItem.uid: root.bindPrefix + "/Engine/WindingTemperature"
				}
			}

			DelegateComponent {
				preferredVisible: heatsinkTemperatureItem.valid
				ListTemperature {
					//% "Heatsink temperature"
					text: qsTrId("genset_heatsink_temperature")
					dataItem.uid: root.bindPrefix + "/HeatsinkTemperature"
				}
			}

			DelegateComponent {
				preferredVisible: starterVoltageItem.valid
				ListQuantity {
					//% "Starter battery voltage"
					text: qsTrId("page-engine_starter_battery_voltage")
					dataItem.uid: root.bindPrefix + "/StarterVoltage"
					unit: VenusOS.Units_Volt_DC
				}
			}

			DelegateComponent {
				preferredVisible: startsItem.valid
				ListText {
					//% "Number of starts"
					text: qsTrId("page-engine_number_of_starts")
					dataItem.uid: root.bindPrefix + "/Engine/Starts"
				}
			}
		}
	}
}

/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	required property string bindPrefix

	GradientListView {
		model: VisibleItemModel {
			ListQuantity {
				text: CommonWords.speed
				dataItem.uid: root.bindPrefix + "/Engine/Speed"
				unit: VenusOS.Units_RevolutionsPerMinute
			}

			ListQuantity {
				//% "Load"
				text: qsTrId("page-engine_load")
				dataItem.uid: root.bindPrefix + "/Engine/Load"
				preferredVisible: dataItem.valid
				unit: VenusOS.Units_Percentage
			}

			ListQuantity {
				//% "Oil pressure"
				text: qsTrId("page-engine_oil_pressure")
				dataItem.uid: root.bindPrefix + "/Engine/OilPressure"
				preferredVisible: dataItem.valid
				unit: VenusOS.Units_Kilopascal
			}

			ListTemperature {
				//% "Oil temperature"
				text: qsTrId("page-engine_oil_temperature")
				preferredVisible: dataItem.valid
				dataItem.uid: root.bindPrefix + "/Engine/OilTemperature"
				decimals: 0
			}

			ListTemperature {
				//% "Coolant temperature"
				text: qsTrId("page-engine_coolant_temperature")
				preferredVisible: dataItem.valid
				dataItem.uid: root.bindPrefix + "/Engine/CoolantTemperature"
				decimals: 0
			}

			ListTemperature {
				//% "Exhaust temperature"
				text: qsTrId("page-engine_exhaust_temperature")
				preferredVisible: dataItem.valid
				dataItem.uid: root.bindPrefix + "/Engine/ExhaustTemperature"
			}

			ListTemperature {
				//% "Winding temperature"
				text: qsTrId("page-engine_winding_temperature")
				preferredVisible: dataItem.valid
				dataItem.uid: root.bindPrefix + "/Engine/WindingTemperature"
			}

			ListTemperature {
				//% "Heatsink temperature"
				text: qsTrId("genset_heatsink_temperature")
				dataItem.uid: root.bindPrefix + "/HeatsinkTemperature"
				preferredVisible: dataItem.valid
			}

			ListQuantity {
				//% "Starter battery voltage"
				text: qsTrId("page-engine_starter_battery_voltage")
				dataItem.uid: root.bindPrefix + "/StarterVoltage"
				preferredVisible: dataItem.valid
				unit: VenusOS.Units_Volt_DC
			}

			ListText {
				//% "Number of starts"
				text: qsTrId("page-engine_number_of_starts")
				dataItem.uid: root.bindPrefix + "/Engine/Starts"
				preferredVisible: dataItem.valid
			}
		}
	}
}

/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil

Page {
	id: root

	property string bindPrefix

	GradientListView {
		model: ObjectModel {
			ListTextItem {
				//% "Capacity"
				text: qsTrId("lynxionsystem_capacity")
				dataItem.uid: root.bindPrefix + "/Capacity"
				visible: defaultVisible && dataItem.isValid
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

			ListQuantityGroup {
				//% "Min/max cell voltage"
				text: qsTrId("lynxionsystem_min_max_cell_voltage")
				textModel: [
					{ value: minCellVoltage.value, unit: VenusOS.Units_Volt },
					{ value: maxCellVoltage.value, unit: VenusOS.Units_Volt },
				]
				visible: minCellVoltage.isValid && maxCellVoltage.isValid

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
						value: Global.systemSettings.convertTemperature(minCellTemperature.value),
						unit: Global.systemSettings.temperatureUnit.value
					},
					{
						value: Global.systemSettings.convertTemperature(maxCellTemperature.value),
						unit: Global.systemSettings.temperatureUnit.value
					}
				]
				visible: minCellTemperature.isValid && maxCellTemperature.isValid

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
				secondaryText: CommonWords.activeOrInactive(dataItem.value)
			}
		}
	}
}

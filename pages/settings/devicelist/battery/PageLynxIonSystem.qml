/*
** Copyright (C) 2023 Victron Energy B.V.
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
				dataSource: root.bindPrefix + "/Capacity"
				visible: defaultVisible && dataValid
			}

			ListTextItem {
				//% "Batteries"
				text: qsTrId("lynxionsystem_batteries")
				dataSource: root.bindPrefix + "/System/NrOfBatteries"
			}

			ListTextItem {
				//% "Parallel"
				text: qsTrId("lynxionsystem_parallel")
				dataSource: root.bindPrefix + "/System/BatteriesParallel"
			}

			ListTextItem {
				//% "Series"
				text: qsTrId("lynxionsystem_series")
				dataSource: root.bindPrefix + "/System/BatteriesSeries"
			}

			ListQuantityGroup {
				//% "Min/max cell voltage"
				text: qsTrId("lynxionsystem_min_max_cell_voltage")
				textModel: [
					{ value: minCellVoltage.value, unit: VenusOS.Units_Volt },
					{ value: maxCellVoltage.value, unit: VenusOS.Units_Volt },
				]
				visible: minCellVoltage.valid && maxCellVoltage.valid

				DataPoint {
					id: minCellVoltage
					source: root.bindPrefix + "/System/MinCellVoltage"
				}

				DataPoint {
					id: maxCellVoltage
					source: root.bindPrefix + "/System/MaxCellVoltage"
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
				visible: minCellTemperature.valid && maxCellTemperature.valid

				DataPoint {
					id: minCellTemperature
					source: root.bindPrefix + "/System/MinCellTemperature"
				}

				DataPoint {
					id: maxCellTemperature
					source: root.bindPrefix + "/System/MaxCellTemperature"
				}
			}

			ListTextItem {
				//% "Balancing"
				text: qsTrId("lynxionsystem_balancing")
				dataSource: root.bindPrefix + "/Balancing"
				secondaryText: CommonWords.activeOrInactive(dataValue)
			}
		}
	}
}

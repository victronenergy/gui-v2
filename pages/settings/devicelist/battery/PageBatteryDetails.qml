/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil
import Victron.Units

Page {
	id: root

	property string bindPrefix
	property var details

	GradientListView {
		model: ObjectModel {
			ListQuantityGroup {
				//% "Lowest cell voltage"
				text: qsTrId("batterydetails_lowest_cell_voltage")
				textModel: [
					{ value: details.minVoltageCellId.value, unit: VenusOS.Units_Volt },
					{ value: details.minCellVoltage.value, unit: VenusOS.Units_Volt },
				]
			}

			ListQuantityGroup {
				//% "Highest cell voltage"
				text: qsTrId("batterydetails_highest_cell_voltage")
				textModel: [
					{ value: details.maxVoltageCellId.value, unit: VenusOS.Units_Volt },
					{ value: details.maxCellVoltage.value, unit: VenusOS.Units_Volt },
				]
			}

			ListQuantityGroup {
				//% "Minimum cell temperature"
				text: qsTrId("batterydetails_minimum_cell_temperature")
				textModel: [
					{
						value: Global.systemSettings.convertTemperature(details.minTemperatureCellId.value),
						unit: Global.systemSettings.temperatureUnit.value
					},
					{
						value: Global.systemSettings.convertTemperature(details.minCellTemperature.value),
						unit: Global.systemSettings.temperatureUnit.value
					}
				]
			}

			ListQuantityGroup {
				//% "Maximum cell temperature"
				text: qsTrId("batterydetails_maximum_cell_temperature")
				textModel: [
					{
						value: Global.systemSettings.convertTemperature(details.maxTemperatureCellId.value),
						unit: Global.systemSettings.temperatureUnit.value
					},
					{
						value: Global.systemSettings.convertTemperature(details.maxCellTemperature.value),
						unit: Global.systemSettings.temperatureUnit.value
					}
				]
			}

			ListTextGroup {
				//% "Battery modules"
				text: qsTrId("batterydetails_modules")
				textModel: [
					//: %1 = number of battery modules that are online
					//% "%1 online"
					qsTrId("devicelist_batterydetails_modules_online").arg(details.modulesOnline.value || "--"),
					//: %1 = number of battery modules that are offline
					//% "%1 offline"
					qsTrId("devicelist_batterydetails_modules_offline").arg(details.modulesOffline.value || "--")
				]
			}

			ListTextGroup {
				//% "Number of modules blocking charge / discharge"
				text: qsTrId("batterydetails_number_of_modules_blocking_charge_discharge")
				textModel: [ details.nrOfModulesBlockingCharge.value, details.nrOfModulesBlockingDischarge.value ]
			}

			ListTextGroup {
				//% "Installed / Available capacity"
				text: qsTrId("batterydetails_installed_available_capacity")
				textModel: [ details.installedCapacity.value, capacity.value ]

				VeQuickItem {
					id: capacity
					uid: root.bindPrefix + "/Capacity"
				}
			}
		}
	}
}

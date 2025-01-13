/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string bindPrefix
	property BatteryDetails details

	GradientListView {
		model: VisibleItemModel {
			ListQuantityGroup {
				//% "Lowest cell voltage"
				text: qsTrId("batterydetails_lowest_cell_voltage")
				textModel: [
					{ value: details.minVoltageCellId.value, visible: details.minVoltageCellId.isValid },
					{ value: details.minCellVoltage.value, unit: VenusOS.Units_Volt_DC, precision: 3 },
				]
				preferredVisible: details.allowsLowestCellVoltage
			}

			ListQuantityGroup {
				//% "Highest cell voltage"
				text: qsTrId("batterydetails_highest_cell_voltage")
				textModel: [
					{ value: details.maxVoltageCellId.value, visible: details.maxVoltageCellId.isValid },
					{ value: details.maxCellVoltage.value, unit: VenusOS.Units_Volt_DC, precision: 3 },
				]
				preferredVisible: details.allowsHighestCellVoltage
			}

			ListQuantityGroup {
				//% "Minimum cell temperature"
				text: qsTrId("batterydetails_minimum_cell_temperature")
				textModel: [
					{
						value: details.minTemperatureCellId.value, visible: details.minTemperatureCellId.isValid
					},
					{
						value: Global.systemSettings.convertFromCelsius(details.minCellTemperature.value),
						unit: Global.systemSettings.temperatureUnit
					}
				]
				preferredVisible: details.allowsMinimumCellTemperature
			}

			ListQuantityGroup {
				//% "Maximum cell temperature"
				text: qsTrId("batterydetails_maximum_cell_temperature")
				textModel: [
					{
						value: details.maxTemperatureCellId.value, visible: details.maxTemperatureCellId.isValid
					},
					{
						value: Global.systemSettings.convertFromCelsius(details.maxCellTemperature.value),
						unit: Global.systemSettings.temperatureUnit
					}
				]
				preferredVisible: details.allowsMaximumCellTemperature
			}

			ListTextGroup {
				//% "Battery modules"
				text: qsTrId("batterydetails_modules")
				textModel: [
					//: %1 = number of battery modules that are online
					//% "%1 online"
					details.modulesOnline.isValid ? qsTrId("devicelist_batterydetails_modules_online").arg(details.modulesOnline.value) : "--",
					//: %1 = number of battery modules that are offline
					//% "%1 offline"
					details.modulesOffline.isValid ? qsTrId("devicelist_batterydetails_modules_offline").arg(details.modulesOffline.value) : "--"
				]
				preferredVisible: details.allowsBatteryModules
			}

			ListTextGroup {
				//% "Number of modules blocking charge / discharge"
				text: qsTrId("batterydetails_number_of_modules_blocking_charge_discharge")
				textModel: [ details.nrOfModulesBlockingCharge.value, details.nrOfModulesBlockingDischarge.value ]
				preferredVisible: details.allowsNumberOfModulesBlockingChargeDischarge
			}

			ListQuantityGroup {
				//% "Installed / Available capacity"
				text: qsTrId("batterydetails_installed_available_capacity")
				textModel: [
					{ value: details.installedCapacity.value, unit: VenusOS.Units_AmpHour },
					{ value: details.capacity.value, unit: VenusOS.Units_AmpHour }
				]
				preferredVisible: details.allowsCapacity
			}

			ListTextGroup {
				//% "Connection information"
				text: qsTrId("batterydetails_connection_information")
				textModel: [ details.connectionInformation.value ]
				preferredVisible: details.connectionInformation.isValid
			}
		}
	}
}

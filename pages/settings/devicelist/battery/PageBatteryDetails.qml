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
				model: QuantityObjectModel {
					QuantityObject { object: details.minVoltageCellId; precision: details.minVoltageCellId.decimals }
					QuantityObject { object: details.minCellVoltage; unit: VenusOS.Units_Volt_DC }
				}
				preferredVisible: details.allowsLowestCellVoltage
			}

			ListQuantityGroup {
				//% "Highest cell voltage"
				text: qsTrId("batterydetails_highest_cell_voltage")
				model: QuantityObjectModel {
					QuantityObject { object: details.maxVoltageCellId; precision: details.maxVoltageCellId.decimals }
					QuantityObject { object: details.maxCellVoltage; unit: VenusOS.Units_Volt_DC }
				}
				preferredVisible: details.allowsHighestCellVoltage
			}

			ListQuantityGroup {
				//% "Minimum cell temperature"
				text: qsTrId("batterydetails_minimum_cell_temperature")
				model: QuantityObjectModel {
					QuantityObject { object: details.minTemperatureCellId; precision: details.minTemperatureCellId.decimals }
					QuantityObject { object: details.minCellTemperature; unit: Global.systemSettings.temperatureUnit }
				}
				preferredVisible: details.allowsMinimumCellTemperature
			}

			ListQuantityGroup {
				//% "Maximum cell temperature"
				text: qsTrId("batterydetails_maximum_cell_temperature")
				model: QuantityObjectModel {
					QuantityObject { object: details.maxTemperatureCellId; precision: details.maxTemperatureCellId.decimals }
					QuantityObject { object: details.maxCellTemperature; unit: Global.systemSettings.temperatureUnit }
				}
				preferredVisible: details.allowsMaximumCellTemperature
			}

			ListQuantityGroup {
				id: batteryModules

				//: %1 = number of battery modules that are online
				//% "%1 online"
				readonly property string onlineText: details.modulesOnline.valid ? qsTrId("devicelist_batterydetails_modules_online").arg(details.modulesOnline.value) : "--"

				//: %1 = number of battery modules that are offline
				//% "%1 offline"
				readonly property string offlineText: details.modulesOffline.valid ? qsTrId("devicelist_batterydetails_modules_offline").arg(details.modulesOffline.value) : "--"

				//% "Battery modules"
				text: qsTrId("batterydetails_modules")
				model: QuantityObjectModel {
					QuantityObject { object: batteryModules; key: "onlineText" }
					QuantityObject { object: batteryModules; key: "offlineText" }
				}
				preferredVisible: details.allowsBatteryModules
			}

			ListQuantityGroup {
				//% "Number of modules blocking charge / discharge"
				text: qsTrId("batterydetails_number_of_modules_blocking_charge_discharge")
				model: QuantityObjectModel {
					QuantityObject { object: details.nrOfModulesBlockingCharge; precision: details.nrOfModulesBlockingCharge.decimals }
					QuantityObject { object: details.nrOfModulesBlockingDischarge; precision: details.nrOfModulesBlockingDischarge.decimals }
				}
				preferredVisible: details.allowsNumberOfModulesBlockingChargeDischarge
			}

			ListQuantityGroup {
				//% "Installed / Available capacity"
				text: qsTrId("batterydetails_installed_available_capacity")
				model: QuantityObjectModel {
					QuantityObject { object: details.installedCapacity; unit: VenusOS.Units_AmpHour }
					QuantityObject { object: details.capacity; unit: VenusOS.Units_AmpHour }
				}
				preferredVisible: details.allowsCapacity
			}

			ListText {
				//% "Connection information"
				text: qsTrId("batterydetails_connection_information")
				secondaryText: details.connectionInformation.value ?? ""
				preferredVisible: details.connectionInformation.valid
			}
		}
	}
}

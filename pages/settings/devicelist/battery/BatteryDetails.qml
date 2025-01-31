/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

// TODO replace this with a QuantityObjectModel, since it filters out non-valid values; the model
// count can be used instead of hasAllowedItem.
QtObject {
	id: root

	property string bindPrefix

	readonly property alias modulesOnline: modulesOnline
	readonly property alias modulesOffline: modulesOffline
	readonly property alias nrOfModulesBlockingCharge: nrOfModulesBlockingCharge
	readonly property alias nrOfModulesBlockingDischarge: nrOfModulesBlockingDischarge
	readonly property alias minCellVoltage: minCellVoltage
	readonly property alias maxCellVoltage: maxCellVoltage
	readonly property alias minCellTemperature: minCellTemperature
	readonly property alias maxCellTemperature: maxCellTemperature
	readonly property alias minVoltageCellId: minVoltageCellId
	readonly property alias maxVoltageCellId: maxVoltageCellId
	readonly property alias minTemperatureCellId: minTemperatureCellId
	readonly property alias maxTemperatureCellId: maxTemperatureCellId
	readonly property alias installedCapacity: installedCapacity
	readonly property alias capacity: capacity
	readonly property alias connectionInformation: connectionInformation

	readonly property bool allowsLowestCellVoltage: minCellVoltage.isValid
	readonly property bool allowsHighestCellVoltage: maxCellVoltage.isValid
	readonly property bool allowsMinimumCellTemperature: minCellTemperature.isValid
	readonly property bool allowsMaximumCellTemperature: maxCellTemperature.isValid
	readonly property bool allowsBatteryModules: modulesOnline.isValid || modulesOffline.isValid
	readonly property bool allowsNumberOfModulesBlockingChargeDischarge: nrOfModulesBlockingCharge.isValid || nrOfModulesBlockingDischarge.isValid
	readonly property bool allowsCapacity: installedCapacity.isValid

	readonly property bool hasAllowedItem: allowsLowestCellVoltage
		|| allowsHighestCellVoltage
		|| allowsMinimumCellTemperature
		|| allowsMaximumCellTemperature
		|| allowsBatteryModules
		|| allowsNumberOfModulesBlockingChargeDischarge
		|| allowsCapacity

	readonly property list<VeQuickItem> _dataItems: [
		VeQuickItem {
			id: modulesOnline
			uid: root.bindPrefix + "/System/NrOfModulesOnline"
		},
		VeQuickItem {
			id: modulesOffline
			uid: root.bindPrefix + "/System/NrOfModulesOffline"
		},
		VeQuickItem {
			id: nrOfModulesBlockingCharge
			uid: root.bindPrefix + "/System/NrOfModulesBlockingCharge"
		},
		VeQuickItem {
			id: nrOfModulesBlockingDischarge
			uid: root.bindPrefix + "/System/NrOfModulesBlockingDischarge"
		},
		VeQuickItem {
			id: minCellVoltage
			uid: root.bindPrefix + "/System/MinCellVoltage"
		},
		VeQuickItem {
			id: maxCellVoltage
			uid: root.bindPrefix + "/System/MaxCellVoltage"
		},
		VeQuickItem {
			id: minCellTemperature
			uid: root.bindPrefix + "/System/MinCellTemperature"
		},
		VeQuickItem {
			id: maxCellTemperature
			uid: root.bindPrefix + "/System/MaxCellTemperature"
		},
		VeQuickItem {
			id: minVoltageCellId
			uid: root.bindPrefix + "/System/MinVoltageCellId"
		},
		VeQuickItem {
			id: maxVoltageCellId
			uid: root.bindPrefix + "/System/MaxVoltageCellId"
		},
		VeQuickItem {
			id: minTemperatureCellId
			uid: root.bindPrefix + "/System/MinTemperatureCellId"
		},
		VeQuickItem {
			id: maxTemperatureCellId
			uid: root.bindPrefix + "/System/MaxTemperatureCellId"
		},
		VeQuickItem {
			id: installedCapacity
			uid: root.bindPrefix + "/InstalledCapacity"
		},
		VeQuickItem {
			id: capacity
			uid: root.bindPrefix + "/Capacity"
		},
		VeQuickItem {
			id: connectionInformation
			uid: root.bindPrefix + "/ConnectionInformation"
		}
	]
}

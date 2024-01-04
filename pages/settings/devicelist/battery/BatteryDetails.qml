/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil

QtObject {
	id: root

	property string bindPrefix
	readonly property bool anyItemValid: {
		for (let i = 0; i < _dataItems.length; ++i) {
			if (_dataItems[i].isValid) {
				return true
			}
		}
		return false
	}

	readonly property alias modulesOnline: modulesOnline
	readonly property alias modulesOffline: modulesOffline
	readonly property alias nrOfModulesBlockingCharge: nrOfModulesBlockingCharge
	readonly property alias nrOfModulesBlockingDischarge: nrOfModulesBlockingDischarge
	readonly property alias nrOfModulesOnline: nrOfModulesOnline
	readonly property alias nrOfModulesOffline: nrOfModulesOffline
	readonly property alias minCellVoltage: minCellVoltage
	readonly property alias maxCellVoltage: maxCellVoltage
	readonly property alias minCellTemperature: minCellTemperature
	readonly property alias maxCellTemperature: maxCellTemperature
	readonly property alias minVoltageCellId: minVoltageCellId
	readonly property alias maxVoltageCellId: maxVoltageCellId
	readonly property alias minTemperatureCellId: minTemperatureCellId
	readonly property alias maxTemperatureCellId: maxTemperatureCellId
	readonly property alias installedCapacity: installedCapacity

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
			id: nrOfModulesOnline
			uid: root.bindPrefix + "/System/NrOfModulesOnline"
		},
		VeQuickItem {
			id: nrOfModulesOffline
			uid: root.bindPrefix + "/System/NrOfModulesOffline"
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
		}
	]
}

/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	property string bindPrefix
	readonly property bool anyItemValid: {
		for (let i = 0; i < _dataPoints.length; ++i) {
			if (_dataPoints[i].valid) {
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

	readonly property list<DataPoint> _dataPoints: [
		DataPoint {
			id: modulesOnline
			source: root.bindPrefix + "/System/NrOfModulesOnline"
		},
		DataPoint {
			id: modulesOffline
			source: root.bindPrefix + "/System/NrOfModulesOffline"
		},
		DataPoint {
			id: nrOfModulesBlockingCharge
			source: root.bindPrefix + "/System/NrOfModulesBlockingCharge"
		},
		DataPoint {
			id: nrOfModulesBlockingDischarge
			source: root.bindPrefix + "/System/NrOfModulesBlockingDischarge"
		},
		DataPoint {
			id: nrOfModulesOnline
			source: root.bindPrefix + "/System/NrOfModulesOnline"
		},
		DataPoint {
			id: nrOfModulesOffline
			source: root.bindPrefix + "/System/NrOfModulesOffline"
		},
		DataPoint {
			id: minCellVoltage
			source: root.bindPrefix + "/System/MinCellVoltage"
		},
		DataPoint {
			id: maxCellVoltage
			source: root.bindPrefix + "/System/MaxCellVoltage"
		},
		DataPoint {
			id: minCellTemperature
			source: root.bindPrefix + "/System/MinCellTemperature"
		},
		DataPoint {
			id: maxCellTemperature
			source: root.bindPrefix + "/System/MaxCellTemperature"
		},
		DataPoint {
			id: minVoltageCellId
			source: root.bindPrefix + "/System/MinVoltageCellId"
		},
		DataPoint {
			id: maxVoltageCellId
			source: root.bindPrefix + "/System/MaxVoltageCellId"
		},
		DataPoint {
			id: minTemperatureCellId
			source: root.bindPrefix + "/System/MinTemperatureCellId"
		},
		DataPoint {
			id: maxTemperatureCellId
			source: root.bindPrefix + "/System/MaxTemperatureCellId"
		},
		DataPoint {
			id: installedCapacity
			source: root.bindPrefix + "/InstalledCapacity"
		}
	]
}

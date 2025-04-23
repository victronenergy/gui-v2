/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	required property string bindPrefix

	readonly property VeQuickItem deepestDischarge: VeQuickItem {
		uid: root.bindPrefix + "/History/DeepestDischarge"
	}
	readonly property VeQuickItem lastDischarge: VeQuickItem {
		uid: root.bindPrefix + "/History/LastDischarge"
	}
	readonly property VeQuickItem averageDischarge: VeQuickItem {
		uid: root.bindPrefix + "/History/AverageDischarge"
	}
	readonly property VeQuickItem chargeCycles: VeQuickItem {
		uid: root.bindPrefix + "/History/ChargeCycles"
	}
	readonly property VeQuickItem fullDischarges: VeQuickItem {
		uid: root.bindPrefix + "/History/FullDischarges"
	}
	readonly property VeQuickItem totalAhDrawn: VeQuickItem {
		uid: root.bindPrefix + "/History/TotalAhDrawn"
	}
	readonly property VeQuickItem minimumVoltage: VeQuickItem {
		uid: root.bindPrefix + "/History/MinimumVoltage"
	}
	readonly property VeQuickItem maximumVoltage: VeQuickItem {
		uid: root.bindPrefix + "/History/MaximumVoltage"
	}
	readonly property VeQuickItem minimumCellVoltage: VeQuickItem {
		uid: root.bindPrefix + "/History/MinimumCellVoltage"
	}
	readonly property VeQuickItem maximumCellVoltage: VeQuickItem {
		uid: root.bindPrefix + "/History/MaximumCellVoltage"
	}
	readonly property VeQuickItem timeSinceLastFullCharge: VeQuickItem {
		uid: root.bindPrefix + "/History/TimeSinceLastFullCharge"
	}
	readonly property VeQuickItem automaticSyncs: VeQuickItem {
		uid: root.bindPrefix + "/History/AutomaticSyncs"
	}
	readonly property VeQuickItem lowVoltageAlarms: VeQuickItem {
		uid: root.bindPrefix + "/History/LowVoltageAlarms"
	}
	readonly property VeQuickItem highVoltageAlarms: VeQuickItem {
		uid: root.bindPrefix + "/History/HighVoltageAlarms"
	}
	readonly property VeQuickItem lowStarterVoltageAlarms: VeQuickItem {
		uid: root.bindPrefix + "/History/LowStarterVoltageAlarms"
	}
	readonly property VeQuickItem highStarterVoltageAlarms: VeQuickItem {
		uid: root.bindPrefix + "/History/HighStarterVoltageAlarms"
	}
	readonly property VeQuickItem minimumStarterVoltage: VeQuickItem {
		uid: root.bindPrefix + "/History/MinimumStarterVoltage"
	}
	readonly property VeQuickItem maximumStarterVoltage: VeQuickItem {
		uid: root.bindPrefix + "/History/MaximumStarterVoltage"
	}
	readonly property VeQuickItem minimumTemperature: VeQuickItem {
		uid: root.bindPrefix + "/History/MinimumTemperature"
		sourceUnit: Units.unitToVeUnit(VenusOS.Units_Temperature_Celsius)
		displayUnit: Units.unitToVeUnit(Global.systemSettings.temperatureUnit)
	}
	readonly property VeQuickItem maximumTemperature: VeQuickItem {
		uid: root.bindPrefix + "/History/MaximumTemperature"
		sourceUnit: Units.unitToVeUnit(VenusOS.Units_Temperature_Celsius)
		displayUnit: Units.unitToVeUnit(Global.systemSettings.temperatureUnit)
	}
	readonly property VeQuickItem dischargedEnergy: VeQuickItem {
		uid: root.bindPrefix + "/History/DischargedEnergy"
	}
	readonly property VeQuickItem chargedEnergy: VeQuickItem {
		uid: root.bindPrefix + "/History/ChargedEnergy"
	}

	readonly property VeQuickItem hasStarterVoltage: VeQuickItem {
		uid: root.bindPrefix + "/Settings/HasStarterVoltage"
	}
	readonly property VeQuickItem hasTemperature: VeQuickItem {
		uid: root.bindPrefix + "/Settings/HasTemperature"
	}

	readonly property bool allowsDeepestDischarge: deepestDischarge.valid
	readonly property bool allowsLastDischarge: lastDischarge.valid
	readonly property bool allowsAverageDischarge: averageDischarge.valid
	readonly property bool allowsChargeCycles: chargeCycles.valid
	readonly property bool allowsFullDischarges: fullDischarges.valid
	readonly property bool allowsTotalAhDrawn: totalAhDrawn.valid
	readonly property bool allowsMinimumVoltage: minimumVoltage.valid
	readonly property bool allowsMaximumVoltage: maximumVoltage.valid
	readonly property bool allowsMinimumCellVoltage: minimumCellVoltage.valid
	readonly property bool allowsMaximumCellVoltage: maximumCellVoltage.valid
	readonly property bool allowsTimeSinceLastFullCharge: timeSinceLastFullCharge.valid
	readonly property bool allowsAutomaticSyncs: automaticSyncs.valid
	readonly property bool allowsLowVoltageAlarms: lowVoltageAlarms.valid
	readonly property bool allowsHighVoltageAlarms: highVoltageAlarms.valid
	readonly property bool allowsLowStarterVoltageAlarms: lowStarterVoltageAlarms.valid && hasStarterVoltage.valid && hasStarterVoltage.value
	readonly property bool allowsHighStarterVoltageAlarms: highStarterVoltageAlarms.valid && hasStarterVoltage.valid && hasStarterVoltage.value
	readonly property bool allowsMinimumStarterVoltage: minimumStarterVoltage.valid && hasStarterVoltage.valid && hasStarterVoltage.value
	readonly property bool allowsMaximumStarterVoltage: maximumStarterVoltage.valid && hasStarterVoltage.valid && hasStarterVoltage.value
	readonly property bool allowsMinimumTemperature: minimumTemperature.valid && hasTemperature.value === 1
	readonly property bool allowsMaximumTemperature: maximumTemperature.valid && hasTemperature.value === 1
	readonly property bool allowsDischargedEnergy: dischargedEnergy.valid
	readonly property bool allowsChargedEnergy: chargedEnergy.valid

	readonly property bool hasAllowedItem: allowsDeepestDischarge
		|| allowsLastDischarge
		|| allowsAverageDischarge
		|| allowsChargeCycles
		|| allowsFullDischarges
		|| allowsTotalAhDrawn
		|| allowsMinimumVoltage
		|| allowsMaximumVoltage
		|| allowsMinimumCellVoltage
		|| allowsMaximumCellVoltage
		|| allowsTimeSinceLastFullCharge
		|| allowsAutomaticSyncs
		|| allowsLowVoltageAlarms
		|| allowsHighVoltageAlarms
		|| allowsLowStarterVoltageAlarms
		|| allowsHighStarterVoltageAlarms
		|| allowsMinimumStarterVoltage
		|| allowsMaximumStarterVoltage
		|| allowsMinimumTemperature
		|| allowsMaximumTemperature
		|| allowsDischargedEnergy
		|| allowsChargedEnergy
}

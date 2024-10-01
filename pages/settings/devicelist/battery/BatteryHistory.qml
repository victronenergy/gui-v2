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
	}
	readonly property VeQuickItem maximumTemperature: VeQuickItem {
		uid: root.bindPrefix + "/History/MaximumTemperature"
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

	readonly property bool allowsDeepestDischarge: deepestDischarge.isValid
	readonly property bool allowsLastDischarge: lastDischarge.isValid
	readonly property bool allowsAverageDischarge: averageDischarge.isValid
	readonly property bool allowsChargeCycles: chargeCycles.isValid
	readonly property bool allowsFullDischarges: fullDischarges.isValid
	readonly property bool allowsTotalAhDrawn: totalAhDrawn.isValid
	readonly property bool allowsMinimumVoltage: minimumVoltage.isValid
	readonly property bool allowsMaximumVoltage: maximumVoltage.isValid
	readonly property bool allowsMinimumCellVoltage: minimumCellVoltage.isValid
	readonly property bool allowsMaximumCellVoltage: maximumCellVoltage.isValid
	readonly property bool allowsTimeSinceLastFullCharge: timeSinceLastFullCharge.isValid
	readonly property bool allowsAutomaticSyncs: automaticSyncs.isValid
	readonly property bool allowsLowVoltageAlarms: lowVoltageAlarms.isValid
	readonly property bool allowsHighVoltageAlarms: highVoltageAlarms.isValid
	readonly property bool allowsLowStarterVoltageAlarms: lowStarterVoltageAlarms.isValid && hasStarterVoltage.isValid && hasStarterVoltage.value
	readonly property bool allowsHighStarterVoltageAlarms: highStarterVoltageAlarms.isValid && hasStarterVoltage.isValid && hasStarterVoltage.value
	readonly property bool allowsMinimumStarterVoltage: minimumStarterVoltage.isValid && hasStarterVoltage.isValid && hasStarterVoltage.value
	readonly property bool allowsMaximumStarterVoltage: maximumStarterVoltage.isValid && hasStarterVoltage.isValid && hasStarterVoltage.value
	readonly property bool allowsMinimumTemperature: minimumTemperature.isValid && hasTemperature.value === 1
	readonly property bool allowsMaximumTemperature: maximumTemperature.isValid && hasTemperature.value === 1
	readonly property bool allowsDischargedEnergy: dischargedEnergy.isValid
	readonly property bool allowsChargedEnergy: chargedEnergy.isValid

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

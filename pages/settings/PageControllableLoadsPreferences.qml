/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	VeQuickItem {
		id: batteryLifeSupportItem
		uid: BackendConnection.serviceUidForType("opportunityloads") + "/BatteryLifeSupport"
	}
	VeQuickItem {
		id: nominalInverterUtilizationLimitItem
		uid: BackendConnection.serviceUidForType("opportunityloads") + "/NominalInverterUtilizationLimit"
	}
	VeQuickItem {
		id: pauseWhenOffgridItem
		uid: BackendConnection.serviceUidForType("opportunityloads") + "/PauseWhenOffgrid"
	}

	GradientListView {
		id: gradientListView

		model: DelegateComponentModel {
			DelegateComponent {
				SettingsListHeader {
					//% "General"
					text: qsTrId("page_controllable_loads_preferences_general")
				}
			}

			DelegateComponent {
				preferredVisible: pauseWhenOffgridItem.valid
				ListSwitch {
					//% "Pause if no AC input is connected"
					text: qsTrId("page_controllable_loads_preferences_pause_if_no_ac")
					dataItem.uid: BackendConnection.serviceUidForType("opportunityloads") + "/PauseWhenOffgrid"
				}
			}

			DelegateComponent {
				preferredVisible: nominalInverterUtilizationLimitItem.valid
				ListQuantityField {
					unit: VenusOS.Units_Percentage
					//% "Nominal inverter utilisation limit"
					text: qsTrId("pagecontrollableloads_preferences_nominal_inverter_utilization_limit")
					dataItem.uid: BackendConnection.serviceUidForType("opportunityloads") + "/NominalInverterUtilizationLimit"
				}
			}

			DelegateComponent {
				SettingsListHeader {
					//% "BatteryLife compatibility"
					text: qsTrId("page_controllable_loads_preferences_battery_life_compatibility")
				}
			}

			DelegateComponent {
				id: batteryLifeSupportSwitchDC
				dataItem: VeQuickItem { uid: BackendConnection.serviceUidForType("opportunityloads") + "/BatteryLifeSupport" }
				preferredVisible: batteryLifeSupportItem.valid
				ListSwitch {
					id: batteryLifeSupportSwitch
					//% "Pause after several days without full charge"
					text: qsTrId("page_controllable_loads_preferences_pause_after_several_days_without_full_charge")
					dataItem.uid: BackendConnection.serviceUidForType("opportunityloads") + "/BatteryLifeSupport"
				}
			}

			DelegateComponent {
				preferredVisible: batteryLifeSupportSwitchDC.dataItem.valid
				PrimaryListLabel {
					//% "Only applies when using Optimized with BatteryLife. Opportunity Loads automatically resumes after a full charge."
					text: qsTrId("page_controllable_loads_preferences_only_applies_when_using_optimized_with_battery_life")
				}
			}
		}
	}
}

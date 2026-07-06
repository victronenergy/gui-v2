/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	GradientListView {
		id: gradientListView

		model: VisibleItemModel {
			SettingsListHeader {
				//% "General"
				text: qsTrId("page_controllable_loads_preferences_general")
			}

			ListSwitch {
				preferredVisible: dataItem.valid
				//% "Pause if no AC input is connected"
				text: qsTrId("page_controllable_loads_preferences_pause_if_no_ac")
				dataItem.uid: BackendConnection.serviceUidForType("opportunityloads") + "/PauseWhenOffgrid"
			}

			ListQuantityField {
				preferredVisible: dataItem.valid
				unit: VenusOS.Units_Percentage
				//% "Nominal inverter utilisation limit"
				text: qsTrId("pagecontrollableloads_preferences_nominal_inverter_utilization_limit")
				dataItem.uid: BackendConnection.serviceUidForType("opportunityloads") + "/NominalInverterUtilizationLimit"
			}

			SettingsListHeader {
				//% "BatteryLife compatibility"
				text: qsTrId("page_controllable_loads_preferences_battery_life_compatibility")
			}

			ListSwitch {
				id: batteryLifeSupportSwitch
				preferredVisible: dataItem.valid
				//% "Pause after several days without full charge"
				text: qsTrId("page_controllable_loads_preferences_pause_after_several_days_without_full_charge")
				dataItem.uid: BackendConnection.serviceUidForType("opportunityloads") + "/BatteryLifeSupport"
			}

			PrimaryListLabel {
				//% "Only applies when using Optimized with BatteryLife. Opportunity Loads automatically resumes after a full charge."
				text: qsTrId("page_controllable_loads_preferences_only_applies_when_using_optimized_with_battery_life")
				preferredVisible: batteryLifeSupportSwitch.dataItem.valid
			}
		}
	}
}

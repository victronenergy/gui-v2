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
				//% "Pause Opportunity Loads if no AC input is connected"
				text: qsTrId("page_controllable_loads_preferences_pause_opportunity_loads_if_no_ac")
				dataItem.uid: BackendConnection.serviceUidForType("opportunityloads") + "/PauseWhenOffgrid"
			}

			ListQuantityField {
				preferredVisible: dataItem.valid
				unit: VenusOS.Units_Percentage
				//% "Nominal inverter utilization limit"
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
				//% "Pause Opportunity Loads after several days without full charge"
				text: qsTrId("page_controllable_loads_preferences_pause_opportunity_load_when_active_soc_limit_exceeds_85")
				dataItem.uid: BackendConnection.serviceUidForType("opportunityloads") + "/BatteryLifeSupport"
			}

			PrimaryListLabel {
				//% "Only applies when using Optimized with BatteryLife. Opportunity Loads automatically resumes after a full charge."
				text: qsTrId("page_controllable_loads_preferences_this_helps")
				preferredVisible: batteryLifeSupportSwitch.dataItem.valid
			}
		}
	}
}

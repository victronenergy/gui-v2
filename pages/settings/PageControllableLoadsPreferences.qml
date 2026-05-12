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
				text: qsTrId("page_controllable_loads_preferences_pause_opportunity_loads")
				dataItem.uid: BackendConnection.serviceUidForType("opportunityloads") + "/PauseWhenOffgrid"
			}

			ListQuantityField {
				preferredVisible: dataItem.valid
				unit: VenusOS.Units_Percentage
				//% "Nominal inverter utilization limit"
				text: qsTrId("pagecontrollableloads_preferences_nominal_inverter_utilization_limit")
				dataItem.uid: BackendConnection.serviceUidForType("opportunityloads") + "/NominalInverterUtilizationLimit"
				//% "Limits how much of the inverter/charger’s nominal power the algorithm plans to use to convert DC-coupled PV to AC for base loads and scheduled loads."
				caption: qsTrId("pagecontrollableloads_preferences_limits_how_much")
			}

			SettingsListHeader {
				//% "BatteryLife compatibility"
				text: qsTrId("page_controllable_loads_preferences_battery_life_compatibility")
			}

			ListSwitch {
				preferredVisible: dataItem.valid
				//% "Pause Opportunity Loads when Active SOC limit exceeds 85%"
				text: qsTrId("page_controllable_loads_preferences_pause_opportunity_loads")
				dataItem.uid: BackendConnection.serviceUidForType("opportunityloads") + "/BatteryLifeSupport"
				//% "This helps the BatteryLife algorithm recharge the battery to 100%."
				caption: qsTrId("page_controllable_loads_preferences_this_helps")
			}
		}
	}
}

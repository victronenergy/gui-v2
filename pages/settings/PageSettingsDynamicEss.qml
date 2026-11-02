/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	GradientListView {
		model: VisibleItemModel {
			ListRadioButtonGroup {
				id: dEssMode
				text: CommonWords.mode
				dataItem.uid: Services.settings.serviceUid + "/Settings/DynamicEss/Mode"
				interactive: opportunityLoads.value !== 1
				//% "Dynamic ESS cannot be enabled while Opportunity Loads is enabled. Disable Opportunity Loads first."
				caption: !interactive ? qsTrId("settings_ess_disable_ol_first")
						//% "Dynamic ESS has not been set up yet. Set it up on the VRM Portal first."
						: !(batteryCapacity.value > 0) ? qsTrId("settings_ess_dess_setup_in_vrm")
						: ""
				optionModel: [
					{ display: CommonWords.off, value: 0 },
					{ display: CommonWords.auto, value: 1 }
				]

				VeQuickItem {
					id: opportunityLoads
					uid: BackendConnection.serviceUidForType("platform") + "/Services/OpportunityLoads/Mode"
				}

				VeQuickItem {
					id: batteryCapacity
					uid: Services.settings.serviceUid + "/Settings/DynamicEss/BatteryCapacity"
				}
			}

			ListText {
				text: CommonWords.status
				dataItem.uid: Services.system.serviceUid + "/DynamicEss/Active"
				secondaryText: {
					switch (dataItem.value) {
					case 0: return CommonWords.inactive_status
					case 1: return CommonWords.auto
					//% "Buying"
					case 2: return qsTrId("settings_ess_buying")
					//% "Selling"
					case 3: return qsTrId("settings_ess_selling")
					default: return ""
					}
				}
			}

			ListQuantity {
				//% "Target SOC"
				text: qsTrId("settings_ess_target_soc")
				preferredVisible: dEssMode.dataItem.value === 1
				dataItem.uid: Services.system.serviceUid + "/DynamicEss/TargetSoc"
				unit: VenusOS.Units_Percentage
			}
		}
	}
}

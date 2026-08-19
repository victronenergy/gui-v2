/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	GradientListView {
		model: DelegateComponentModel {
			DelegateComponent {
				id: dEssModeDC
				dataItem: VeQuickItem { uid: Global.systemSettings.serviceUid + "/Settings/DynamicEss/Mode" }
				ListRadioButtonGroup {
					id: dEssMode
					text: CommonWords.mode
					dataItem.uid: Global.systemSettings.serviceUid + "/Settings/DynamicEss/Mode"
					interactive: opportunityLoads.value !== 1
					//% "Dynamic ESS cannot be enabled while Opportunity Loads is enabled. Disable Opportunity Loads first."
					caption: interactive ? "" : qsTrId("settings_ess_disable_ol_first")
					optionModel: [
						{ display: CommonWords.off, value: 0 },
						{ display: CommonWords.auto, value: 1 }
					]

					VeQuickItem {
						id: opportunityLoads
						uid: BackendConnection.serviceUidForType("platform") + "/Services/OpportunityLoads/Mode"
					}
				}
			}

			DelegateComponent {
				ListText {
					text: CommonWords.status
					dataItem.uid: Global.system.serviceUid + "/DynamicEss/Active"
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
			}

			DelegateComponent {
				preferredVisible: dEssModeDC.dataItem.value === 1
				ListQuantity {
					//% "Target SOC"
					text: qsTrId("settings_ess_target_soc")
					dataItem.uid: Global.system.serviceUid + "/DynamicEss/TargetSoc"
					unit: VenusOS.Units_Percentage
				}
			}
		}
	}
}

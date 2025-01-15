/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	GradientListView {
		model: ObjectModel {
			ListRadioButtonGroup {
				id: dEssMode
				text: CommonWords.mode
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/DynamicEss/Mode"
				optionModel: [
					{ display: CommonWords.off, value: 0 },
					{ display: CommonWords.auto, value: 1 }
				]
			}

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

			ListQuantity {
				//% "Target SOC"
				text: qsTrId("settings_ess_target_soc")
				preferredVisible: dEssMode.dataItem.value === 1
				dataItem.uid: Global.system.serviceUid + "/DynamicEss/TargetSoc"
				unit: VenusOS.Units_Percentage
			}
		}
	}
}

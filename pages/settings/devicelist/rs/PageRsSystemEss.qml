/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string bindPrefix

	VeQuickItem {
		id: dEssModeItem

		uid: Global.systemSettings.serviceUid + "/Settings/DynamicEss/Mode"
	}

	VeQuickItem {
		id: essMinSocItem
		uid: bindPrefix + "/Settings/Ess/MinimumSocLimit"
	}

	GradientListView {
		model: ObjectModel {
			ListRadioButtonGroup {
				id: essMode
				text: CommonWords.mode
				optionModel: Global.ess.stateModel
				dataItem.uid: root.bindPrefix + "/Settings/Ess/Mode"
			}

			ListButton {
				//% "Minimum SOC (unless grid fails)"
				text: qsTrId("settings_rs_ess_min_soc")
				button.text: Units.getCombinedDisplayText(VenusOS.Units_Percentage, essMinSocItem.value)
				onClicked: Global.dialogLayer.open(minSocDialogComponent)

				Component {
					id: minSocDialogComponent

					ESSMinimumSOCDialog {
						minimumStateOfCharge: essMinSocItem.value
						onAccepted: essMinSocItem.setValue(minimumStateOfCharge)
					}
				}
			}

			ListQuantity {
				//% "Active SOC limit"
				text: qsTrId("settings_rs_active_soc_limit")
				allowed: defaultAllowed
					&& essMode.dataItem.value === VenusOS.Ess_State_OptimizedWithBatteryLife
				dataItem.uid: root.bindPrefix + "/Ess/ActiveSocLimit"
				unit: VenusOS.Units_Percentage
			}

			ListNavigation {
				//% "Dynamic ESS"
				text: qsTrId("settings_rs_ess_dess")
				allowed: dEssModeItem.value > 0 || Global.systemSettings.canAccess(VenusOS.User_AccessType_Service)
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/PageSettingsDynamicEss.qml",
							{ title: text })
				}
			}
		}
	}
}

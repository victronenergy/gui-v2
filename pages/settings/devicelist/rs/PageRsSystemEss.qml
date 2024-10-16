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

	GradientListView {
		model: ObjectModel {
			ListRadioButtonGroup {
				id: essMode
				text: CommonWords.mode
				optionModel: Global.ess.stateModel
				dataItem.uid: root.bindPrefix + "/Settings/Ess/Mode"
			}

			ListSpinBox {
				//% "Minimum SOC (unless grid fails)"
				text: qsTrId("settings_rs_ess_min_soc")
				allowed: essMode.dataItem.value < 2 // Optimised
				dataItem.uid: root.bindPrefix + "/Settings/Ess/MinimumSocLimit"
				suffix: Units.defaultUnitString(VenusOS.Units_Percentage)
				to: 100
				stepSize: 5
			}

			ListNavigationItem {
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

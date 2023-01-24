/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "/components/Utils.js" as Utils

Page {
	id: root

	property string bindPrefix: "com.victronenergy.settings/Settings/Fronius"
	property DataPoint inverterIdsItem: DataPoint { source: bindPrefix + "/InverterIds" }


	SettingsListView {
		model: inverterIdsItem.value ? inverterIdsItem.value.split(',') : []
		delegate: SettingsListNavigationItem {
			id: menu

			property string uniqueId: modelData
			property string inverterPath: bindPrefix + "/Inverters/" + uniqueId
			property DataPoint customNameItem: DataPoint { source: inverterPath + "/CustomName" }
			property DataPoint phaseItem: DataPoint { source: inverterPath + "/Phase" }
			property DataPoint positionItem: DataPoint { source: inverterPath + "/Position" }
			property DataPoint serialNumberItem: DataPoint { source: inverterPath + "/SerialNumber" }

			onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsFroniusInverter.qml", {"title": menu.text, "uniqueId": menu.uniqueId})
			text: customNameItem.value || serialNumberItem.value || '--'
			secondaryText: {
				switch (positionItem.value) {
				case 0: {
					switch (phaseItem.value) {
					case 0: {
						//% "AC-In1 MP"
						return qsTrId("page_setting_fronius_inverters_ac_in1_mp")
					}
					case 1:
					case 2:
					case 3: {
						//% "AC-In1 L%1"
						return qsTrId("page_setting_fronius_inverters_ac_in1_l").arg(phaseItem.value)
					}
					default: {
						//% "AC-In1 --"
						return qsTrId("page_setting_fronius_inverters_ac_in1_phase_unknown")
					}
					}
				}
				case 1: {
					switch (phaseItem.value) {
					case 0: {
						//% "AC-Out MP"
						return qsTrId("page_setting_fronius_inverters_ac_out_mp")
					}
					case 1:
					case 2:
					case 3: {
						//% "AC-Out L%1"
						return qsTrId("page_setting_fronius_inverters_ac_out_l").arg(phaseItem.value)
					}
					default: {
						//% "AC-Out --"
						return qsTrId("page_setting_fronius_inverters_ac_out_phase_unknown")
					}
					}
				}

				case 2: {
					switch (phaseItem.value) {
					case 0: {
						//% "AC-In2 MP"
						return qsTrId("page_setting_fronius_inverters_ac_in2_mp")
					}
					case 1:
					case 2:
					case 3: {
						//% "AC-In2 L%1"
						return qsTrId("page_setting_fronius_inverters_ac_in2_l1").arg(phaseItem.value)
					}
					default: {
						//% "AC-In2 --"
						return qsTrId("page_setting_fronius_inverters_ac_in2_phase_unknown")
					}
					}
				}

				default: {
					switch (phaseItem.value) {
					case 0: {
						//% "AC-In1 MP"
						return qsTrId("page_setting_fronius_inverters_ac_in1_mp")
					}
					case 1:
					case 2:
					case 3: {
						//% "AC-In1 L%1"
						return qsTrId("page_setting_fronius_inverters_ac_in1_l1").arg(phaseItem.value)
					}
					default: {
						//% "AC-In1 --"
						return qsTrId("page_setting_fronius_inverters_ac_in1_unknown")
					}
					}
				}
				}
			}
		}
	}
}

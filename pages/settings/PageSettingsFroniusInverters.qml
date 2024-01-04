/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil
import Victron.Utils

Page {
	id: root

	property string bindPrefix: Global.systemSettings.serviceUid + "/Settings/Fronius"

	GradientListView {
		model: VeQItemTableModel {
			uids: BackendConnection.type === BackendConnection.DBusSource
				  ? ["dbus/" + bindPrefix + "/Inverters"]
				  : BackendConnection.type === BackendConnection.MqttSource
					? ["mqtt/settings/0/Settings/Fronius/Inverters"]
					: []

			flags: VeQItemTableModel.AddChildren |
				   VeQItemTableModel.AddNonLeaves |
				   VeQItemTableModel.DontAddItem
		}
		delegate: ListNavigationItem {
			id: menu

			property string inverterPath: model.uid
			property VeQuickItem customNameItem: VeQuickItem { uid: inverterPath + "/CustomName" }
			property VeQuickItem phaseItem: VeQuickItem { uid: inverterPath + "/Phase" }
			property VeQuickItem positionItem: VeQuickItem { uid: inverterPath + "/Position" }
			property VeQuickItem serialNumberItem: VeQuickItem { uid: inverterPath + "/SerialNumber" }

			onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsFroniusInverter.qml", {"title": menu.text, "bindPrefix": menu.inverterPath})
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

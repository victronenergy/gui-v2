/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import QtQuick.Controls.impl as CP

Page {
	id: root

	required property string bindPrefix

	VeQuickItem {
		id: bmsPresentItem
		uid: root.bindPrefix + "/Settings/BmsPresent"
	}
	VeQuickItem {
		id: chargeCurrentItem
		uid: root.bindPrefix + "/Link/ChargeCurrent"
	}
	VeQuickItem {
		id: chargeVoltageItem
		uid: root.bindPrefix + "/Link/ChargeVoltage"
	}
	VeQuickItem {
		id: networkModeItem
		uid: root.bindPrefix + "/Link/NetworkMode"
	}

	GradientListView {
		id: chargerListView

		model: DelegateComponentModel {
			DelegateComponent {
				id: networkModeEnabledDC
				dataItem: VeQuickItem { uid: root.bindPrefix + "/Link/NetworkMode" }
				preferredVisible: networkModeItem.valid
				ListText {
					id: networkModeEnabled
					//% "Networked"
					text: qsTrId("charger_networked")
					dataItem.uid: root.bindPrefix + "/Link/NetworkMode"
					secondaryText: dataItem.valid ? CommonWords.yesOrNo(dataItem.value & 1) : ""
				}
			}

			DelegateComponent {
				ListText {
					text: CommonWords.network_status
					secondaryText: Global.systemSettings.networkStatusToText(dataItem.value)
					dataItem.uid: root.bindPrefix + "/Link/NetworkStatus"
				}
			}

			DelegateComponent {
				id: networkModeModeDC
				dataItem: VeQuickItem { uid: root.bindPrefix + "/Link/NetworkMode" }
				preferredVisible: networkModeItem.valid && networkModeEnabledDC.dataItem.value
				ListText {
					id: networkModeMode
					//% "Mode setting"
					text: qsTrId("charger_mode_setting")
					secondaryText: {
						if (!dataItem.valid) {
							return ""
						}
						switch (dataItem.value & 0xE) {
						case 0:
							//% "Standalone"
							return qsTrId("charger_standalone")
						case 2:
							//% "Charge"
							return qsTrId("charger_charge")
						case 4:
							//% "External control"
							return qsTrId("charger_external_control")
						case 6:
							//% "Charge & HUB-1"
							return qsTrId("charger_charge_hub_1")
						case 8:
							//% "BMS"
							return qsTrId("charger_bms")
						case 0xA:
							//% "Charge & BMS"
							return qsTrId("charger_charge_bms")
						case 0xC:
							//% "Ext. Control & BMS"
							return qsTrId("charger_ext_control_bms")
						case 0xE:
							//% "Charge, Hub-1 & BMS"
							return qsTrId("charger_charge_hub_1_bms")
						default:
							return ""
						}
					}
					dataItem.uid: root.bindPrefix + "/Link/NetworkMode"
				}
			}

			DelegateComponent {
				dataItem: VeQuickItem { uid: root.bindPrefix + "/Link/NetworkMode" }
				preferredVisible: networkModeItem.valid && networkModeEnabledDC.dataItem.value && ((dataItem.value & 0x30) > 0x00)
				ListText {
					//% "Master setting"
					text: qsTrId("charger_master_setting")
					secondaryText: {
						if (!dataItem.valid) {
							return ""
						}
						switch (dataItem.value & 0x30) {
						case 0x00:
							//% "Slave"
							return qsTrId("charger_slave")
						case 0x10:
							//% "Group master"
							return qsTrId("charger_group_master")
						case 0x20:
							//% "Charge master"
							return qsTrId("charger_charge_master")
						case 0x30:
							//% "Group & Charge master"
							return qsTrId("charger_group_charge_master")
						default:
							return ""
						}
					}
					dataItem.uid: root.bindPrefix + "/Link/NetworkMode"
				}
			}

			DelegateComponent {
				preferredVisible: chargeVoltageItem.valid && networkModeEnabledDC.dataItem.value > 0 && (networkModeModeDC.dataItem.value & 0x04)
				ListQuantity {
					//% "Charge voltage"
					text: qsTrId("charger_charge_voltage")
					dataItem.uid: root.bindPrefix + "/Link/ChargeVoltage"
					unit: VenusOS.Units_Volt_DC
				}
			}

			DelegateComponent {
				preferredVisible: chargeCurrentItem.valid && networkModeEnabledDC.dataItem.value > 0 && (networkModeModeDC.dataItem.value & 0x08)
				ListText {
					text: CommonWords.charge_current
					dataItem.uid: root.bindPrefix + "/Link/ChargeCurrent"
				}
			}

			DelegateComponent {
				id: bmsControlledDC
				dataItem: VeQuickItem { uid: root.bindPrefix + "/Settings/BmsPresent" }
				preferredVisible: bmsPresentItem.valid
				ListText {
					id: bmsControlled
					text: CommonWords.bms_controlled
					secondaryText: CommonWords.yesOrNo(dataItem.value)
					dataItem.uid: root.bindPrefix + "/Settings/BmsPresent"
				}
			}

			DelegateComponent {
				preferredVisible: bmsControlledDC.dataItem.value === 1
				ListButton {
					text: CommonWords.bms_control
					secondaryText: CommonWords.reset
					onClicked: {
						bmsControlledDC.dataItem.setValue(0)
					}
				}
			}

			DelegateComponent {
				preferredVisible: bmsControlledDC.dataItem.value === 1
				ListInfoLabel {
					text: CommonWords.bms_control_info
				}
			}
		}
	}
}

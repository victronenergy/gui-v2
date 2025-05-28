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

	GradientListView {
		id: chargerListView

		model: VisibleItemModel {
			ListText {
				id: networkModeEnabled
				//% "Networked"
				text: qsTrId("charger_networked")
				dataItem.uid: root.bindPrefix + "/Link/NetworkMode"
				preferredVisible: dataItem.valid
				secondaryText: dataItem.valid ? CommonWords.yesOrNo(dataItem.value & 1) : ""
			}

			ListText {
				text: CommonWords.network_status
				secondaryText: Global.systemSettings.networkStatusToText(dataItem.value)
				dataItem.uid: root.bindPrefix + "/Link/NetworkStatus"
			}

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
				preferredVisible: dataItem.valid && networkModeEnabled.dataItem.value
			}

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
				preferredVisible: dataItem.valid && networkModeEnabled.dataItem.value && ((dataItem.value & 0x30) > 0x00)
			}

			ListQuantity {
				//% "Charge voltage"
				text: qsTrId("charger_charge_voltage")
				dataItem.uid: root.bindPrefix + "/Link/ChargeVoltage"
				preferredVisible: dataItem.valid && networkModeEnabled.dataItem.value > 0 && (networkModeMode.dataItem.value & 0x04)
				unit: VenusOS.Units_Volt_DC
			}

			ListText {
				text: CommonWords.charge_current
				dataItem.uid: root.bindPrefix + "/Link/ChargeCurrent"
				preferredVisible: dataItem.valid && networkModeEnabled.dataItem.value > 0 && (networkModeMode.dataItem.value & 0x08)
			}

			ListText {
				id: bmsControlled
				text: CommonWords.bms_controlled
				secondaryText: CommonWords.yesOrNo(dataItem.value)
				dataItem.uid: root.bindPrefix + "/Settings/BmsPresent"
				preferredVisible: dataItem.valid
			}

			ListButton {
				text: CommonWords.bms_control
				secondaryText: CommonWords.reset
				preferredVisible: bmsControlled.dataItem.value === 1
				onClicked: {
					bmsControlled.dataItem.setValue(0)
				}
			}

			PrimaryListLabel {
				id: bmsControlInfoLabel

				text: CommonWords.bms_control_info
				font.pixelSize: Theme.font_size_caption
				color: Theme.color_font_secondary
				leftPadding: infoIcon.x + infoIcon.width + infoIcon.x/2
				preferredVisible: bmsControlled.dataItem.value === 1

				CP.IconImage {
					id: infoIcon

					x: Theme.geometry_listItem_content_horizontalMargin
					y: bmsControlInfoLabel.topPadding + (infoFontMetrics.boundingRect("A").height - height)/2
					source: "qrc:/images/information.svg"
					color: Theme.color_font_secondary
				}

				FontMetrics {
					id: infoFontMetrics

					font: bmsControlInfoLabel.font
				}
			}
		}
	}
}

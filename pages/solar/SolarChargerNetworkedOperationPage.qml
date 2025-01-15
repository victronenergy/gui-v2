/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import QtQuick.Controls.impl as CP

Page {
	id: root

	property var solarCharger

	GradientListView {
		id: chargerListView

		model: AllowedItemModel {
			ListText {
				id: networkModeEnabled
				//% "Networked"
				text: qsTrId("charger_networked")
				dataItem.uid: root.solarCharger.serviceUid + "/Link/NetworkMode"
				allowed: dataItem.isValid
				secondaryText: dataItem.isValid ? CommonWords.yesOrNo(dataItem.value & 1) : ""
			}

			ListText {
				text: CommonWords.network_status
				secondaryText: Global.systemSettings.networkStatusToText(dataItem.value)
				dataItem.uid: root.solarCharger.serviceUid + "/Link/NetworkStatus"
			}

			ListText {
				id: networkModeMode
				//% "Mode setting"
				text: qsTrId("charger_mode_setting")
				secondaryText: {
					if (!dataItem.isValid) {
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
				dataItem.uid: root.solarCharger.serviceUid + "/Link/NetworkMode"
				allowed: dataItem.isValid && networkModeEnabled.dataItem.value
			}

			ListText {
				//% "Master setting"
				text: qsTrId("charger_master_setting")
				secondaryText: {
					if (!dataItem.isValid) {
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
				dataItem.uid: root.solarCharger.serviceUid + "/Link/NetworkMode"
				allowed: dataItem.isValid && networkModeEnabled.dataItem.value && ((dataItem.value & 0x30) > 0x00)
			}

			ListQuantity {
				//% "Charge voltage"
				text: qsTrId("charger_charge_voltage")
				dataItem.uid: root.solarCharger.serviceUid + "/Link/ChargeVoltage"
				allowed: dataItem.isValid && networkModeEnabled.dataItem.value > 0 && (networkModeMode.dataItem.value & 0x04)
				unit: VenusOS.Units_Volt_DC
			}

			ListText {
				text: CommonWords.charge_current
				dataItem.uid: root.solarCharger.serviceUid + "/Link/ChargeCurrent"
				allowed: dataItem.isValid && networkModeEnabled.dataItem.value > 0 && (networkModeMode.dataItem.value & 0x08)
			}

			ListText {
				id: bmsControlled
				//% "BMS controlled"
				text: qsTrId("charger_network_bms_controlled")
				secondaryText: CommonWords.yesOrNo(dataItem.value)
				dataItem.uid: root.solarCharger.serviceUid + "/Settings/BmsPresent"
				allowed: dataItem.isValid
			}

			ListButton {
				//% "BMS control"
				text: qsTrId("charger_network_bms_control")
				button.text: CommonWords.reset
				allowed: bmsControlled.dataItem.value === 1
				onClicked: {
					bmsControlled.dataItem.setValue(0)
				}
			}

			PrimaryListLabel {
				id: bmsControlInfoLabel

				//% "BMS control is enabled automatically when BMS is present. Reset if the system configuration changed or if there is no BMS present."
				text: qsTrId("charger_network_bms_control_info")
				font.pixelSize: Theme.font_size_caption
				color: Theme.color_font_secondary
				leftPadding: infoIcon.x + infoIcon.width + infoIcon.x/2
				allowed: bmsControlled.dataItem.value === 1

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

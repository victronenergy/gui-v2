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

		model: ObjectModel {
			ListTextItem {
				id: networkModeEnabled
				//% "Networked"
				text: qsTrId("charger_networked")
				dataSource: root.solarCharger.serviceUid + "/Link/NetworkMode"
				visible: dataValid
				secondaryText: dataValue === undefined ? "" : CommonWords.yesOrNo(dataValue & 1)
			}

			ListTextItem {
				//% "Network status"
				text: qsTrId("charger_network_status")
				secondaryText: Global.systemSettings.networkStatusToText(dataValue)
				dataSource: root.solarCharger.serviceUid + "/Link/NetworkStatus"
			}

			ListTextItem {
				id: networkModeMode
				//% "Mode setting"
				text: qsTrId("charger_mode_setting")
				secondaryText: {
					if (dataValue === undefined) {
						return ""
					}
					switch (dataValue & 0xE) {
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
				dataSource: root.solarCharger.serviceUid + "/Link/NetworkMode"
				visible: dataValid && networkModeEnabled.dataValue
			}

			ListTextItem {
				//% "Master setting"
				text: qsTrId("charger_master_setting")
				secondaryText: {
					if (dataValue === undefined) {
						return ""
					}
					switch (dataValue & 0x30) {
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
				dataSource: root.solarCharger.serviceUid + "/Link/NetworkMode"
				visible: dataValid && networkModeEnabled.dataValue && ((dataValue & 0x30) > 0x00)
			}

			ListQuantityItem {
				//% "Charge voltage"
				text: qsTrId("charger_charge_voltage")
				dataSource: root.solarCharger.serviceUid + "/Link/ChargeVoltage"
				visible: dataValid && networkModeEnabled.dataValue > 0 && (networkModeMode.dataValue & 0x04)
				unit: VenusOS.Units_Volt
			}

			ListTextItem {
				text: CommonWords.charge_current
				dataSource: root.solarCharger.serviceUid + "/Link/ChargeCurrent"
				visible: dataValid && networkModeEnabled.dataValue > 0 && (networkModeMode.dataValue & 0x08)
			}

			ListTextItem {
				id: bmsControlled
				//% "BMS Controlled"
				text: qsTrId("charger_network_bms_controlled")
				secondaryText: CommonWords.yesOrNo(dataValue)
				dataSource: root.solarCharger.serviceUid + "/Settings/BmsPresent"
				visible: dataValid
			}

			ListButton {
				//% "BMS Control"
				text: qsTrId("charger_network_bms_control")
				//: Reset the BMS control
				//% "Reset"
				button.text: qsTrId("charger_network_bms_control_reset")
				visible: bmsControlled.dataValue === 1
				onClicked: {
					bmsControlled.setDataValue(0)
				}
			}

			ListLabel {
				id: bmsControlInfoLabel

				//% "BMS control is enabled automatically when BMS is present. Reset if the system configuration changed or if there is no BMS present."
				text: qsTrId("charger_network_bms_control_info")
				font.pixelSize: Theme.font_size_caption
				color: Theme.color_font_secondary
				leftPadding: infoIcon.x + infoIcon.width + infoIcon.x/2
				visible: bmsControlled.dataValue === 1

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

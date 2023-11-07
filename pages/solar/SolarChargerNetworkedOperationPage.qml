/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import QtQuick.Controls.impl as CP

Page {
	id: root

	property var solarCharger

	function _alarmTypeToText(alarmType) {
		switch (alarmType) {
		case VenusOS.SolarCharger_AlarmType_OK:
			//: Voltage alarm is at "OK" level
			//% "OK"
			return qsTrId("charger_alarms_level_ok")
		case VenusOS.SolarCharger_AlarmType_Warning:
			//: Voltage alarm is at "Warning" level
			//% "Warning"
			return qsTrId("charger_alarms_level_warning")
		case VenusOS.SolarCharger_AlarmType_Alarm:
			//: Voltage alarm is at "Alarm" level
			//% "Alarm"
			return qsTrId("charger_alarms_level_alarm")
		default:
			return ""
		}
	}

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
				secondaryText: {
					switch (dataValue) {
					case VenusOS.SolarCharger_NetworkStatus_Slave:
						//: Network status: Slave
						//% "Slave"
						return qsTrId("charger_network_status_slave")
					case VenusOS.SolarCharger_NetworkStatus_GroupMaster:
						//: Network status: Group Master
						//% "Group Master"
						return qsTrId("charger_network_status_group_master")
					case VenusOS.SolarCharger_NetworkStatus_InstanceMaster:
						//: Network status: Instance Master
						//% "Instance Master"
						return qsTrId("charger_network_status_instance_master")
					case VenusOS.SolarCharger_NetworkStatus_GroupAndInstanceMaster:
						//: Network status: Group & Instance Master
						//% "Group & Instance Master"
						return qsTrId("charger_network_status_group_and_instance_master")
					case VenusOS.SolarCharger_NetworkStatus_Standalone:
						//: Network status: Standalone
						//% "Standalone"
						return qsTrId("charger_network_status_standalone")
					case VenusOS.SolarCharger_NetworkStatus_StandaloneAndGroupMaster:
						//: Network status: Standalone & Group Master
						//% "Standalone & Group Master"
						return qsTrId("charger_network_status_standalone_and_group_master")
					default:
						return ""
					}
				}
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
				font.pixelSize: Theme.font.size.caption
				color: Theme.color.font.secondary
				leftPadding: infoIcon.x + infoIcon.width + infoIcon.x/2
				visible: bmsControlled.dataValue === 1

				CP.IconImage {
					id: infoIcon

					x: Theme.geometry.listItem.content.horizontalMargin
					y: bmsControlInfoLabel.topPadding + (infoFontMetrics.boundingRect("A").height - height)/2
					source: "qrc:/images/information.svg"
					color: Theme.color.font.secondary
				}

				FontMetrics {
					id: infoFontMetrics

					font: bmsControlInfoLabel.font
				}
			}
		}
	}
}

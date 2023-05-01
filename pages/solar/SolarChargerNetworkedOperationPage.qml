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
					case VenusOS.SolarCharger_NetworkStatus_StandaloneAndInstanceMaster:
						//: Network status: Standalone & Instance Master
						//% "Standalone & Instance Master"
						return qsTrId("charger_network_status_standalone_and_instance_master")
					default:
						return ""
					}
				}
				dataSource: root.solarCharger.serviceUid + "/Link/NetworkStatus"
			}

			ListTextItem {
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
				visible: bmsPresent.value === 1
				onClicked: {
					bmsPresent.setValue(0)
				}

				DataPoint {
					id: bmsPresent

					source: root.solarCharger.serviceUid + "/Settings/BmsPresent"
				}
			}

			ListLabel {
				id: bmsControlInfoLabel

				//% "BMS control is enabled automatically when BMS is present. Reset if the system configuration changed or if there is no BMS present."
				text: qsTrId("charger_network_bms_control_info")
				font.pixelSize: Theme.font.size.caption
				color: Theme.color.font.secondary
				leftPadding: infoIcon.x + infoIcon.width + infoIcon.x/2

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

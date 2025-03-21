/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string bindPrefix
	readonly property bool multiPhase: numberOfPhases.valid && numberOfPhases.value > 1

	title: acSystemDevice.name

	VeQuickItem {
		id: numberOfPhases
		uid: root.bindPrefix + "/Ac/NumberOfPhases"
	}

	Device {
		id: acSystemDevice
		serviceUid: root.bindPrefix
	}

	GradientListView {
		model: VisibleItemModel {
			ListInverterChargerModeButton {
				serviceUid: root.bindPrefix
			}

			ListText {
				text: CommonWords.state
				secondaryText: Global.system.systemStateToText(dataItem.value)
				dataItem.uid: root.bindPrefix + "/State"
			}

			SettingsColumn {
				width: parent ? parent.width : 0
				preferredVisible: inputSettingsModel.count > 0

				Repeater {
					model: AcInputSettingsModel {
						id: inputSettingsModel
						serviceUid: root.bindPrefix
					}
					delegate: ListCurrentLimitButton {
						required property AcInputSettings inputSettings

						serviceUid: root.bindPrefix
						inputNumber: inputSettings.inputNumber
						inputType: inputSettings.inputType
					}
				}
			}

			ListActiveAcInput {
				bindPrefix: root.bindPrefix
			}

			RsSystemAcIODisplay {
				serviceUid: root.bindPrefix
			}

			ListNavigation {
				id: systemAlarmsItem
				//% "System alarms"
				text: qsTrId("rssystem_system_alarms")
				onClicked: Global.pageManager.pushPage(pageRsSystemAlarms)
				Component { id: pageRsSystemAlarms; PageRsSystemAlarms { title: systemAlarmsItem.text; bindPrefix: root.bindPrefix } }
			}

			ListNavigation {
				id: alarmSetupItem
				text: CommonWords.alarm_setup
				onClicked: Global.pageManager.pushPage(pageRsAlarmSettings)
				Component { id: pageRsAlarmSettings; PageRsAlarmSettings { title: alarmSetupItem.text; bindPrefix: root.bindPrefix } }
			}

			ListNavigation {
				id: essItem
				text: CommonWords.ess
				onClicked: Global.pageManager.pushPage(pageRsSystemEss)
				Component { id: pageRsSystemEss; PageRsSystemEss { title: essItem.text; bindPrefix: root.bindPrefix } }
			}

			ListNavigation {
				id: rsDevicesItem
				//% "RS devices"
				text: qsTrId("settings_rs_devices")
				onClicked: Global.pageManager.pushPage(pageRsSystemDevices)
				Component { id: pageRsSystemDevices; PageRsSystemDevices { title: rsDevicesItem.text; bindPrefix: root.bindPrefix } }
			}

			ListTextField {
				text: CommonWords.custom_name
				dataItem.uid: root.bindPrefix + "/CustomName"
			}
		}
	}
}

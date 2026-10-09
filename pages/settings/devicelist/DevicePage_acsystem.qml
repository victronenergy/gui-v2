/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	Provides a list of settings for an acsystem service.

	Note this does not extend DevicePage, as an AC system is a virtual device for managing a group
	of Multi RS devices.
*/
Page {
	id: root

	property string serviceUid
	readonly property bool multiPhase: numberOfPhases.valid && numberOfPhases.value > 1

	title: acSystemDevice.name

	VeQuickItem {
		id: numberOfPhases
		uid: root.serviceUid + "/Ac/NumberOfPhases"
	}

	Device {
		id: acSystemDevice
		serviceUid: root.serviceUid
	}

	GradientListView {
		model: VisibleItemModel {
			ListInverterChargerModeButton {
				serviceUid: root.serviceUid
			}

			ListText {
				text: CommonWords.state
				secondaryText: VenusOS.system_stateToText(dataItem.value)
				dataItem.uid: root.serviceUid + "/State"
			}

			SettingsColumn {
				width: parent ? parent.width : 0
				preferredVisible: inputSettingsModel.count > 0

				Repeater {
					model: AcInputSettingsModel {
						id: inputSettingsModel
						serviceUid: root.serviceUid
					}
					delegate: ListCurrentLimitButton {
						required property AcInputSettings inputSettings

						serviceUid: root.serviceUid
						inputNumber: inputSettings.inputNumber
						inputType: inputSettings.inputType
					}
				}
			}

			ListActiveAcInput {
				bindPrefix: root.serviceUid
			}

			RsSystemAcIODisplay {
				serviceUid: root.serviceUid
			}

			ListNavigation {
				//% "System alarms"
				text: qsTrId("rssystem_system_alarms")
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/devicelist/rs/PageRsSystemAlarms.qml",
							{ "title": text, "bindPrefix": root.serviceUid })
				}
			}

			ListNavigation {
				text: CommonWords.alarm_setup
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/devicelist/rs/PageRsAlarmSettings.qml",
							{ "title": text, "bindPrefix": root.serviceUid })
				}
			}

			ListNavigation {
				text: CommonWords.ess
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/devicelist/rs/PageRsSystemEss.qml",
							{ "title": text, "bindPrefix": root.serviceUid })
				}
			}

			ListNavigation {
				//% "Inverters"
				text: qsTrId("settings_rssystem_inverters")
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/devicelist/rs/PageRsSystemDevices.qml",
							{ "title": text, "bindPrefix": root.serviceUid })
				}
			}

			ListTextField {
				text: CommonWords.custom_name
				dataItem.uid: root.serviceUid + "/CustomName"
			}
		}
	}
}

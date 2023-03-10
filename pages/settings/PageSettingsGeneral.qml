/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

ListPage {
	id: root

	listView: GradientListView {
		id: settingsListView

		// Allow AccessLevelRadioButtonGroup to get key events
		focus: true

		model: ObjectModel {
			AccessLevelRadioButtonGroup {
				listPage: root
				listIndex: ObjectModel.index
			}

			ListTextField {
				//% "Set root password"
				text: qsTrId("settings_set_root_password")
				showAccessLevel: VenusOS.User_AccessType_SuperUser
				placeholderText: "* * * * * *"

				onAccepted: {
					// TODO implement via platform helpers
					Global.showToastNotification(VenusOS.Notification_Info, "not yet implemented!")
				}
			}

			ListSwitch {
				id: sshOnLan

				//% "SSH on LAN"
				text: qsTrId("settings_ssh_on_lan")
				dataSource: "com.victronenergy.settings/Settings/System/SSHLocal"
				showAccessLevel: VenusOS.User_AccessType_SuperUser
			}

			ListSwitch {
				id: remoteSupportOnOff

				//% "Remote support"
				text: qsTrId("settings_remote_support")
				dataSource: "com.victronenergy.settings/Settings/System/RemoteSupport"
			}

			ListTextItem {
				//% "Remote support tunnel"
				text: qsTrId("settings_remote_support_tunnel")
				secondaryText: remotePort.secondaryText.length > 0 ? CommonWords.online : CommonWords.offline
				visible: defaultVisible && remoteSupportOnOff.checked
			}

			ListTextItem {
				id: remotePort

				//% "Remote support IP and port"
				text: qsTrId("settings_remote_ip_and_support")
				dataSource: "com.victronenergy.settings/Settings/System/RemoteSupportIpAndPort"
				visible: defaultVisible && remoteSupportOnOff.checked
			}

			ListButton {
				//% "Reboot"
				text: qsTrId("settings_reboot")
				//% "Reboot now"
				button.text: qsTrId("settings_reboot_now")
				writeAccessLevel: VenusOS.User_AccessType_User
				onClicked: {
					console.log("TODO implement reboot")
				}
			}

			ListSwitch {
				//% "Audible alarm"
				text: qsTrId("settings_audible_alarm")
				dataSource: "com.victronenergy.settings/Settings/Alarm/Audible"
				visible: defaultVisible && buzzerStateDataPoint.valid

				DataPoint {
					id: buzzerStateDataPoint
					source: "com.victronenergy.system/Buzzer/State"
				}
			}

			ListSwitch {
				//% "Demo mode"
				text: qsTrId("settings_demo_mode")
				checked: Global.systemSettings.demoMode.value === VenusOS.SystemSettings_DemoModeActive
				updateOnClick: false
				onClicked: {
					// TODO clarify - do we need same demo modes as gui-v1? Those trigger demos via scripts in dbus-recorder/.
					if (checked && BackendConnection.state !== BackendConnection.Ready && BackendConnection.state !== BackendConnection.Connecting) {
						//% "No backend source available. Demo mode cannot be deactivated!"
						Global.showToastNotification(VenusOS.Notification_Info, qsTrId("settings_general_no_backend_source"))
						return
					}
					Global.systemSettings.demoMode.setValue(
						checked ? VenusOS.SystemSettings_DemoModeInactive : VenusOS.SystemSettings_DemoModeActive)
				}
			}
		}
	}
}

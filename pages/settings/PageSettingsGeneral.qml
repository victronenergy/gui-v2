/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	SettingsListView {
		id: settingsListView

		// Allow AccessLevelRadioButtonGroup to get key events
		focus: true

		model: ObjectModel {
			AccessLevelRadioButtonGroup {}

			SettingsListTextField {
				//% "Set root password"
				text: qsTrId("settings_set_root_password")
				showAccessLevel: VenusOS.User_AccessType_SuperUser
				placeholderText: "* * * * * *"
			}

			SettingsListSwitch {
				id: sshOnLan

				//% "SSH on LAN"
				text: qsTrId("settings_ssh_on_lan")
				source: "com.victronenergy.settings/Settings/System/SSHLocal"
				showAccessLevel: VenusOS.User_AccessType_SuperUser
			}

			SettingsListSwitch {
				id: remoteSupportOnOff

				//% "Remote support"
				text: qsTrId("settings_remote_support")
				source: "com.victronenergy.settings/Settings/System/RemoteSupport"
			}

			SettingsListTextItem {
				//% "Remote support tunnel"
				text: qsTrId("settings_remote_support_tunnel")
				secondaryText: remotePort.secondaryText.length > 0
						 //% "Online"
						? qsTrId("settings_remote_support_online")
						 //% "Offline"
						: qsTrId("settings_remote_support_offline")
				visible: defaultVisible && remoteSupportOnOff.checked
			}

			SettingsListTextItem {
				id: remotePort

				//% "Remote support IP and port"
				text: qsTrId("settings_remote_ip_and_support")
				source: "com.victronenergy.settings/Settings/System/RemoteSupportIpAndPort"
				visible: defaultVisible && remoteSupportOnOff.checked
			}

			SettingsListButton {
				//% "Reboot"
				text: qsTrId("settings_reboot")
				//% "Reboot now"
				button.text: qsTrId("settings_reboot_now")
				onClicked: {
					console.log("TODO implement reboot")
				}
			}

			SettingsListSwitch {
				//% "Audible alarm"
				text: qsTrId("settings_audible_alarm")
				source: "com.victronenergy.settings/Settings/Alarm/Audible"
				visible: defaultVisible && buzzerStateDataPoint.value !== undefined

				DataPoint {
					id: buzzerStateDataPoint
					source: "com.victronenergy.system/Buzzer/State"
				}
			}

			SettingsListSwitch {
				//% "Demo mode"
				text: qsTrId("settings_demo_mode")
				checked: Global.systemSettings.demoMode.value === VenusOS.SystemSettings_DemoModeActive
				checkWhenClicked: false
				onClicked: {
					if (checked && !dbusConnected) {
						//% "No backend source available. Demo mode cannot be deactivated!"
						Global.dialogManager.showToastNotification(VenusOS.Notification_Notification, qsTrId("settings_general_no_backend_source"))
						return
					}
					Global.systemSettings.demoMode.setValue(
						checked ? VenusOS.SystemSettings_DemoModeActive : VenusOS.SystemSettings_DemoModeInactive)
				}
			}
		}
	}
}

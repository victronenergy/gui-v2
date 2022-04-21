/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import Victron.Velib

Page {
	id: root

	SettingsListView {
		id: settingsListView

		// Allow AccessLevelRadioButtonGroup to get key events
		focus: true

		model: ObjectModel {
			AccessLevelRadioButtonGroup {}

			SettingsListItem {
				//% "Set root password"
				text: qsTrId("settings_set_root_password")
				showAccessLevel: User.AccessSuperUser
				// TODO show text input with VKB
			}

			SettingsListSwitch {
				id: sshOnLan

				//% "SSH on LAN"
				text: qsTrId("settings_ssh_on_lan")
				source: "com.victronenergy.settings/Settings/System/SSHLocal"
				showAccessLevel: User.AccessSuperUser
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
				visible: defaultVisible && buzzerStateItem.value !== undefined

				VeQuickItem {
					id: buzzerStateItem
					uid: dbusConnected
						 ? "dbus/com.victronenergy.system/Buzzer/State"
						 : ""
				}
			}
		}
	}
}

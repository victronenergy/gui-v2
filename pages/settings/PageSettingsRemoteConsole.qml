/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	SettingsListView {
		model: ObjectModel {
			SettingsLabel {
				//% "Manually reboot the GX device after changing these settings.\n\nFirst time use? Make sure to either set or disable the password check."
				text: qsTrId("settings_remoteconsole_reboot_warning")
			}

			SettingsListButton {
				//% "Disable password check"
				text: qsTrId("settings_remoteconsole_password_disable_password_check")
				//% "Disable"
				button.text: qsTrId("settings_remoteconsole_disable_password")
				onClicked: {
					// TODO vePlatform.setRemoteConsolePassword("")
					//% "Password check has been disabled"
					Global.dialogManager.showToastNotification(VenusOS.Notification_Notification, qsTrId("settings_remoteconsole_password_check_disabled"))
					enablePasswordField.textField.text = ""
				}
			}

			SettingsListTextField {
				id: enablePasswordField

				//% "Enable password check"
				text: qsTrId("settings_remoteconsole_enable_password_check")
				//% "Enter password"
				placeholderText: qsTrId("settings_remoteconsole_enter_password")

				onAccepted: {
					// TODO vePlatform.setRemoteConsolePassword(textField.text)
					const info = textField.text === ""
						  //% "Password check is disabled"
						? qsTrId("settings_remoteconsole_password_check_is_disabled")
						  //% "Password check enabled and the password is set"
						: qsTrId("settings_remoteconsole_password_check_enabled")
					Global.dialogManager.showToastNotification(VenusOS.Notification_Notification, info)
				}

				onHasActiveFocusChanged: {
					if (hasActiveFocus) {
						textField.text = ""
					}
				}
			}

			SettingsListSwitch {
				id: vncInternet

				//% "Enable on VRM"
				text: qsTrId("settings_remoteconsole_enable_on_vrm")
				source: "com.victronenergy.settings/Settings/System/VncInternet"
			}

			SettingsListTextItem {
				//% "Remote Console on VRM - status"
				text: qsTrId("settings_remoteconsole_vrm_status")
				secondaryText: vncInternet.checked
						&& remoteSupportIpAndPort.value !== undefined
						&& remoteSupportIpAndPort.value !== 0
					  //% "Online"
					? qsTrId("settings_remoteconsole_vrm_online")
					  //% "Offline"
					: qsTrId("settings_remoteconsole_vrm_offline")

				DataPoint {
					id: remoteSupportIpAndPort
					source: "com.victronenergy.settings/Settings/System/RemoteSupportIpAndPort"
				}
			}

			SettingsListSwitch {
				id: vncOnLan

				//% "Enable on LAN"
				text: qsTrId("settings_remoteconsole_enable_on_lan")
				source: "com.victronenergy.settings/Settings/System/VncLocal"
				height: implicitHeight + vncOnLanCaption.height

				SettingsLabel {
					id: vncOnLanCaption

					anchors {
						bottom: parent.bottom
						bottomMargin: Theme.geometry.settingsListItem.content.verticalMargin
					}
					//% "Security warning: only enable the console on LAN when the GX device is connected to a trusted network."
					text: qsTrId("settings_remoteconsole_enable_on_lan_warning")
				}
			}
		}
	}
}

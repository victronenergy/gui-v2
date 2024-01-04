/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil

Page {
	id: root

	GradientListView {
		model: ObjectModel {
			ListLabel {
				//% "Manually reboot the GX device after changing these settings.\n\nFirst time use? Make sure to either set or disable the password check."
				text: qsTrId("settings_remoteconsole_reboot_warning")
			}

			ListButton {
				//% "Disable password check"
				text: qsTrId("settings_remoteconsole_password_disable_password_check")
				//% "Disable"
				button.text: qsTrId("settings_remoteconsole_disable_password")
				onClicked: {
					// TODO vePlatform.setRemoteConsolePassword("")
					//% "Password check has been disabled"
					Global.showToastNotification(VenusOS.Notification_Info, qsTrId("settings_remoteconsole_password_check_disabled"))
					enablePasswordField.textField.text = ""
				}
			}

			ListTextField {
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
					Global.showToastNotification(VenusOS.Notification_Info, info)
				}

				onHasActiveFocusChanged: {
					if (hasActiveFocus) {
						textField.text = ""
					}
				}
			}

			ListSwitch {
				id: vncInternet

				//% "Enable on VRM"
				text: qsTrId("settings_remoteconsole_enable_on_vrm")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/System/VncInternet"
			}

			ListTextItem {
				//% "Remote Console on VRM - status"
				text: qsTrId("settings_remoteconsole_vrm_status")
				secondaryText: vncInternet.checked
						&& remoteSupportIpAndPort.isValid
						&& remoteSupportIpAndPort.value !== 0 ? CommonWords.online : CommonWords.offline

				VeQuickItem {
					id: remoteSupportIpAndPort
					uid: Global.systemSettings.serviceUid + "/Settings/System/RemoteSupportIpAndPort"
				}
			}

			ListSwitch {
				id: vncOnLan

				//% "Enable on LAN"
				text: qsTrId("settings_remoteconsole_enable_on_lan")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/System/VncLocal"

				bottomContent.children: ListLabel {
					visible: text.length > 0
					topPadding: 0
					bottomPadding: 0
					color: Theme.color_font_secondary
					//% "Security warning: only enable the console on LAN when the GX device is connected to a trusted network."
					text: qsTrId("settings_remoteconsole_enable_on_lan_warning")
				}
			}
		}
	}
}

/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	GradientListView {
		id: settingsListView

		model: ObjectModel {

			ListRadioButtonGroup {
				//% "Access level"
				text: qsTrId("settings_access_level")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/System/AccessLevel"
				writeAccessLevel: VenusOS.User_AccessType_User
				optionModel: [
					//% "User"
					{ display: qsTrId("settings_access_user"), value: VenusOS.User_AccessType_User, promptPassword: true },
					//% "User & Installer"
					{ display: qsTrId("settings_access_user_installer"), value: VenusOS.User_AccessType_Installer, promptPassword: true },
					//% "Superuser"
					{ display: qsTrId("settings_access_superuser"), value: VenusOS.User_AccessType_SuperUser, readOnly: true },
					//% "Service"
					{ display: qsTrId("settings_access_service"), value: VenusOS.User_AccessType_Service, readOnly: true },
				]
				validatePassword: (index, password) => {
					if ((index === 0 || index === 1) && password === "ZZZ") {
						return Utils.validationResult(VenusOS.InputValidation_Result_OK)
					}
					//% "Incorrect password"
					return Utils.validationResult(VenusOS.InputValidation_Result_Error, qsTrId("settings_access_incorrect_password"))
				}
			}

			ListTextField {
				//% "Root password"
				text: qsTrId("settings_root_password")
				showAccessLevel: VenusOS.User_AccessType_SuperUser
				//% "Enter password"
				placeholderText: qsTrId("settings_root_enter_password")
				textField.echoMode: TextInput.Password
				saveInput: function() {
					if (secondaryText.length < 8) {
						//% "Password needs to be at least 8 characters long"
						Global.showToastNotification(VenusOS.Notification_Info, qsTrId("settings_root_too_short_password"), 5000)
					} else {
						var object = {"SetRootPassword": secondaryText}
						var json = JSON.stringify(object)
						securityApi.setValue(json)
						//% "Root password changed to %1"
						Global.showToastNotification(VenusOS.Notification_Info, qsTrId("settings_root_password_changed_to").arg(secondaryText), 5000)
					}
				}
			}

			ListSwitch {
				//% "Enable SSH on LAN"
				text: qsTrId("settings_enable_ssh_on_lan")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/System/SSHLocal"
				showAccessLevel: VenusOS.User_AccessType_SuperUser
			}

			ListSwitch {
				id: remoteSupportOnOff

				//% "Remote support"
				text: qsTrId("settings_remote_support")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/System/RemoteSupport"
			}

			ListText {
				//% "Remote support tunnel"
				text: qsTrId("settings_remote_support_tunnel")
				secondaryText: remotePort.secondaryText.length > 0 ? CommonWords.online : CommonWords.offline
				allowed: defaultAllowed && remoteSupportOnOff.checked
			}

			ListText {
				id: remotePort

				//% "Remote support IP and port"
				text: qsTrId("settings_remote_ip_and_support")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/System/RemoteSupportIpAndPort"
				allowed: defaultAllowed && remoteSupportOnOff.checked
			}

			ListButton {
				//% "Logout"
				text: qsTrId("settings_logout")
				//% "Log out now"
				button.text: qsTrId("settings_logout_now")

				// Cannot log out from GX devices, VRM or Unsecured profile with no password
				allowed: Qt.platform.os === "wasm" && !BackendConnection.vrm
						 && securityProfile.dataItem.value !== VenusOS.Security_Profile_Unsecured
				writeAccessLevel: VenusOS.User_AccessType_User
				onClicked: Global.dialogLayer.open(logoutDialogComponent)

				Component {
					id: logoutDialogComponent
					ModalWarningDialog {
						//% "Log out?"
						title: qsTrId("settings_logout_dialog_title")
						//% "This will disconnect all local network connections."
						description: qsTrId("settings_logout_dialog_description")
						//% "Log out"
						acceptText: qsTrId("settings_logout_dialog_accept_text")
						dialogDoneOptions: VenusOS.ModalDialog_DoneOptions_OkAndCancel
						height: Theme.geometry_modalDialog_height_small
						onAccepted: BackendConnection.logout()
					}
				}
			}
		}
	}
}
/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	readonly property bool pulledDown: settingsListView.contentY < -60

	onIsCurrentPageChanged: {
		if (isCurrentPage) {
			keyEvents.repeatCount = 0
			keyEvents.upCount = 0
			keyEvents.downCount = 0
		}
	}

	Connections {
		id: keyEvents

		property int repeatCount
		property int upCount
		property int downCount

		target: Global

		function onKeyPressed(event) {
			if (!root.isCurrentPage) {
				repeatCount = 0
				return
			}
			if (event.key === Qt.Key_Right) {
				// change to super user mode if the right button is pressed for a while
				if (Global.systemSettings.accessLevel.value !== VenusOS.User_AccessType_SuperUser && ++repeatCount > 60) {
					Global.systemSettings.accessLevel.setValue(VenusOS.User_AccessType_SuperUser)
					repeatCount = 0
				}
			} else if (event.key === Qt.Key_Up) {
				if (upCount < 5) ++upCount
				if (downCount > 0) upCount = 0
				downCount = 0
			} else if (event.key === Qt.Key_Down) {
				if (downCount < 5) ++downCount;
				if (upCount === 5 && downCount === 5) {
					Global.systemSettings.accessLevel.setValue(VenusOS.User_AccessType_Service)
					upCount = 0
				}
			}
		}
	}

	Timer {
		running: root.pulledDown
		interval: 5000
		onTriggered: {
			if (Global.systemSettings.accessLevel.value >= VenusOS.User_AccessType_Installer) {
				Global.systemSettings.accessLevel.setValue(VenusOS.User_AccessType_SuperUser)
			}
		}
	}

	GradientListView {
		id: settingsListView

		boundsBehavior: Flickable.DragOverBounds
		model: VisibleItemModel {
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

			ListNavigation {
				id: securityProfileListNavigation

				// TODO: (optional) put this in its own ListNavigation customised file
				// TODO: showAccessLevel
				// TODO: writeAccessLevel
				// TODO: pass the accessLevels into securityProfileOptionsComponent and observe there also
				// TODO: popTimer like ListRadioButtonGroup?

				readonly property var optionModel: [
					{
						//% "Secured"
						display: qsTrId("settings_security_profile_secured"),
						value: VenusOS.Security_Profile_Secured,
						//% "Password protected and the network communication is encrypted"
						caption: qsTrId("settings_security_profile_secured_caption"),
						promptPassword: true
					},
					{
						//% "Weak"
						display: qsTrId("settings_security_profile_weak"),
						value: VenusOS.Security_Profile_Weak,
						//% "Password protected, but the network communication is not encrypted"
						caption: qsTrId("settings_security_profile_weak_caption"),
						promptPassword: true
					},
					{
						//% "Unsecured"
						display: qsTrId("settings_security_profile_unsecured"),
						value: VenusOS.Security_Profile_Unsecured,
						//% "No password and the network communication is not encrypted"
						caption: qsTrId("settings_security_profile_unsecured_caption")
					}
				]
				readonly property int currentIndex: {
					if (!optionModel || optionModel.length === undefined || securityProfile.uid.length === 0 || !securityProfile.valid) {
						return defaultIndex
					}
					for (let i = 0; i < optionModel.length; ++i) {
						if (optionModel[i].value === securityProfile.value) {
							return i
						}
					}
					return defaultIndex
				}

				readonly property var currentValue: currentIndex >= 0 && optionModel.length !== undefined && currentIndex < optionModel.length
													? optionModel[currentIndex].value
													: undefined

				property int defaultIndex: -1

				//% "Local network security profile"
				text: qsTrId("settings_local_network_security_profile")

				//% "Unknown"
				property string defaultSecondaryText: qsTrId("settings_radio_button_group_unknown")

				secondaryText: currentIndex >= 0 && optionModel.length !== undefined && currentIndex < optionModel.length
							   ? optionModel[currentIndex].display
							   : defaultSecondaryText

				interactive: true

				VeQuickItem {
					id: securityProfile
					uid: Global.systemSettings.serviceUid + "/Settings/System/SecurityProfile"
				}

				VeQuickItem {
					id: securityApi
					uid: Global.venusPlatform.serviceUid + "/Security/Api"
				}

				onClicked: {
					Global.pageManager.pushPage(securityProfileOptionsComponent, { title: text })
				}

				Component {
					id: securityProfileOptionsComponent

					PageSettingsSecurityProfile {
						// now we can pass things back to the ListNavigationButton

						currentIndex: securityProfileListNavigation.currentIndex

						// TODO: pass the password in
						currentPassword:"" // "TODO: get the password"

						optionModel: securityProfileListNavigation.optionModel

						onAccepted: {
							console.log("The chosen security profile is", securityProfileIndex)

							let password = "pass"// TODO get the current password

							if (securityProfileIndex === VenusOS.Security_Profile_Unsecured) {
								password = ""
							}
							// NOTE: this restarts the webserver when changed
							let object = {"SetPassword": password, "SetSecurityProfile": securityProfileIndex}
							let json = JSON.stringify(object)
							securityApi.setValue(json)
							// This guards the wasm version to trigger a reload even if the reply isn't received.
							BackendConnection.securityProtocolChanged()
							Global.pageManager.popPage()
							if (Qt.platform.os === "wasm" && !BackendConnection.vrm) {
								Global.showToastNotification(VenusOS.Notification_Info,
															 //% "Page will automatically reload in 5 seconds"
															 qsTrId("access_and_security_page_will_reload"),
															 3000)
							}
						}
					}
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
				preferredVisible: remoteSupportOnOff.checked
			}

			ListText {
				id: remotePort

				//% "Remote support IP and port"
				text: qsTrId("settings_remote_ip_and_support")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/System/RemoteSupportIpAndPort"
				preferredVisible: remoteSupportOnOff.checked
			}

			ListButton {
				//% "Logout"
				text: qsTrId("settings_logout")
				//% "Log out now"
				secondaryText: qsTrId("settings_logout_now")

				// Cannot log out from GX devices, VRM or Unsecured profile with no password
				preferredVisible: Qt.platform.os === "wasm" && !BackendConnection.vrm
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

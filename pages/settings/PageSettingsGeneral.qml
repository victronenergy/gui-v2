/*
** Copyright (C) 2023 Victron Energy B.V.
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

		model: ObjectModel {
			ListRadioButtonGroup {
				//% "Security profile"
				text: qsTrId("settings_security_profile")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/System/SecurityProfile"
				updateOnClick: false // handle option clicked manually.
				optionModel: [
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
					},
				]

				onOptionClicked: function(index, password) {
					// Radio button model indexes should match the enums
					if (index === VenusOS.Security_Profile_Unsecured) {
						// NOTE: this restarts the webserver when changed
						dataItem.setValue(VenusOS.Security_Profile_Unsecured)
					} else {
						if (password.length < 8) {
							//% "Password needs to be at least 8 characters long"
							Global.showToastNotification(VenusOS.Notification_Info, qsTrId("settings_security_too_short_password"), 5000)
						} else {
							var object = {Action: "SetPassword", Password: password}
							var json = JSON.stringify(object)
							securityApi.setValue(json)

							// NOTE: this restarts the webserver when changed
							dataItem.setValue(index)
						}
					}
				}
				VeQuickItem {
					id: securityApi
					uid: Global.venusPlatform.serviceUid + "/Security/Api"
				}
			}

			ListRadioButtonGroup {
				//% "Access level"
				text: qsTrId("settings_access_level")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/System/AccessLevel"
				writeAccessLevel: VenusOS.User_AccessType_User

				optionModel: [
					//% "User"
					{ display: qsTrId("settings_access_user"), value: VenusOS.User_AccessType_User, password: "ZZZ" },
					//% "User & Installer"
					{ display: qsTrId("settings_access_user_installer"), value: VenusOS.User_AccessType_Installer, password: "ZZZ" },
					//% "Superuser"
					{ display: qsTrId("settings_access_superuser"), value: VenusOS.User_AccessType_SuperUser, readOnly: true },
					//% "Service"
					{ display: qsTrId("settings_access_service"), value: VenusOS.User_AccessType_Service, readOnly: true },
				]
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
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/System/SSHLocal"
				showAccessLevel: VenusOS.User_AccessType_SuperUser
			}

			ListSwitch {
				id: remoteSupportOnOff

				//% "Remote support"
				text: qsTrId("settings_remote_support")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/System/RemoteSupport"
			}

			ListTextItem {
				//% "Remote support tunnel"
				text: qsTrId("settings_remote_support_tunnel")
				secondaryText: remotePort.secondaryText.length > 0 ? CommonWords.online : CommonWords.offline
				allowed: defaultAllowed && remoteSupportOnOff.checked
			}

			ListTextItem {
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

			ListButton {
				text: CommonWords.reboot
				//% "Reboot now"
				button.text: qsTrId("settings_reboot_now")
				writeAccessLevel: VenusOS.User_AccessType_User
				onClicked: {
					Global.venusPlatform.reboot()
					Global.dialogLayer.open(rebootDialogComponent)
				}

				Component {
					id: rebootDialogComponent

					ModalWarningDialog {
						title: BackendConnection.type === BackendConnection.DBusSource
							//% "Rebooting..."
							? qsTrId("dialoglayer_rebooting")
							//% "Device has been rebooted."
							: qsTrId("dialoglayer_rebooted")

						// On device, dialog cannot be dismissed; just wait until device is rebooted.
						dialogDoneOptions: VenusOS.ModalDialog_DoneOptions_OkOnly
						footer.enabled: BackendConnection.type !== BackendConnection.DBusSource
						footer.opacity: footer.enabled ? 1 : 0
					}
				}
			}

			ListSwitch {
				//% "Audible alarm"
				text: qsTrId("settings_audible_alarm")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Alarm/Audible"
				allowed: defaultAllowed && buzzerStateDataItem.isValid

				VeQuickItem {
					id: buzzerStateDataItem
					uid: Global.system.serviceUid + "/Buzzer/State"
				}
			}

			ListSwitch {
				//% "Enable status LEDs"
				text: qsTrId("settings_enable_status_leds")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/LEDs/Enable"
				allowed: defaultAllowed && dataItem.isValid
			}

			ListRadioButtonGroup {
				//% "Demo mode"
				text: qsTrId("settings_demo_mode")
				height: implicitHeight + demoModeCaption.height
				primaryLabel.anchors.verticalCenterOffset: -(demoModeCaption.height / 2)
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Gui/DemoMode"
				popDestination: undefined // don't pop page automatically.
				updateOnClick: false // handle option clicked manually.
				optionModel: [
					{ display: CommonWords.disabled, value: 0 },
					//% "ESS demo"
					{ display: qsTrId("page_settings_demo_ess"), value: 1 },
					//% "Boat/Motorhome demo 1"
					{ display: qsTrId("page_settings_demo_1"), value: 2 },
					//% "Boat/Motorhome demo 2"
					{ display: qsTrId("page_settings_demo_2"), value: 3 },
				]
				ListLabel {
					id: demoModeCaption

					anchors {
						bottom: parent.bottom
						bottomMargin: Theme.geometry_listItem_content_verticalMargin
					}
					//% "Starting demo mode will change some settings and the user interface will be unresponsive for a moment."
					text: qsTrId("settings_demo_mode_caption")
				}
				onOptionClicked: function(index) {
					Qt.callLater(Global.main.rebuildUi)
					dataItem.setValue(index)
				}
			}
		}
	}
}

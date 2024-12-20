/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import QtQuick.Templates as T

Page {
	id: root

	GradientListView {
		id: settingsListView

		model: ObjectModel {
			SettingsListHeader {
				//% "System"
				text: qsTrId("pagesettingsgeneral_system")
			}

			ListNavigation {
				//% "Firmware"
				text: qsTrId("pagesettingsgeneral_firmware")
				secondaryText: FirmwareVersion.versionText(firmwareVersion.value, "venus")
				onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsFirmware.qml", {"title": text})

				VeQuickItem {
					id: firmwareVersion
					uid: Global.venusPlatform.serviceUid + "/Firmware/Installed/Version"
				}
			}

			ListNavigation {
				//% "Access & Security"
				text: qsTrId("pagesettingsgeneral_access_and_security")
				onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsAccessAndSecurity.qml", {"title": text})
			}

			SettingsListHeader {
				//% "Preferences"
				text: qsTrId("pagesettingsgeneral_preferences")
			}

			ListNavigation {
				//% "Display & Appearance"
				text: qsTrId("pagesettingsgeneral_display_and_appearance")
				onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsDisplayAndAppearance.qml", {"title": text})
			}

			ListNavigation {
				//% "Alarms & Feedback"
				text: qsTrId("pagesettingsgeneral_alarms_and_feedback")
				onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsAlarmsAndFeedback.qml", {"title": text})
			}

			SettingsListHeader { }

			ListNavigation {
				//% "Language"
				text: qsTrId("pagesettingsgeneral_language")
			}

			ListNavigation {
				//% "Date & Time"
				text: qsTrId("pagesettingsgeneral_date_and_time")
			}


			ListNavigation {
				//% "Display Units"
				text: qsTrId("pagesettingsgeneral_display_units")
			}

			SettingsListHeader { }

			ListNavigation {
				//% "Reboot"
				text: qsTrId("pagesettingsgeneral_reboot")
			}

			ListRadioButtonGroup {
				id: securityProfile

				property int pendingProfile
				property string pendingPassword

				//% "Network security profile"
				text: qsTrId("settings_network_security_profile")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/System/SecurityProfile"
				updateDataOnClick: false // handle option clicked manually.
				popDestination: undefined
				//% "Please select..."
				defaultSecondaryText: qsTrId("settings_security_profile_indeterminate")
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
				validatePassword: (index, password) => {
					pendingPassword = ""
					if (password.length < 8) {
						//% "Password needs to be at least 8 characters long"
						return Utils.validationResult(VenusOS.InputValidation_Result_Error, qsTrId("settings_security_too_short_password"))
					}
					pendingPassword = password
					return Utils.validationResult(VenusOS.InputValidation_Result_OK)
				}

				onOptionClicked: (index) => {
					// Radio button model indexes should match the enums
					securityProfile.pendingProfile = index
					if (securityProfile.pendingProfile === VenusOS.Security_Profile_Unsecured) {
						// NOTE: this restarts the webserver when changed
						Global.dialogLayer.open(securityProfileConfirmationDialog)
					} else {
						Global.dialogLayer.open(securityProfileConfirmationDialog, {password: pendingPassword})
					}
				}

				VeQuickItem {
					id: securityApi
					uid: Global.venusPlatform.serviceUid + "/Security/Api"
				}

				Component {
					id: securityProfileConfirmationDialog

					ModalWarningDialog {
						property string password

						icon.source: ""
						title: {
							switch (securityProfile.pendingProfile) {
							case VenusOS.Security_Profile_Secured:
								//% "Select 'Secured' profile?"
								return qsTrId("settings_security_profile_secured_title")
							case VenusOS.Security_Profile_Weak:
								//% "Select 'Weak' profile?"
								return qsTrId("settings_security_profile_weak_title")
							case VenusOS.Security_Profile_Unsecured:
								//% "Select 'Unsecured' profile?"
								return qsTrId("settings_security_profile_unsecured_title")
							}
						}

						description: {
							switch (securityProfile.pendingProfile) {
							case VenusOS.Security_Profile_Secured:
								//% "• Local network services are password protected\n• The network communication is encrypted\n• A secure connection with VRM is enabled\n• Insecure settings cannot be enabled"
								return qsTrId("settings_security_profile_secured_description")
							case VenusOS.Security_Profile_Weak:
								//% "• Local network services are password protected\n• Unencrypted access to local websites is enabled as well (HTTP/HTTPS)"
								return qsTrId("settings_security_profile_weak_description")
							case VenusOS.Security_Profile_Unsecured:
								//% "• Local network services do not need a password\n• Unencrypted access to local websites is enabled as well (HTTP/HTTPS)"
								return  qsTrId("settings_security_profile_unsecured_description")
							}
						}
						onAccepted: {
							const profile = securityProfile.pendingProfile
							if (profile === VenusOS.Security_Profile_Unsecured)
								password = "";
							securityProfile.currentIndex = profile
							// NOTE: this restarts the webserver when changed
							var object = {"SetPassword": password, "SetSecurityProfile": profile};
							var json = JSON.stringify(object);
							securityApi.setValue(json);
							// This guards the wasm version to trigger a reload even if the reply isn't received.
							BackendConnection.securityProtocolChanged()
							Global.pageManager.popPage()
						}
						dialogDoneOptions: VenusOS.ModalDialog_DoneOptions_OkAndCancel
						height: securityProfile.pendingProfile === VenusOS.Security_Profile_Secured
								? Theme.geometry_modalDialog_height
								: Theme.geometry_modalDialog_height_small
					}
				}
			}

			ListButton {
				text: CommonWords.reboot
				//% "Reboot now"
				button.text: qsTrId("settings_reboot_now")
				writeAccessLevel: VenusOS.User_AccessType_User
				onClicked: Global.dialogLayer.open(confirmRebootDialogComponent)

				Component {
					id: confirmRebootDialogComponent

					ModalWarningDialog {
						//% "Press 'OK' to reboot"
						title: qsTrId("press_ok_to_reboot")
						dialogDoneOptions: VenusOS.ModalDialog_DoneOptions_OkAndCancel
						onClosed: {
							if (result === T.Dialog.Accepted) {
								Global.venusPlatform.reboot()
								Qt.callLater(Global.dialogLayer.open, rebootingDialogComponent)
							}
						}
					}
				}

				Component {
					id: rebootingDialogComponent

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

			ListRadioButtonGroup {
				//% "Demo mode"
				text: qsTrId("settings_demo_mode")
				height: implicitHeight + demoModeCaption.height
				primaryLabel.anchors.verticalCenterOffset: -(demoModeCaption.height / 2)
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Gui/DemoMode"
				popDestination: undefined // don't pop page automatically.
				updateDataOnClick: false // handle option clicked manually.
				optionModel: [
					{ display: CommonWords.disabled, value: 0 },
					//% "ESS demo"
					{ display: qsTrId("page_settings_demo_ess"), value: 1 },
					//% "Boat/Motorhome demo 1"
					{ display: qsTrId("page_settings_demo_1"), value: 2 },
					//% "Boat/Motorhome demo 2"
					{ display: qsTrId("page_settings_demo_2"), value: 3 },
				]

				PrimaryListLabel {
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

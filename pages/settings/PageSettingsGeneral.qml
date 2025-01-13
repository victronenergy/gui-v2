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

		model: VisibleItemModel {
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

			ListRadioButtonGroup {
				//% "Language"
				text: qsTrId("settings_language")

				writeAccessLevel: VenusOS.User_AccessType_User
				optionModel: languageModel
				currentIndex: optionModel.currentIndex
				secondaryText: optionModel.currentDisplayText
				popDestination: undefined // don't pop page automatically.
				updateCurrentIndexOnClick: false // don't update the radio button selection automatically.

				onOptionClicked: function(index) {
					// The SystemSettings data point listener will set the Language.
					// It may take a few seconds for the backend to deliver the value
					// change to that other data point.  So, display a message to the user.
					Global.dialogLayer.open(changingLanguageDialog)
					languageDataItem.setValue(Language.toCode(optionModel.languageAt(index)))
				}

				LanguageModel {
					id: languageModel
				}

				Instantiator {
					model: languageModel
					delegate: FontLoader {
						source: model.fontFileUrl
						onStatusChanged: {
							if (status === FontLoader.Ready) {
								languageModel.setFontFamily(source, name)
							}
						}
					}
				}

				VeQuickItem {
					id: languageDataItem
					uid: Global.systemSettings.serviceUid + "/Settings/Gui/Language"
					onValueChanged: {
						if (value !== undefined) {
							languageModel.currentLanguage = Language.fromCode(value)
						}
					}
				}

				Component {
					id: changingLanguageDialog

					ModalWarningDialog {
						id: dlg
						property bool languageChangeFailed
						property bool languageChangeSucceeded
						dialogDoneOptions: VenusOS.ModalDialog_DoneOptions_OkOnly
						//% "Changing language"
						title: qsTrId("settings_language_changing_language")
						description: dlg.languageChangeFailed
							  //% "Failed to change language!"
							? qsTrId("settings_language_change_failed")
							: dlg.languageChangeSucceeded
							  //% "Successfully changed language!"
							? qsTrId("settings_language_change_succeeded")
							  //% "Please wait while the language is changed."
							: qsTrId("settings_language_please_wait")
						Connections {
							target: Language
							function onLanguageChangeFailed() { dlg.languageChangeFailed = true; dlg.languageChangeSucceeded = false }
							function onCurrentLanguageChanged() { if (!dlg.languageChangeFailed) { dlg.languageChangeSucceeded = true } }
						}
					}
				}
			}

			ListNavigation {
				//% "Date & Time"
				text: qsTrId("pagesettingsgeneral_date_and_time")
				onClicked: Global.pageManager.pushPage("/pages/settings/PageTzInfo.qml", {"title": text})
			}

			SettingsListHeader { }

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
		}
	}
}

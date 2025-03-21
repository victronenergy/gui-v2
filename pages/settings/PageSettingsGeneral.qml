/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

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
				id: firmwareItem
				//% "Firmware"
				text: qsTrId("pagesettingsgeneral_firmware")
				secondaryText: FirmwareVersion.versionText(firmwareVersion.value, "venus")
				onClicked: Global.pageManager.pushPage(pageSettingsFirmware)

				VeQuickItem {
					id: firmwareVersion
					uid: Global.venusPlatform.serviceUid + "/Firmware/Installed/Version"
				}

				Component { id: pageSettingsFirmware; PageSettingsFirmware { title: firmwareItem.text } }
			}

			ListNavigation {
				id: accessAndSecurityItem
				//% "Access & Security"
				text: qsTrId("pagesettingsgeneral_access_and_security")
				onClicked: Global.pageManager.pushPage(pageSettingsAccessAndSecurity)
				Component { id: pageSettingsAccessAndSecurity; PageSettingsAccessAndSecurity { title: accessAndSecurityItem.text } }
			}

			SettingsListHeader {
				//% "Preferences"
				text: qsTrId("pagesettingsgeneral_preferences")
			}

			ListNavigation {
				id: displayAndAppearanceItem
				//% "Display & Appearance"
				text: qsTrId("pagesettingsgeneral_display_and_appearance")
				onClicked: Global.pageManager.pushPage(pageSettingsDisplayAndAppearance)
				Component { id: pageSettingsDisplayAndAppearance; PageSettingsDisplayAndAppearance { title: displayAndAppearanceItem.text } }
			}

			ListNavigation {
				id: alarmsAndFeedbackItem
				//% "Alarms & Feedback"
				text: qsTrId("pagesettingsgeneral_alarms_and_feedback")
				onClicked: Global.pageManager.pushPage(pageSettingsAlarmsAndFeedback)
				Component { id: pageSettingsAlarmsAndFeedback; PageSettingsAlarmsAndFeedback { title: alarmsAndFeedbackItem.text } }
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
				id: tzInfoItem
				//% "Date & Time"
				text: qsTrId("pagesettingsgeneral_date_and_time")
				onClicked: Global.pageManager.pushPage(pageTzInfo)
				Component { id: pageTzInfo; PageTzInfo { title: tzInfoItem.text } }
			}

			SettingsListHeader { }

			ListRebootButton { }

			SettingsListHeader { }

			ListNavigation {
				id: usefulLinksItem
				//% "Useful Links"
				text: qsTrId("pagesettingsgeneral_useful_links")
				onClicked: Global.pageManager.pushPage(pageSettingsUsefulLinks)
				Component { id: pageSettingsUsefulLinks; PageSettingsUsefulLinks { title: usefulLinksItem.text } }
			}

			ListNavigation {
				id: modificationChecksItem
				//% "Modification checks"
				text: qsTrId("pagesettingsgeneral_modification_checks")
				secondaryText: fsModifiedStateItem.value === 0 && systemHooksStateItem.valid && !(systemHooksStateItem.value & VenusOS.ModificationChecks_SystemHooksState_HookLoadedAtBoot)
					//% "Unmodified"
					? qsTrId("pagesettingsmodificationchecks_unmodified")
					//% "Modified"
					:  qsTrId("pagesettingsmodificationchecks_modified")
				secondaryLabel.color: fsModifiedStateItem.value === 0 && systemHooksStateItem.valid && !(systemHooksStateItem.value & VenusOS.ModificationChecks_SystemHooksState_HookLoadedAtBoot) ? Theme.color_font_primary : Theme.color_red
				preferredVisible: fsModifiedStateItem.valid && systemHooksStateItem.valid
				onClicked: Global.pageManager.pushPage(pageSettingsModificationChecks)

				VeQuickItem {
					id: fsModifiedStateItem
					uid: Global.venusPlatform.serviceUid + "/ModificationChecks/FsModifiedState"
				}
				VeQuickItem {
					id: systemHooksStateItem
					uid: Global.venusPlatform.serviceUid + "/ModificationChecks/SystemHooksState"
				}

				Component { id: pageSettingsModificationChecks; PageSettingsModificationChecks { title: modificationChecksItem.text } }
			}
		}
	}
}

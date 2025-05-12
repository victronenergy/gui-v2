/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	GradientListView {
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

			ListRebootButton { }

			SettingsListHeader { }

			ListNavigation {
				//% "Useful Links"
				text: qsTrId("pagesettingsgeneral_useful_links")
				onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsUsefulLinks.qml", {"title": text})
			}

			ListNavigation {
				//% "Modification checks"
				text: qsTrId("pagesettingsgeneral_modification_checks")
				secondaryText: fsModifiedStateItem.value === 0 && systemHooksStateItem.valid && !(systemHooksStateItem.value & VenusOS.ModificationChecks_SystemHooksState_HookLoadedAtBoot)
					//% "Unmodified"
					? qsTrId("pagesettingsmodificationchecks_unmodified")
					//% "Modified"
					:  qsTrId("pagesettingsmodificationchecks_modified")
				secondaryLabel.color: fsModifiedStateItem.value === 0 && systemHooksStateItem.valid && !(systemHooksStateItem.value & VenusOS.ModificationChecks_SystemHooksState_HookLoadedAtBoot) ? Theme.color_font_primary : Theme.color_red
				preferredVisible: fsModifiedStateItem.valid && systemHooksStateItem.valid
				onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsModificationChecks.qml", {"title": text})

				VeQuickItem {
					id: fsModifiedStateItem
					uid: Global.venusPlatform.serviceUid + "/ModificationChecks/FsModifiedState"
				}
				VeQuickItem {
					id: systemHooksStateItem
					uid: Global.venusPlatform.serviceUid + "/ModificationChecks/SystemHooksState"
				}
			}

			SettingsListHeader { }

			ListRadioButtonGroup {
				//% "Demo mode"
				text: qsTrId("settings_demo_mode")
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

				//% "Starting demo mode will change some settings and the user interface will be unresponsive for a moment."
				caption: qsTrId("settings_demo_mode_caption")

				onOptionClicked: function(index) {
					Qt.callLater(Global.main.rebuildUi)
					dataItem.setValue(index)
				}
			}
		}
	}
}

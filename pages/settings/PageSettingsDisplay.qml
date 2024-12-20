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

		model: ObjectModel {

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
				//% "Units"
				text: qsTrId("settings_units")
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/PageSettingsDisplayUnits.qml", {"title": text})
				}
			}
		}
	}
}

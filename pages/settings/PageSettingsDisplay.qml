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
		id: settingsListView

		model: ObjectModel {

			ListSwitch {
				id: autoBrightness
				//% "Adaptive brightness"
				text: qsTrId("settings_adaptive_brightness")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Gui/AutoBrightness"
				// TODO will this also need bindings similar to gui-v1 vePlatform.hasAutoBrightness?
			}

			ListSlider {
				//% "Brightness"
				text: qsTrId("settings_brightness")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Gui/Brightness"
				writeAccessLevel: VenusOS.User_AccessType_User
				visible: defaultVisible && !autoBrightness.checked
				// TODO will this also need bindings similar to gui-v1 vePlatform.hasBacklight and vePlatform.brightness?
				slider.to: 15   // TODO replace with maxBrightness from venus-platform when available
			}

			ListRadioButtonGroup {
				//% "Display off time"
				text: qsTrId("settings_display_off_time")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Gui/DisplayOff"
				writeAccessLevel: VenusOS.User_AccessType_User

				optionModel: [
					//% "10 sec"
					{ display: qsTrId("settings_displayoff_10sec"), value: 10 },
					//% "30 sec"
					{ display: qsTrId("settings_displayoff_30sec"), value: 30 },
					//% "1 min"
					{ display: qsTrId("settings_displayoff_1min"), value: 60 },
					//% "10 min"
					{ display: qsTrId("settings_displayoff_10min"), value: 600 },
					//% "30 min"
					{ display: qsTrId("settings_displayoff_30min"), value: 1800 },
					//% "Never"
					{ display: qsTrId("settings_displayoff_never"), value: 0 },
				]
			}

			ListRadioButtonGroup {
				//% "Display mode"
				text: qsTrId("settings_display_color_mode")

				optionModel: [
					//: Dark colors mode
					//% "Dark"
					{ display: qsTrId("settings_display_dark_mode") },
					//: Light colors mode
					//% "Light"
					{ display: qsTrId("settings_display_light_mode") },
					//: Auto colors mode: will automatically switch to Dark or Light mode
					//% "Auto"
					{ display: qsTrId("settings_display_auto_mode") },
				]
				// TODO detect auto mode
				currentIndex: Theme.colorScheme === Theme.Dark ? 0 : 1

				onOptionClicked: function(index) {
					if (index === 0) {
						Global.systemSettings.colorScheme.setValue(Theme.Dark)
					} else if (index === 1) {
						Global.systemSettings.colorScheme.setValue(Theme.Light)
					} else {
						// TODO set auto mode
					}
				}
			}

			ListNavigationItem {
				//% "Brief view levels"
				text: qsTrId("settings_brief_view_levels")
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/PageSettingsDisplayBrief.qml", {"title": text})
				}
			}

			ListRadioButtonGroup {
				//% "Language"
				text: qsTrId("settings_language")

				writeAccessLevel: VenusOS.User_AccessType_User
				optionModel: LanguageModel { currentLanguage: Language.current }
				currentIndex: optionModel.currentIndex
				secondaryText: optionModel.currentDisplayText
				popDestination: undefined // don't pop page automatically.
				updateOnClick: false // handle option clicked manually.

				property var pleaseWaitDialog

				onOptionClicked: function(index) {
					// The SystemSettings data point listener will trigger retranslateUi()
					// It may take a few seconds for the backend to deliver the value
					// change to the other data point.  So, display a message to the user.
					languageDataItem.setValue(Language.toCode(optionModel.languageAt(index)))
					pleaseWaitDialog = changingLanguageDialog.createObject(Global.dialogLayer)
					pleaseWaitDialog.open()
				}

				VeQuickItem {
					id: languageDataItem
					uid: Global.systemSettings.serviceUid + "/Settings/Gui/Language"
				}

				Component {
					id: changingLanguageDialog

					ModalWarningDialog {
						dialogDoneOptions: VenusOS.ModalDialog_DoneOptions_NoOptions
						//% "Changing language"
						title: qsTrId("settings_language_changing_language")
						//% "Please wait while the language is changed"
						description: qsTrId("settings_language_please_wait")
					}
				}
			}

			ListNavigationItem {
				//% "Units"
				text: qsTrId("settings_units")
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/PageSettingsDisplayUnits.qml", {"title": text})
				}
			}
		}
	}
}

/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	SettingsListView {
		id: settingsListView

		model: ObjectModel {

			SettingsListSwitch {
				id: autoBrightness
				//% "Adaptive brightness"
				text: qsTrId("settings_adaptive_brightness")
				source: "com.victronenergy.settings/Settings/Gui/AutoBrightness"
				// TODO will this also need bindings similar to gui-v1 vePlatform.hasAutoBrightness?
			}

			SettingsListSlider {
				//% "Brightness"
				text: qsTrId("settings_brightness")
				source: "com.victronenergy.settings/Settings/Gui/Brightness"
				writeAccessLevel: VenusOS.User_AccessType_User
				visible: defaultVisible && !autoBrightness.checked
				// TODO will this also need bindings similar to gui-v1 vePlatform.hasBacklight and vePlatform.brightness?
			}

			SettingsListRadioButtonGroup {
				//% "Display off time"
				text: qsTrId("settings_display_off_time")
				source: "com.victronenergy.settings/Settings/Gui/DisplayOff"
				writeAccessLevel: VenusOS.User_AccessType_User

				model: [
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

			SettingsListRadioButtonGroup {
				//% "Display mode"
				text: qsTrId("settings_display_color_mode")

				model: [
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
					Global.pageManager.popPage()
				}
			}

			SettingsListNavigationItem {
				//% "Brief view levels"
				text: qsTrId("settings_brief_view_levels")
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/PageSettingsDisplayBrief.qml", {"title": text})
				}
			}

			SettingsListRadioButtonGroup {
				//% "Language"
				text: qsTrId("settings_language")
				writeAccessLevel: VenusOS.User_AccessType_User
				model: LanguageModel { currentLanguage: Language.current }
				currentIndex: model.currentIndex
				secondaryText: model.currentDisplayText

				onOptionClicked: function(index) {
					Language.current = model.languageAt(index)
					Global.pageManager.popPage()
				}
			}

			SettingsListNavigationItem {
				//% "Units"
				text: qsTrId("settings_units")
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/PageSettingsDisplayUnits.qml", {"title": text})
				}
			}
		}
	}
}

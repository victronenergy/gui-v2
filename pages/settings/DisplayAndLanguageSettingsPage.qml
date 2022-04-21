/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import QtQuick.Controls

Page {
	id: root

	SettingsListView {
		id: settingsListView

		model: ObjectModel {

			SettingsListSwitch {
				//% "Adaptive brightness"
				text: qsTrId("settings_adaptive_brightness")
				source: "com.victronenergy.settings/Settings/Gui/AutoBrightness"
			}

			SettingsListSlider {
				//% "Brightness"
				text: qsTrId("settings_brightness")
				source: "com.victronenergy.settings/Settings/Gui/Brightness"
				writeAccessLevel: User.AccessUser
			}

			SettingsListRadioButtonGroup {
				//% "Display off time"
				text: qsTrId("settings_display_off_time")
				source: "com.victronenergy.settings/Settings/Gui/DisplayOff"
				writeAccessLevel: User.AccessUser

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
						Theme.load(Theme.screenSize, Theme.Dark)
					} else if (index === 1) {
						Theme.load(Theme.screenSize, Theme.Light)
					} else {
						// TODO set auto mode
					}
				}
			}

			SettingsListNavigationItem {
				//% "Brief view levels"
				text: qsTrId("settings_brief_view_levels")
			}

			SettingsListRadioButtonGroup {
				//% "Language"
				text: qsTrId("settings_language")
				writeAccessLevel: User.AccessUser
				model: LanguageModel { currentLanguage: Language.current }
				currentIndex: model.currentIndex
				secondaryText: model.currentDisplayText

				onOptionClicked: function(index) {
					Language.current = model.languageAt(index)
				}
			}
		}
	}
}

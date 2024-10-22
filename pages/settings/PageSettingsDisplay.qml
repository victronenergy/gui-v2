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

			ListSwitch {
				id: autoBrightness
				//% "Adaptive brightness"
				text: qsTrId("settings_adaptive_brightness")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Gui/AutoBrightness"
				allowed: Qt.platform.os != "wasm" && dataItem.isValid && dataItem.max === 1
			}

			ListSlider {
				//% "Brightness"
				text: qsTrId("settings_brightness")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Gui/Brightness"
				writeAccessLevel: VenusOS.User_AccessType_User
				allowed: defaultAllowed && !autoBrightness.checked && Qt.platform.os != "wasm"
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
				allowed: defaultAllowed && Qt.platform.os != "wasm"
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
				]
				currentIndex: Theme.colorScheme === Theme.Light ? 1 : 0

				onOptionClicked: function(index) {
					Global.systemSettings.colorScheme.setValue(index === 1 ? Theme.Light : Theme.Dark)
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

			ListNavigationItem {
				//% "Units"
				text: qsTrId("settings_units")
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/PageSettingsDisplayUnits.qml", {"title": text})
				}
			}

			ListNavigationItem {
				//% "Minimum and maximum gauge ranges"
				text: qsTrId("settings_display_minmax")
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/PageSettingsDisplayMinMax.qml", {"title": text})
				}
			}

			ListNavigationItem {
				//% "Start page"
				text: qsTrId("settings_brief_view_start_page")
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/PageSettingsDisplayStartPage.qml", {"title": text})
				}
			}

			ListRadioButtonGroup {
				id: runningVersion

				property ModalWarningDialog _restartDialog

				text: onScreenGuiv2Possible.value
					  //% "User interface"
					? qsTrId("settings_display_onscreen_ui")
					  //% "User interface (Remote Console)"
					: qsTrId("settings_display_remote_console_ui")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Gui/RunningVersion"
				writeAccessLevel: VenusOS.User_AccessType_User
				updateDataOnClick: false
				optionModel: [
					{
						//% "Classic UI"
						display: qsTrId("settings_display_classic_ui"),
						value: 1
					},
					{
						//% "New UI"
						display: qsTrId("settings_display_new_ui"),
						value: 2
					},
				]

				onOptionClicked: function(index) {
					// When the /RunningVersion changes, venus-platform quits the currently-running
					// app and starts the selected version. Note: on device, user may not see the
					// dialog at all, depending on how quickly the app exits.
					if (!_restartDialog) {
						_restartDialog = restartDialogComponent.createObject(Global.dialogLayer)
					}
					_restartDialog.versionName = optionModel[index].display
					_restartDialog.settingText = runningVersion.text
					_restartDialog.open()
					dataItem.setValue(optionModel[index].value)
				}

				VeQuickItem {
					id: onScreenGuiv2Possible
					uid: Global.venusPlatform.serviceUid + "/Gui/OnScreenGuiv2Supported"
				}

				Component {
					id: restartDialogComponent

					ModalWarningDialog {
						property string settingText // "User interface" or "User interface (Remote Console)"
						property string versionName

						title: BackendConnection.type === BackendConnection.DBusSource
							  //% "Restarting application..."
							? qsTrId("settings_restarting_app")
							  //: %1 = The name of the setting being updated
							  //% "%1 updated"
							: qsTrId("settings_app_restarted").arg(settingText)
						description: BackendConnection.type === BackendConnection.DBusSource
							  //: %1 = the UI version that the system is switching to
							  //% "User interface will switch to %1."
							? qsTrId("settings_switch_ui").arg(versionName)
							  //: %1 = The name of the setting being updated
							  //: %2 = the UI version that the system has switched to.
							  //% "%1 is set to %2"
							: qsTrId("settings_has_switched_ui").arg(settingText).arg(versionName)

						dialogDoneOptions: BackendConnection.type === BackendConnection.DBusSource
								? VenusOS.ModalDialog_DoneOptions_NoOptions
								: VenusOS.ModalDialog_DoneOptions_OkOnly
						footer.enabled: dialogDoneOptions !== VenusOS.ModalDialog_DoneOptions_NoOptions
						footer.opacity: footer.enabled ? 1 : 0
					}
				}
			}
		}
	}
}

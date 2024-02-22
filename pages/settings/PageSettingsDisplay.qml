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
				updateOnClick: false // handle option clicked manually.

				onOptionClicked: function(index) {
					// The SystemSettings data point listener will trigger retranslateUi()
					// It may take a few seconds for the backend to deliver the value
					// change to the other data point.  So, display a message to the user.
					languageDataItem.setValue(Language.toCode(optionModel.languageAt(index)))
					Global.dialogLayer.open(changingLanguageDialog)
				}

				LanguageModel {
					id: languageModel
					//% "(no browser support)"
					unsupportedLanguageMessage: qsTrId("settings_language_no_browser_support")
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
						dialogDoneOptions: VenusOS.ModalDialog_DoneOptions_NoOptions
						//% "Changing language"
						title: qsTrId("settings_language_changing_language")
						//% "Please wait while the language is changed."
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

			ListRadioButtonGroup {
				id: runningVersion

				property ModalWarningDialog _restartDialog

				//% "Onscreen UI (GX Touch & Ekrano)"
				text: qsTrId("settings_display_onscreen_ui")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Gui/RunningVersion"
				writeAccessLevel: VenusOS.User_AccessType_User
				updateOnClick: false
				optionModel: [
					//% "Standard version"
					{ display: qsTrId("settings_display_standard_version"), value: 1 },
					//% "Gui-v2 (beta) version"
					{ display: qsTrId("settings_display_beta_version"), value: 2 },
				]

				onOptionClicked: function(index) {
					// When the /RunningVersion changes, venus-platform quits the currently-running
					// app and starts the selected version. Note: on device, user may not see the
					// dialog at all, depending on how quickly the app exits.
					if (!_restartDialog) {
						_restartDialog = restartDialogComponent.createObject(Global.dialogLayer)
					}
					_restartDialog.versionName = optionModel[index].display
					_restartDialog.open()
					dataItem.setValue(optionModel[index].value)
				}

				Component {
					id: restartDialogComponent

					ModalWarningDialog {
						property string versionName

						title: BackendConnection.type === BackendConnection.DBusSource
							  //% "Restarting application..."
							? qsTrId("settings_restarting_app")
							  //% "Application restarted"
							: qsTrId("settings_app_restarted")
						description: BackendConnection.type === BackendConnection.DBusSource
							  //: %1 = the UI version that the system is switching to
							  //% "Onscreen UI will switch to %1."
							? qsTrId("settings_switch_ui").arg(versionName)
							   //: %1 = the UI version that the system has switched to.
							  //% "Onscreen UI has switched to %1."
							: qsTrId("settings_has_switched_ui").arg(versionName)

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

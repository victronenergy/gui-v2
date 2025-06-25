/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	readonly property bool isClean: fsModifiedStateItem.value === VenusOS.ModificationChecks_FsModifiedState_Clean
		&& systemHooksStateItem.valid && !(systemHooksStateItem.value & VenusOS.ModificationChecks_SystemHooksState_HookLoadedAtStartup)
	readonly property bool isModified: fsModifiedStateItem.value === VenusOS.ModificationChecks_FsModifiedState_Modified
		|| (systemHooksStateItem.valid && (systemHooksStateItem.value & VenusOS.ModificationChecks_SystemHooksState_HookLoadedAtStartup))
	readonly property bool isRaspberry: modelItem.valid && modelItem.value.indexOf("Raspberry") !== -1

	function supportStateText() {
		let runningServices = []

		if (isModified){
			//% "Modifications installed"
			return qsTrId("pagesettingsgeneral_modificationchecks_modified")
		}

		if (modbusTcpItem.value !== 0){
			//% "Modbus TCP Server"
			runningServices.push(qsTrId("pagesettingsgeneral_modificationchecks_modbus"))
		}
		if (signalKItem.valid && signalKItem.value !== 0) {
			//% "Signal K"
			runningServices.push(qsTrId("pagesettingsgeneral_modificationchecks_signalk"))
		}
		if (nodeRedItem.valid && nodeRedItem.value !== VenusOS.NodeRed_Mode_Disabled) {
			//% "Node-RED"
			runningServices.push(qsTrId("pagesettingsgeneral_modificationchecks_nodered"))
		}
		if (runningServices.length > 0){
			let runningServicesText = runningServices.join(", ")
			// Check if the text is longer then 20 characters
			if (runningServicesText.length > 20) {
				//% "%1 running integrations"
				return qsTrId("pagesettingsgeneral_modificationchecks_running_integrations").arg(runningServices.length)
			}
			return runningServices.join(", ")
		}

		if (isRaspberry){
			//% "Unsupported GX device"
			return qsTrId("pagesettingsgeneral_modificationchecks_unsupported_device")
		}

		if (isClean){
			//% "Clean"
			return qsTrId("pagesettingsgeneral_modificationchecks_clean")
		}

		return ""
	}

	function supportStateColor() {
		if (isModified){
			// "Modified"
			return Theme.color_red
		}
		if (modbusTcpItem.value !== 0
			|| (signalKItem.valid && signalKItem.value !== 0)
			|| (nodeRedItem.valid && nodeRedItem.value !== 0)) {
			// "Running integrations"
			return Theme.color_orange
		}
		if (isRaspberry){
			// "Unsupported GX device"
			return Theme.color_red
		}
		if (isClean){
			// "Clean"
			return Theme.color_green
		}

		// ""
		return Theme.color_font_secondary
	}

	VeQuickItem {
		id: modelItem
		uid: Global.venusPlatform.serviceUid + "/Device/Model"
	}

	VeQuickItem {
		id: modbusTcpItem
		uid: Global.systemSettings.serviceUid + "/Settings/Services/Modbus"
	}
	VeQuickItem {
		id: signalKItem
		uid: Global.venusPlatform.serviceUid + "/Services/SignalK/Enabled"
	}
	VeQuickItem {
		id: nodeRedItem
		uid: Global.venusPlatform.serviceUid + "/Services/NodeRed/Mode"
	}

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
					// change to that other data point. So, display a message to the user.
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
				//% "Documentation"
				text: qsTrId("pagesettingsgeneral_documentation")
				onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsDocumentation.qml", {"title": text})
			}

			ListNavigation {
				//% "Support status (modifications checks)"
				text: qsTrId("pagesettingsgeneral_support_status_modification_checks")
				secondaryText: supportStateText()
				secondaryLabel.color: supportStateColor()
				preferredVisible: fsModifiedStateItem.valid && systemHooksStateItem.valid
				onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsSupportStatus.qml", {"title": text})

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

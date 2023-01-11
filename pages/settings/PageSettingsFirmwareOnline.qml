/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil

Page {
	id: root

	SettingsListView {
		id: settingsListView

		model: ObjectModel {

			SettingsListRadioButtonGroup {
				//% "Auto update"
				text: qsTrId("settings_auto_update")
				source: "com.victronenergy.settings/Settings/System/AutoUpdate"
				writeAccessLevel: VenusOS.User_AccessType_User
				optionModel: [
					{ display: CommonWords.disabled, value: VenusOS.Firmware_AutoUpdate_Disabled },
					//% "Check only"
					{ display: qsTrId("settings_firmware_check_only"), value: VenusOS.Firmware_AutoUpdate_CheckOnly },
					//% "Check and download only"
					{ display: qsTrId("settings_firmware_check_and_download_only"), value: VenusOS.Firmware_AutoUpdate_CheckAndDownloadOnly, readOnly: true },
					//% "Check and update"
					{ display: qsTrId("settings_firmware_check_and_update"), value: VenusOS.Firmware_AutoUpdate_CheckAndUpdate }
				]
			}

			SettingsListRadioButtonGroup {
				//% "Update feed"
				text: qsTrId("settings_update_feed")
				source: "com.victronenergy.settings/Settings/System/ReleaseType"
				writeAccessLevel: VenusOS.User_AccessType_User
				optionModel: [
					//% "Latest release"
					{ display: qsTrId("settings_firmware_latest_release"), value: FirmwareUpdater.FirmwareRelease },
					//% "Latest release candidate"
					{ display: qsTrId("settings_firmware_latest_release_candidate"), value: FirmwareUpdater.FirmwareCandidate },
					//: Select the 'Testing' update feed
					//% "Testing"
					{ display: qsTrId("settings_firmware_testing"), value: FirmwareUpdater.FirmwareRelease, readOnly: !Global.systemSettings.canAccess(VenusOS.User_AccessType_Service) },
					//: Select the 'Develop' update feed
					//% "Develop"
					{ display: qsTrId("settings_firmware_develop"), value: FirmwareUpdater.FirmwareDevelop, readOnly: true },
				]
			}

			SettingsListRadioButtonGroup {
				//% "Image type"
				text: qsTrId("settings_firmware_image_type")
				source: "com.victronenergy.settings/Settings/System/ImageType"
				visible: largeImageSupport.value === 1
				optionModel: [
					//% "Normal"
					{ display: qsTrId("settings_firmware_normal"), value: FirmwareUpdater.ImageTypeNormal },
					//% "Large"
					{ display: qsTrId("settings_firmware_large"), value: FirmwareUpdater.ImageTypeLarge },
				]

				DataPoint {
					id: largeImageSupport
					source: "com.victronenergy.platform/Firmware/LargeImageSupport"
				}
			}

			FirmwareCheckListButton {
				//% "Check for updates"
				text: qsTrId("settings_firmware_check_for_updates")
				updateType: VenusOS.Firmware_UpdateType_Online
			}

			SettingsListButton {
				id: installUpdate

				//% "Update available"
				text: qsTrId("settings_firmware_update_available")
				button.text: {
					if (Global.firmwareUpdate.state === FirmwareUpdater.DownloadingAndInstalling) {
						if (progress.value) {
							//: Firmware update progress. %1 = firmware version, %2 = current update progress
							//% "Installing %1 %2%"
							return qsTrId("settings_firmware_online_installing_progress").arg(Global.firmwareUpdate.onlineAvailableVersion).arg(progress.value)
						}
						//: %1 = firmware version
						//% "Installing %1..."
						return qsTrId("settings_firmware_online_installing").arg(Global.firmwareUpdate.onlineAvailableVersion)
					} else {
						//: %1 = firmware version
						//% "Press to update to %1"
						return qsTrId("settings_firmware_online_press_to_update_to").arg(Global.firmwareUpdate.onlineAvailableVersion)
					}
				}

				enabled: !Global.firmwareUpdate.busy
				writeAccessLevel: VenusOS.User_AccessType_User
				visible: Global.firmwareUpdate.onlineAvailableVersion && Global.firmwareUpdate.state !== FirmwareUpdater.Checking
				onClicked: {
					Global.firmwareUpdate.installUpdate(VenusOS.Firmware_UpdateType_Online)
				}

				DataPoint {
					id: progress
					source: "com.victronenergy.platform/Firmware/Progress"
				}
			}

			SettingsListTextItem {
				//% "Update build date/time"
				text: qsTrId("settings_firmware_update_build_date_time")
				source: "com.victronenergy.platform/Firmware/Online/AvailableBuild"
				visible: installUpdate.visible && Global.systemSettings.canAccess(VenusOS.User_AccessType_SuperUser)
			}
		}
	}
}

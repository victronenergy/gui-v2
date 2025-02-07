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

			ListRadioButtonGroup {
				//% "Auto update"
				text: qsTrId("settings_auto_update")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/System/AutoUpdate"
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

			ListRadioButtonGroup {
				//% "Update feed"
				text: qsTrId("settings_update_feed")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/System/ReleaseType"
				optionModel: [
					//% "Official release"
					{ display: qsTrId("settings_firmware_official_release"), value: FirmwareUpdater.FirmwareRelease },
					//% "Beta release"
					{ display: qsTrId("settings_firmware_beta_release"), value: FirmwareUpdater.FirmwareCandidate },
					//: Select the 'Testing' update feed
					//% "Testing (Victron internal)"
					{ display: qsTrId("settings_firmware_testing_internal"), value: FirmwareUpdater.FirmwareTesting, readOnly: !Global.systemSettings.canAccess(VenusOS.User_AccessType_Service) },
					//: Select the 'Develop' update feed
					//% "Develop (Victron internal)"
					{ display: qsTrId("settings_firmware_develop_internal"), value: FirmwareUpdater.FirmwareDevelop, readOnly: true },
				]
			}

			ListRadioButtonGroup {
				//% "Image type"
				text: qsTrId("settings_firmware_image_type")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/System/ImageType"
				preferredVisible: largeImageSupport.value === 1
				optionModel: [
					//% "Normal"
					{ display: qsTrId("settings_firmware_normal"), value: FirmwareUpdater.ImageTypeNormal },
					//% "Large"
					{ display: qsTrId("settings_firmware_large"), value: FirmwareUpdater.ImageTypeLarge },
				]

				VeQuickItem {
					id: largeImageSupport
					uid: Global.venusPlatform.serviceUid + "/Firmware/LargeImageSupport"
				}
			}

			ListFirmwareCheckButton {
				//% "Check for updates"
				text: qsTrId("settings_firmware_check_for_updates")
				updateType: VenusOS.Firmware_UpdateType_Online
			}

			ListButton {
				id: installUpdate

				//% "Update available"
				text: qsTrId("settings_firmware_update_available")
				secondaryText: {
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

				interactive: !Global.firmwareUpdate.busy
				writeAccessLevel: VenusOS.User_AccessType_User
				preferredVisible: !!Global.firmwareUpdate.onlineAvailableVersion && !Global.firmwareUpdate.checkingForUpdate
				onClicked: {
					Global.firmwareUpdate.installUpdate(VenusOS.Firmware_UpdateType_Online)
				}

				VeQuickItem {
					id: progress
					uid: Global.venusPlatform.serviceUid + "/Firmware/Progress"
				}
			}

			ListText {
				//% "Update build date/time"
				text: qsTrId("settings_firmware_update_build_date_time")
				dataItem.uid: Global.venusPlatform.serviceUid + "/Firmware/Online/AvailableBuild"
				preferredVisible: installUpdate.preferredVisible
					&& Global.systemSettings.canAccess(VenusOS.User_AccessType_SuperUser)
			}
		}
	}
}

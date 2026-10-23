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
				dataItem.uid: Services.settings.serviceUid + "/Settings/System/AutoUpdate"
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
				dataItem.uid: Services.settings.serviceUid + "/Settings/System/ReleaseType"
				optionModel: [
					//% "Official release"
					{ display: qsTrId("settings_firmware_official_release"), value: FirmwareUpdater.FirmwareRelease },
					//% "Beta release"
					{ display: qsTrId("settings_firmware_beta_release"), value: FirmwareUpdater.FirmwareCandidate },
					//: Select the 'Testing' update feed
					//% "Testing (Victron internal)"
					{ display: qsTrId("settings_firmware_testing_internal"), value: FirmwareUpdater.FirmwareTesting, readOnly: !Services.settings.canAccess(VenusOS.User_AccessType_Service) },
					//: Select the 'Develop' update feed
					//% "Develop (Victron internal)"
					{ display: qsTrId("settings_firmware_develop_internal"), value: FirmwareUpdater.FirmwareDevelop, readOnly: true },
				]
			}

			ListRadioButtonGroup {
				text: CommonWords.image_type
				dataItem.uid: Services.settings.serviceUid + "/Settings/System/ImageType"
				preferredVisible: largeImageSupport.value === 1
				optionModel: [
					{ display: CommonWords.firmware_type_normal, value: FirmwareUpdater.ImageTypeNormal },
					{ display: CommonWords.firmware_type_large, value: FirmwareUpdater.ImageTypeLarge },
				]

				VeQuickItem {
					id: largeImageSupport
					uid: Services.platform.serviceUid + "/Firmware/LargeImageSupport"
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
						return CommonWords.update_to_version.arg(Global.firmwareUpdate.onlineAvailableVersion)
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
					uid: Services.platform.serviceUid + "/Firmware/Progress"
				}
			}

			ListText {
				//% "Update build date/time"
				text: qsTrId("settings_firmware_update_build_date_time")
				dataItem.uid: Services.platform.serviceUid + "/Firmware/Online/AvailableBuild"
				preferredVisible: installUpdate.preferredVisible
					&& Services.settings.canAccess(VenusOS.User_AccessType_SuperUser)
			}
		}
	}
}

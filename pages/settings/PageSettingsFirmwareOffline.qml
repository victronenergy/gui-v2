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

			ListFirmwareCheckButton {
				//% "Check for updates on SD/USB"
				text: qsTrId("settings_firmware_check_for_updates_on_sd_usb")
				updateType: VenusOS.Firmware_UpdateType_Offline
			}

			ListButton {
				id: installUpdate

				//% "Firmware found"
				text: qsTrId("settings_firmware_found")
				secondaryText: {
					if (Global.firmwareUpdate.state === FirmwareUpdater.DownloadingAndInstalling) {
						//: %1 = firmware version
						//% "Installing %1"
						return qsTrId("settings_firmware_offline_installing").arg(Global.firmwareUpdate.offlineAvailableVersion)
					} else {
						//: %1 = firmware version
						//% "Press to update to %1"
						return qsTrId("settings_firmware_offline_press_to_install").arg(Global.firmwareUpdate.offlineAvailableVersion)
					}
				}

				interactive: !Global.firmwareUpdate.busy
				writeAccessLevel: VenusOS.User_AccessType_User
				preferredVisible: !!Global.firmwareUpdate.offlineAvailableVersion && !Global.firmwareUpdate.checkingForUpdate
				onClicked: {
					Global.firmwareUpdate.installUpdate(VenusOS.Firmware_UpdateType_Offline)
				}
			}

			ListText {
				//% "Firmware build date/time"
				text: qsTrId("settings_firmware_build_date_time")
				dataItem.uid: Global.venusPlatform.serviceUid + "/Firmware/Offline/AvailableBuild"
				preferredVisible: installUpdate.preferredVisible
					&& Global.systemSettings.canAccess(VenusOS.User_AccessType_SuperUser)
			}

			ListMountStateButton {
				interactive: mounted && Global.firmwareUpdate.state !== FirmwareUpdater.DownloadingAndInstalling
			}
		}
	}
}

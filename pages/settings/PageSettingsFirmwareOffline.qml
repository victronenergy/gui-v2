/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil

Page {
	id: root

	property FirmwareUpdate firmwareUpdate: FirmwareUpdate {}

	GradientListView {
		id: settingsListView

		model: ObjectModel {

			FirmwareCheckListButton {
				//% "Check for updates on SD/USB"
				text: qsTrId("settings_firmware_check_for_updates_on_sd_usb")
				updateType: VenusOS.Firmware_UpdateType_Offline
				firmwareUpdate: root.firmwareUpdate
			}

			ListButton {
				id: installUpdate

				//% "Firmware found"
				text: qsTrId("settings_firmware_found")
				button.text: {
					if (root.firmwareUpdate.state === FirmwareUpdater.DownloadingAndInstalling) {
						//: %1 = firmware version
						//% "Installing %1"
						return qsTrId("settings_firmware_offline_installing").arg(root.firmwareUpdate.offlineAvailableVersion)
					} else {
						//: %1 = firmware version
						//% "Press to update to %1"
						return qsTrId("settings_firmware_offline_press_to_install").arg(root.firmwareUpdate.offlineAvailableVersion)
					}
				}

				enabled: !root.firmwareUpdate.busy
				writeAccessLevel: VenusOS.User_AccessType_User
				visible: !!root.firmwareUpdate.offlineAvailableVersion
				onClicked: {
					root.firmwareUpdate.installUpdate(VenusOS.Firmware_UpdateType_Offline)
				}
			}

			ListTextItem {
				//% "Firmware build date/time"
				text: qsTrId("settings_firmware_build_date_time")
				dataSource: "com.victronenergy.platform/Firmware/Offline/AvailableBuild"
				visible: installUpdate.visible && Global.systemSettings.canAccess(VenusOS.User_AccessType_SuperUser)
			}

			MountStateListButton {}
		}
	}
}

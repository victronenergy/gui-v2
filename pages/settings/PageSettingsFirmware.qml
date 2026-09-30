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

			ListText {
				id: remotePort

				text: CommonWords.firmware_version
				secondaryText: FirmwareVersion.versionText(dataItem.value, "venus")
				dataItem.uid: Services.platform.serviceUid + "/Firmware/Installed/Version"
			}

			ListText {
				//% "Build date/time"
				text: qsTrId("settings_build_date_time")
				dataItem.uid: Services.platform.serviceUid + "/Firmware/Installed/Build"
			}

			ListFirmwareImageTypeInstalled { }

			ListNavigation {
				//% "Online updates"
				text: qsTrId("settings_online_updates")
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/PageSettingsFirmwareOnline.qml", { title: text })
				}
			}

			ListNavigation {
				//% "Install firmware from SD/USB"
				text: qsTrId("settings_install_firmware_from_sd_usb")
				preferredVisible: !Services.platform.isContainer
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/PageSettingsFirmwareOffline.qml", { title: text })
				}
			}

			ListNavigation {
				//% "Stored backup firmware"
				text: qsTrId("settings_stored_backup_firmware")
				preferredVisible: !Services.platform.isContainer
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/PageSettingsRootfsSelect.qml", { title: text })
				}
			}

			ListInfoLabel {
				//% "To update, pull a new container image."
				text: qsTrId("settings_firmware_container_update")
				preferredVisible: Services.platform.isContainer
			}
		}
	}
}

/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

ListPage {
	id: root

	listView: GradientListView {
		id: settingsListView

		model: ObjectModel {

			ListTextItem {
				id: remotePort

				//% "Firmware version"
				text: qsTrId("settings_firmware_version")
				dataSource: "com.victronenergy.platform/Firmware/Installed/Version"
			}

			ListTextItem {
				//% "Build date/time"
				text: qsTrId("settings_build_date_time")
				dataSource: "com.victronenergy.platform/Firmware/Installed/Build"
			}

			ListNavigationItem {
				//% "Online updates"
				text: qsTrId("settings_online_updates")
				listPage: root
				listIndex: ObjectModel.index
				onClicked: {
					listPage.navigateTo("/pages/settings/PageSettingsFirmwareOnline.qml", { title: text }, listIndex)
				}
			}

			ListNavigationItem {
				//% "Install firmware from SD/USB"
				text: qsTrId("settings_install_firmware_from_sd_usb")
				listPage: root
				listIndex: ObjectModel.index
				onClicked: {
					listPage.navigateTo("/pages/settings/PageSettingsFirmwareOffline.qml", { title: text }, listIndex)
				}
			}

			ListNavigationItem {
				//% "Stored backup firmware"
				text: qsTrId("settings_stored_backup_firmware")
				listPage: root
				listIndex: ObjectModel.index
				onClicked: {
					listPage.navigateTo("/pages/settings/PageSettingsRootfsSelect.qml", { title: text }, listIndex)
				}
			}
		}
	}
}

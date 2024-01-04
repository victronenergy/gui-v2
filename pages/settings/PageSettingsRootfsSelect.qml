/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil

Page {
	id: root

	property bool _autoUpdateDisabled: autoUpdate.value !== 1
	property bool _switchingEnabled: backupVersionItem.isValid
	property bool _rebooting

	VeQuickItem {
		id: autoUpdate
		uid: Global.systemSettings.serviceUid + "/Settings/System/AutoUpdate"
	}
	VeQuickItem {
		id: currentVersionItem
		uid: Global.venusPlatform.serviceUid + "/Firmware/Installed/Version"
	}
	VeQuickItem {
		id: currentBuildItem
		uid: Global.venusPlatform.serviceUid + "/Firmware/Installed/Build"
	}
	VeQuickItem {
		id: backupVersionItem
		uid: Global.venusPlatform.serviceUid + "/Firmware/Backup/AvailableVersion"
	}
	VeQuickItem {
		id: backupBuildItem
		uid: Global.venusPlatform.serviceUid + "/Firmware/Backup/AvailableBuild"
	}
	VeQuickItem {
		id: activateBackup
		uid: Global.venusPlatform.serviceUid + "/Firmware/Backup/Activate"
	}

	GradientListView {
		id: settingsListView

		model: ObjectModel {
			ListLabel {
				//% "This option allows you to switch between the current and the previous firmware version. No internet or sdcard needed."
				text: qsTrId("settings_firmware_version_switch_option")
			}

			ListButton {
				id: backupVersion

				//: %1 = backup version, %2 = backup version build number
				//% "Firmware %1 (%2)"
				text: qsTrId("settings_firmware_backup_version").arg(backupVersionItem.value).arg(backupBuildItem.value)
				button.text: root._autoUpdateDisabled
					 //% "Press to boot"
				   ? qsTrId("settings_firmware_press_to_boot")
				   : CommonWords.disabled
				visible: root._switchingEnabled

				onClicked: {
					if (_autoUpdateDisabled) {
						text = ""
						root._rebooting = true
						// TODO confirm whether we need to show "icon-restart-active" instead of the normal notification icon
						//: %1 = backup version
						//% "Rebooting to %1"
						Global.showToastNotification(VenusOS.Notification_Info, qsTrId("settings_firmware_rebooting_to").arg(backupVersionItem.value), 50000)
						activateBackup.setValue(1)
					} else {
						//% "Switching firmware version is not possible when auto update is set to \"Check and update\". Set auto update to \"Disabled\" or \"Check only\" to enable this option."
						Global.showToastNotification(VenusOS.Notification_Info, qsTrId("settings_firmware_switching_not_possible"), 10000)
					}
				}
			}

			ListTextItem {
				id: currentVersion

				//: %1 = current firmware version, %2 = current firmware build number
				//% "Firmware %1 (%2)"
				text: qsTrId("settings_firmware_current_version").arg(currentVersionItem.value).arg(currentBuildItem.value)
				secondaryText: CommonWords.running_status
				visible: currentVersionItem.isValid && root._switchingEnabled
			}

			ListTextItem {
				//% "Backup firmware not available"
				text: qsTrId("settings_firmware_backup_not_available")
				visible: !currentVersion.visible && !backupVersion.visible && !root._rebooting
			}
		}
	}
}

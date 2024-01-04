/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil

QtObject {
	id: root

	readonly property string onlineAvailableVersion: _onlineVersion.value || ""
	readonly property string offlineAvailableVersion: _offlineVersion.value || ""
	readonly property bool busy: state > FirmwareUpdater.Idle
	readonly property var state: _stateItem.value
	property bool checkingForUpdate

	property int _updateType

	property VeQuickItem _stateItem: VeQuickItem {
		uid: Global.venusPlatform.serviceUid + "/Firmware/State"

		onValueChanged: {
			let msg = ""
			switch (value) {
			case FirmwareUpdater.Idle:
			case FirmwareUpdater.UpdateFileNotFound:
				// If a new version is available, the online/offline version value will be available
				// together with the new state value, but the version may not be deserialized and
				// set until after the state change. So, wait until the next event loop to be sure.
				Qt.callLater(root._finishUpdateCheck)
				break
			case FirmwareUpdater.ErrorDuringChecking:
				//% "Error while checking for firmware updates"
				msg = qsTrId("settings_firmware_error_during_checking_for_updates")
				break
			case FirmwareUpdater.Checking:
				break
			case FirmwareUpdater.DownloadingAndInstalling:
				if (_onlineVersion.isValid) {
					//: %1 = firmware version
					//% "Downloading and installing firmware %1..."
					msg = qsTrId("settings_firmware_downloading_and_installing").arg(_onlineVersion.value)
				} else if (_offlineVersion.isValid) {
					//: %1 = firmware version
					//% "Installing %1..."
					msg = qsTrId("settings_firmware_installing").arg(_offlineVersion.value)
				} else {
					//% "Installing firmware..."
					msg = qsTrId("settings_firmware_installing_firmware")
				}
				break
			case FirmwareUpdater.ErrorDuringUpdating:
				//% "Error during firmware installation"
				msg = qsTrId("settings_firmware_error_during_installation")
				break
			case FirmwareUpdater.Rebooting:
				//% "Firmware installed, rebooting."
				msg = qsTrId("settings_firmware_installed_rebooting")
				break
			}
			if (msg) {
				// TODO confirm whether we need to show "icon-firmwareupdate-active" instead of the normal notification icon
				Global.showToastNotification(VenusOS.Notification_Info, msg, 10000)
			}
		}
	}

	// online updates
	property VeQuickItem _onlineCheckUpdate: VeQuickItem {
		uid: Global.venusPlatform.serviceUid + "/Firmware/Online/Check"
	}
	property VeQuickItem _onlineVersion: VeQuickItem {
		uid: Global.venusPlatform.serviceUid + "/Firmware/Online/AvailableVersion"
	}
	property VeQuickItem _onlineInstallUpdate: VeQuickItem {
		uid: Global.venusPlatform.serviceUid + "/Firmware/Online/Install"
	}

	// offline updates
	property VeQuickItem _offlineCheckUpdate: VeQuickItem {
		uid: Global.venusPlatform.serviceUid + "/Firmware/Offline/Check"
	}
	property VeQuickItem _offlineVersion: VeQuickItem {
		uid: Global.venusPlatform.serviceUid + "/Firmware/Offline/AvailableVersion"
	}
	property VeQuickItem _offlineInstallUpdate: VeQuickItem {
		uid: Global.venusPlatform.serviceUid + "/Firmware/Offline/Install"
	}

	function checkForUpdate(updateType) {
		_updateType = updateType
		checkingForUpdate = true
		if (updateType === VenusOS.Firmware_UpdateType_Online) {
			_onlineCheckUpdate.setValue(1)
		} else if (updateType === VenusOS.Firmware_UpdateType_Offline) {
			_offlineCheckUpdate.setValue(1)
		} else {
			console.warn("checkForUpdate(): unknown firmware update type:", updateType)
		}
	}

	function installUpdate(updateType) {
		_updateType = updateType
		if (updateType === VenusOS.Firmware_UpdateType_Online) {
			_onlineInstallUpdate.setValue(1)
		} else if (updateType === VenusOS.Firmware_UpdateType_Offline) {
			_offlineInstallUpdate.setValue(1)
		} else {
			console.warn("installUpdate(): unknown firmware update type:", updateType)
		}
	}

	function _finishUpdateCheck() {
		if (!checkingForUpdate) {
			return
		}
		let msg = ""
		checkingForUpdate = false
		if (_updateType === VenusOS.Firmware_UpdateType_Online && !_onlineVersion.isValid) {
			//% "No newer version available"
			msg = qsTrId("settings_firmware_no_newer_version_available")
		} else if (_updateType === VenusOS.Firmware_UpdateType_Offline && !_offlineVersion.isValid) {
			//% "No firmware found"
			msg = qsTrId("settings_firmware_no_firmware_found")
		}
		if (msg) {
			Global.showToastNotification(VenusOS.Notification_Info, msg, 10000)
		}
	}
}

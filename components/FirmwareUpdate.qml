/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	readonly property string onlineAvailableVersion: _onlineVersion.value || ""
	readonly property string offlineAvailableVersion: _offlineVersion.value || ""
	readonly property bool busy: state > FirmwareUpdater.Idle
	readonly property var state: _stateItem.value
	readonly property alias checkingForUpdate: updateCheckTimer.running

	property int _updateType

	property Timer _updateCheckTimeout: Timer {
		id: updateCheckTimer
		repeat: false
		running: false
		onTriggered: root._finishUpdateCheck()
	}

	property VeQuickItem _stateItem: VeQuickItem {

		// Make sure notificationLayer is ready before reading the firmware state,
		// otherwise Global.showToastNotification() call inside onValueChanged signal handler will fail.
		uid: (Global.allPagesLoaded && !!Global.notificationLayer) ? Global.venusPlatform.serviceUid + "/Firmware/State" : ""

		onValueChanged: {
			if (uid === "" || !valid) {
				return
			}

			let msg = ""
			switch (value) {
			case FirmwareUpdater.Idle: // fall through
			case FirmwareUpdater.UpdateFileNotFound:
				// If a new version is available, the online/offline version value will be available
				// together with the new state value, but the version may not be deserialized and
				// set until after the state change.  Also, an intermediate invalid value may be
				// set while waiting on the backend to supply the actual value.
				// So, wait asynchronously for a valid value to be provided.
				if (updateCheckTimer.running) {
					updateCheckTimer.stop()
					updateCheckTimer.interval = 500
					updateCheckTimer.start()
				}
				break
			case FirmwareUpdater.ErrorDuringChecking:
				//% "Error while checking for firmware updates"
				msg = qsTrId("settings_firmware_error_during_checking_for_updates")
				break
			case FirmwareUpdater.Checking:
				break
			case FirmwareUpdater.DownloadingAndInstalling:
				if (_onlineVersion.valid) {
					//: %1 = firmware version
					//% "Downloading and installing firmware %1..."
					msg = qsTrId("settings_firmware_downloading_and_installing").arg(_onlineVersion.value)
				} else if (_offlineVersion.valid) {
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
				//% "Firmware installed, device rebooting"
				msg = qsTrId("settings_firmware_installed_rebooting")
				// Note: for WebAssembly, don't yet reload the page.
				// If we did the reload now, we would still get the wrong blob.
				// Instead, wait for the device to reboot (i.e. requires
				// a full disconnect/reconnect cycle) then react to the
				// updated build version we receive (reload the page).
				break
			default:
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
		onValidChanged: {
			if (valid && _updateType === VenusOS.Firmware_UpdateType_Online && updateCheckTimer.running) {
				updateCheckTimer.stop()
				Qt.callLater(root._finishUpdateCheck)
			}
		}
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
		onValidChanged: {
			if (valid && _updateType === VenusOS.Firmware_UpdateType_Offline && updateCheckTimer.running) {
				updateCheckTimer.stop()
				Qt.callLater(root._finishUpdateCheck)
			}
		}
	}
	property VeQuickItem _offlineInstallUpdate: VeQuickItem {
		uid: Global.venusPlatform.serviceUid + "/Firmware/Offline/Install"
	}

	// installed build
	property VeQuickItem _firmwareInstalledBuild: VeQuickItem {
		uid: Global.venusPlatform.serviceUid + "/Firmware/Installed/Build"
		onValueChanged: {
			if (Qt.platform.os == "wasm" && value != null && value.length > 0) {
				if (Global.firmwareInstalledBuild.length > 0 &&
						Global.firmwareInstalledBuild != value) {
					console.warn("Firmware update detected, reloading page in 10 seconds"
						+ " (" + Global.firmwareInstalledBuild + " != " + value + ")")
					Global.firmwareInstalledBuildUpdated = true
				}
				Global.firmwareInstalledBuild = value
			}
		}

		// VRM sometimes won't provide the latest value to existing clients
		// after a device restart, and MQTT comms can be unreliable.
		// So, periodically force read the firmware installed build value.
		property Timer forceReadTimer: Timer {
			interval: 1000 * 60 * 10
			repeat: true
			running: Qt.platform.os == "wasm"
			onTriggered: root._firmwareInstalledBuild.getValue(true)
		}
	}

	function checkForUpdate(updateType) {
		_updateType = updateType
		updateCheckTimer.interval = 8000 // give up after 8 seconds
		updateCheckTimer.start()
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
		let msg = ""
		if (_updateType === VenusOS.Firmware_UpdateType_Online && onlineAvailableVersion.length === 0) {
			//% "No newer version available"
			msg = qsTrId("settings_firmware_no_newer_version_available")
		} else if (_updateType === VenusOS.Firmware_UpdateType_Offline && offlineAvailableVersion.length === 0) {
			//% "No firmware found"
			msg = qsTrId("settings_firmware_no_firmware_found")
		}
		if (msg) {
			Global.showToastNotification(VenusOS.Notification_Info, msg, 10000)
		}
	}
}

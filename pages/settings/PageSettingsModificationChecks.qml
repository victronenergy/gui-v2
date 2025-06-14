/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import QtQuick.Templates as T

Page {
	id: root

	readonly property int fsModifiedState: fsModifiedStateItem.valid ? fsModifiedStateItem.value : -1
	readonly property int systemHooksState: systemHooksStateItem.valid ? systemHooksStateItem.value : -1
	readonly property bool isLatestReleaseFirmwareInstalled: firmwareInstalledVersionItem.valid && firmwareReleaseAvailableVersionItem.valid && firmwareInstalledVersionItem.value === firmwareReleaseAvailableVersionItem.value
	readonly property bool isLargeFirmwareInstalled: signalKItem.valid || nodeRedItem.valid

	property bool restoreFirmwareIntegrityPressed: false

	function getVictronSupportState() {
		if (modelItem.value.indexOf("Raspberry") === -1) {
			if (fsModifiedState !== VenusOS.ModificationChecks_FsModifiedState_Modified && !(systemHooksState & VenusOS.ModificationChecks_SystemHooksState_HookLoadedAtBoot)) {
				//% "Yes"
				return qsTrId("pagesettingsmodificationchecks_yes")
			} else if ((systemHooksState & VenusOS.ModificationChecks_SystemHooksState_HookLoadedAtBoot) && fsModifiedState !== VenusOS.ModificationChecks_FsModifiedState_Modified) {
				//% "Disable all modifications before contacting support"
				return qsTrId("pagesettingsmodificationchecks_disable_modifications")
			} else if (fsModifiedState === VenusOS.ModificationChecks_FsModifiedState_Modified && !(systemHooksState & VenusOS.ModificationChecks_SystemHooksState_HookLoadedAtBoot)) {
				//% "Restore firmware integrity before contacting support"
				return qsTrId("pagesettingsmodificationchecks_disable_system_hooks")
			} else {
				//% "Disable all modifications and restore\nfirmware integrity before contacting support"
				return qsTrId("pagesettingsmodificationchecks_disable_modifications_system_hooks")
			}
		} else {
			//% "Unsupported GX device"
			return qsTrId("pagesettingsmodificationchecks_unsupported_gx_device")
		}
	}

	function scaleBytes(bytes) {
		if (bytes < 1024) {
			return bytes + " B"
		} else if (bytes < 1024 * 1024) {
			return (bytes / 1024).toFixed(1) + " KB"
		} else if (bytes < 1024 * 1024 * 1024) {
			return (bytes / 1024 / 1024).toFixed(1) + " MB"
		} else {
			return (bytes / 1024 / 1024 / 1024).toFixed(1) + " GB"
		}
	}

	function getFsModifiedState() {
		if (fsModifiedState === VenusOS.ModificationChecks_FsModifiedState_Clean) {
			return CommonWords.ok
		} else if (fsModifiedState === VenusOS.ModificationChecks_FsModifiedState_Modified) {
			//% "Modified"
			return qsTrId("pagesettingsmodificationchecks_modified")
		} else {
			//% "Not available on this device"
			return qsTrId("pagesettingsmodificationchecks_not_available_on_this_device")
		}
	}

	function getSystemHooksState() {
		if (systemHooksState < 4) {
			//% "No"
			return qsTrId("common_words_no")
		} else if ((systemHooksState & VenusOS.ModificationChecks_SystemHooksState_HookLoadedAtBoot)
			&& (systemHooksState & VenusOS.ModificationChecks_SystemHooksState_RcLocal)
			&& (systemHooksState & VenusOS.ModificationChecks_SystemHooksState_RcSLocal)) {
			//% "Yes (rc.local and rcS.local)"
			return qsTrId("pagesettingsmodificationchecks_yes_rc_local_rcS_local")
		} else if ((systemHooksState & VenusOS.ModificationChecks_SystemHooksState_HookLoadedAtBoot)
			&& (systemHooksState & VenusOS.ModificationChecks_SystemHooksState_RcSLocal)) {
			//% "Yes (rcS.local)"
			return qsTrId("pagesettingsmodificationchecks_yes_rcS_local")
		} else if ((systemHooksState & VenusOS.ModificationChecks_SystemHooksState_HookLoadedAtBoot)
			&& (systemHooksState & VenusOS.ModificationChecks_SystemHooksState_RcLocal)) {
			//% "Yes (rc.local)"
			return qsTrId("pagesettingsmodificationchecks_yes_rc_local")
		} else if ((systemHooksState & VenusOS.ModificationChecks_SystemHooksState_HookLoadedAtBoot)
			&& !(systemHooksState & VenusOS.ModificationChecks_SystemHooksState_RcLocal)
			&& !(systemHooksState & VenusOS.ModificationChecks_SystemHooksState_RcSLocal)) {
			//% "Yes, but disable at next boot"
			return qsTrId("pagesettingsmodificationchecks_yes_but_disable_next_boot")
		} else if (!(systemHooksState & VenusOS.ModificationChecks_SystemHooksState_HookLoadedAtBoot)
			&& (systemHooksState & VenusOS.ModificationChecks_SystemHooksState_RcLocal)
			&& (systemHooksState & VenusOS.ModificationChecks_SystemHooksState_RcSLocal)) {
			//% "No, but enable at next boot (rc.local and rcS.local)"
			return qsTrId("pagesettingsmodificationchecks_no_but_next_boot_rc_local_rcS_local")
		} else if (!(systemHooksState & VenusOS.ModificationChecks_SystemHooksState_HookLoadedAtBoot)
			&& (systemHooksState & VenusOS.ModificationChecks_SystemHooksState_RcSLocal)) {
			//% "No, but enable at next boot (rcS.local)"
			return qsTrId("pagesettingsmodificationchecks_no_but_next_boot_rcS_local")
		} else if (!(systemHooksState & VenusOS.ModificationChecks_SystemHooksState_HookLoadedAtBoot)
			&& (systemHooksState & VenusOS.ModificationChecks_SystemHooksState_RcLocal)) {
			//% "No, but enable at next boot (rc.local)"
			return qsTrId("pagesettingsmodificationchecks_no_but_next_boot_rc_local")
		} else {
			//% "Unknown: %1"
			return qsTrId("pagesettingsmodificationchecks_unknown").arg(systemHooksState)
		}
	}

	function getLatestReleaseFirmwareInstalled() {
		if (firmwareStateItem.valid && firmwareStateItem.value === FirmwareUpdater.Checking) {
			//% "Checking..."
			return qsTrId("pagesettingsmodificationchecks_firmware_checking")
		} else if (firmwareStateItem.valid && firmwareStateItem.value === FirmwareUpdater.ErrorDuringChecking && !firmwareReleaseAvailableVersionItem.valid) {
			//% "Error while checking for firmware updates"
			return qsTrId("pagesettingsmodificationchecks_firmware_online_check_failed")
		} else if (isLatestReleaseFirmwareInstalled) {
			//% "Yes"
			return qsTrId("common_words_yes")
		} else if (firmwareReleaseAvailableVersionItem.valid) {
			//: %1 = firmware version
			//% "No, %1 is available"
			return qsTrId("pagesettingsmodificationchecks_firmware_no_available").arg(firmwareReleaseAvailableVersionItem.value)
		} else {
			//% "Unknown"
			return qsTrId("pagesettingsmodificationchecks_firmware_unknown")
		}
	}

	VeQuickItem {
		id: allModificationsEnabledItem
		uid: Global.systemSettings.serviceUid + "/Settings/System/ModificationChecks/AllModificationsEnabled"
	}
	VeQuickItem {
		id: modelItem
		uid: Global.venusPlatform.serviceUid + "/Device/Model"
	}
	VeQuickItem {
		id: signalKItem
		uid: Global.venusPlatform.serviceUid + "/Services/SignalK/Enabled"
	}
	VeQuickItem {
		id: nodeRedItem
		uid: Global.venusPlatform.serviceUid + "/Services/NodeRed/Mode"
	}
	VeQuickItem {
		id: firmwareInstalledVersionItem
		uid: Global.venusPlatform.serviceUid + "/Firmware/Installed/Version"
	}
	VeQuickItem {
		id: largeImageSupportItem
		uid: Global.venusPlatform.serviceUid + "/Firmware/LargeImageSupport"
	}
	VeQuickItem {
		id: firmwareProgressItem
		uid: Global.venusPlatform.serviceUid + "/Firmware/Progress"
	}
	VeQuickItem {
		id: firmwareReleaseAvailableVersionItem
		uid: Global.venusPlatform.serviceUid + "/Firmware/Release/AvailableVersion"
	}
	VeQuickItem {
		id: firmwareReleaseCheckItem
		uid: Global.venusPlatform.serviceUid + "/Firmware/Release/Check"
	}
	VeQuickItem {
		id: firmwareReleaseInstallItem
		uid: Global.venusPlatform.serviceUid + "/Firmware/Release/Install"
	}
	VeQuickItem {
		id: firmwareStateItem
		uid: Global.venusPlatform.serviceUid + "/Firmware/State"
	}
	VeQuickItem {
		id: dataPartitionFreeSpaceItem
		uid: Global.venusPlatform.serviceUid + "/ModificationChecks/DataPartitionFreeSpace"
	}
	VeQuickItem {
		id: sshKeyForRootPresentItem
		uid: Global.venusPlatform.serviceUid + "/ModificationChecks/SshKeyForRootPresent"
	}
	VeQuickItem {
		id: startModificationCheckItem
		uid: Global.venusPlatform.serviceUid + "/ModificationChecks/StartCheck"
	}
	VeQuickItem {
		id: fsModifiedStateItem
		uid: Global.venusPlatform.serviceUid + "/ModificationChecks/FsModifiedState"
	}
	VeQuickItem {
		id: systemHooksStateItem
		uid: Global.venusPlatform.serviceUid + "/ModificationChecks/SystemHooksState"
	}

	GradientListView {
		model: VisibleItemModel {

			PrimaryListLabel {
				//% "This page shows the current system state, allows you to enable or disable modifications, and restore the firmware to its original state."
				text: qsTrId("pagesettingsmodificationchecks_description")
			}

			ListText {
				//% "Victron Energy support"
				text: qsTrId("pagesettingsmodificationchecks_system_state")
				secondaryText: getVictronSupportState()
				secondaryLabel.color: modelItem.value.indexOf("Raspberry") === -1 && fsModifiedState !== VenusOS.ModificationChecks_FsModifiedState_Modified
					&& !(systemHooksState & VenusOS.ModificationChecks_SystemHooksState_HookLoadedAtBoot)
					? Theme.color_green : Theme.color_red
			}

			ListText {
				//% "Device model"
				text: qsTrId("pagesettingsmodificationchecks_device_model")
				secondaryText: modelItem.value || ""
				secondaryLabel.color: modelItem.valid && modelItem.value.indexOf("Raspberry") === -1 ? Theme.color_green : Theme.color_red
			}

			ListText {
				// Value is missing on older devices, therefore do not use colors on that
				//% "HQ serial number"
				text: qsTrId("pagesettingsmodificationchecks_hq_serial_number")
				dataItem.uid: Global.venusPlatform.serviceUid + "/Device/HQSerialNumber"
				preferredVisible: dataItem.valid && dataItem.value != ""
			}

			ListText {
				//% "Data partition free space"
				text: qsTrId("pagesettingsmodificationchecks_data_free_space")
				secondaryText: scaleBytes(dataPartitionFreeSpaceItem.value)
				secondaryLabel.color: dataPartitionFreeSpaceItem.value < 1024 * 1024 * 10 ? Theme.color_red : Theme.color_green
			}

			ListText {
				//% "User SSH key present"
				text: qsTrId("pagesettingsmodificationchecks_user_ssh_key_present")
				secondaryText: sshKeyForRootPresentItem.value === 1 ? qsTrId("common_words_yes") : qsTrId("common_words_no")
			}

			SettingsListHeader {
				//% "Modifications"
				text: qsTrId("pagesettingsmodificationchecks_modifications")
			}

			ListText {
				//% "Third-party modifications loaded at boot"
				text: qsTrId("pagesettingsmodificationchecks_third_party_modifications_at_boot")
				secondaryText: getSystemHooksState()
				secondaryLabel.color: systemHooksState < 4 ? Theme.color_green : systemHooksState < 16 ? Theme.color_orange : Theme.color_red
			}

			ListSwitch {
				id: enableAllModifications
				//% "Load third-party modifications at boot (if present)"
				text: qsTrId("pagesettingsmodificationchecks_enable_third_party_modifications")
				/*
				Venus Platform
				- Save the current state of Signal K and Node-RED
				- Disable (service) and lock (GUI buttons) Signal K
				- Disable (service) and lock (GUI buttons) Node-RED
				- Disable rc.local by renaming it to rc.local.disabled
				- Disable rcS.local by renaming it to rcS.local.disabled
				*/
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/System/ModificationChecks/AllModificationsEnabled"
				//% "Enables all modifications, allowing Signal K and Node-RED to be enabled separately."
				// caption: qsTrId("pagesettingsmodificationchecks_enable_all_modifications_description_large")

				onCheckedChanged: {
					/*
					Show reboot dialog if restore integrity button was not pressed and
						- switch is now checked, no system hook was loaded at the last boot and rc.local or rcS.local are present
						or
						- switch is now unchecked and at least one system hook was loaded at the last boot
					*/
					if (!restoreFirmwareIntegrityPressed
						&& ((enableAllModifications.checked && !(systemHooksState & VenusOS.ModificationChecks_SystemHooksState_HookLoadedAtBoot)
							&& ((systemHooksState & VenusOS.ModificationChecks_SystemHooksState_RcLocalDisabled) || (systemHooksState & VenusOS.ModificationChecks_SystemHooksState_RcSLocalDisabled))
						) || (!enableAllModifications.checked && (systemHooksState & VenusOS.ModificationChecks_SystemHooksState_HookLoadedAtBoot)))) {
						Global.dialogLayer.open(askForRebootDialogComponent)
					} else {
						startModificationCheckItem.setValue(1)
					}
				}

				Component {
					id: askForRebootDialogComponent

					ModalWarningDialog {
						//% "Reboot needed"
						title: qsTrId("pagesettingsmodificationchecks_reboot_needed")
						//% "To apply changes a reboot is needed.<br>Press 'OK' to reboot now."
						description: qsTrId("pagesettingsmodificationchecks_reboot_needed_description")
						dialogDoneOptions: VenusOS.ModalDialog_DoneOptions_OkAndCancel
						onClosed: {
							if (result === T.Dialog.Accepted) {
								Global.venusPlatform.reboot()
								Qt.callLater(Global.dialogLayer.open, rebootingDialogComponent)
							} else {
								startModificationCheckItem.setValue(1)
							}
						}
					}
				}
			}

			ListRebootButton {
				//% "Reboot now to apply changes"
				text: qsTrId("pagesettingsmodificationchecks_reboot_now_to_apply_changes")
				// Show button if
				// - Switch is enabled and custom-rc is not present, but rc.local or rcS.local are present
				// - Switch is disabled and custom-rc is present
				preferredVisible: (enableAllModifications.checked && !(systemHooksState & VenusOS.ModificationChecks_SystemHooksState_HookLoadedAtBoot)
					&& ((systemHooksState & VenusOS.ModificationChecks_SystemHooksState_RcLocal) || (systemHooksState & VenusOS.ModificationChecks_SystemHooksState_RcSLocal)))
						|| (!enableAllModifications.checked && (systemHooksState & VenusOS.ModificationChecks_SystemHooksState_HookLoadedAtBoot))
			}

			SettingsListHeader {
				//% "Firmware"
				text: qsTrId("pagesettingsmodificationchecks_firmware")
			}

			ListText {
				//% "Installed firmware version"
				text: qsTrId("pagesettingsmodificationchecks_installed_firmware_version")
				secondaryText: FirmwareVersion.versionText(firmwareInstalledVersionItem.value, "venus")
			}

			ListText {
				//% "Installed image type"
				text: qsTrId("pagesettingsmodificationchecks_installed_image_type")
				secondaryText: isLargeFirmwareInstalled ? qsTrId("settings_firmware_large") : qsTrId("settings_firmware_normal")
				preferredVisible: largeImageSupportItem.valid && largeImageSupportItem.value === 1
			}

			ListText {
				//% "Firmware integrity"
				text: qsTrId("pagesettingsmodificationchecks_firmware_integrity")
				secondaryText: getFsModifiedState()
				secondaryLabel.color: fsModifiedState === VenusOS.ModificationChecks_FsModifiedState_Clean ? Theme.color_green
					: fsModifiedState === VenusOS.ModificationChecks_FsModifiedState_Modified ? Theme.color_red : Theme.color_orange
				// Theme.color_font_secondary
				//% "State of root-fs"
				caption: qsTrId("pagesettingsmodificationchecks_firmware_integrity_description")
				// preferredVisible: fsModifiedStateItem.valid && fsModifiedStateItem.value !== VenusOS.ModificationChecks_FsModifiedState_Unknown
			}

			ListText {
				//% "Latest stable firmware version installed?"
				text: qsTrId("pagesettingsmodificationchecks_latest_stable_firmware_installed")
				secondaryText: getLatestReleaseFirmwareInstalled()
				secondaryLabel.color: isLatestReleaseFirmwareInstalled ? Theme.color_green : Theme.color_red
			}

			ListButton {
				//% "Reinstall latest stable firmware"
				text: qsTrId("pagesettingsmodificationchecks_firmware_reinstall")
				button.text: {
					if  (Global.firmwareUpdate.state === FirmwareUpdater.DownloadingAndInstalling) {
						if (firmwareProgressItem.value) {
							//: Firmware update firmwareProgressItem. %1 = firmware version, %2 = current update progress
							//% "Installing %1 %2%"
							qsTrId("settings_firmware_online_installing_progress").arg(Global.firmwareUpdate.onlineAvailableVersion).arg(firmwareProgressItem.value)
						}
						//: %1 = firmware version
						//% "Installing %1..."
						qsTrId("settings_firmware_online_installing").arg(Global.firmwareUpdate.onlineAvailableVersion)
					} else {
						//% "Press to install"
						qsTrId("pagesettingsmodificationchecks_press_to_install") + (firmwareReleaseAvailableVersionItem.valid ? " " + firmwareReleaseAvailableVersionItem.value : "")
					}
				}
				writeAccessLevel: VenusOS.User_AccessType_User
				//% "Restore the firmware to its original state while preserving system settings."
				caption: qsTrId("pagesettingsmodificationchecks_firmware_reinstall_caption")
				onClicked: Global.dialogLayer.open(confirmReinstallDialogComponent)

				Component {
					id: confirmReinstallDialogComponent

					ModalWarningDialog {
						//% "Reinstall latest stable firmware"
						title: qsTrId("pagesettingsmodificationchecks_firmware_restore_clean_state_title")
						//% "This will disable all third-party modifications, download and reinstall the latest stable firmware.<br>Internet connectivity is required.<br>Press 'OK' to continue."
						description: qsTrId("pagesettingsmodificationchecks_firmware_restore_clean_state_description")
						dialogDoneOptions: VenusOS.ModalDialog_DoneOptions_OkAndCancel
						onClosed: {
							if (result === T.Dialog.Accepted) {
								restoreFirmwareIntegrityPressed = true
								allModificationsEnabledItem.setValue(0)
								firmwareReleaseInstallItem.setValue(1)
							}
						}
					}
				}
			}

			SettingsListHeader {
				//% "Integrations"
				text: qsTrId("pagesettingsmodificationchecks_integrations")
			}

			ListText {
				//% "MQTT Access"
				text: qsTrId("pagesettingsmodificationchecks_mqtt_access")
				secondaryText: mqttAccessItem.valid && mqttAccessItem.value ? CommonWords.enabled : CommonWords.disabled

				VeQuickItem {
					id: mqttAccessItem
					uid: Global.systemSettings.serviceUid + "/Settings/Services/MqttLocal"
				}
			}

			ListText {
				//% "Modbus/TCP"
				text: qsTrId("pagesettingsmodificationchecks_modbus_tcp")
				secondaryText: modbusTcpItem.valid && modbusTcpItem.value ? CommonWords.enabled : CommonWords.disabled

				VeQuickItem {
					id: modbusTcpItem
					uid: Global.systemSettings.serviceUid + "/Settings/Services/Modbus"
				}
			}

			ListText {
				//% "Signal K"
				text: qsTrId("pagesettingsmodificationchecks_signal_k")
				secondaryText: signalKItem.valid && signalKItem.value ? CommonWords.enabled : CommonWords.disabled
				preferredVisible: signalKItem.valid
			}

			ListText {
				//% "Node-RED"
				text: qsTrId("pagesettingsmodificationchecks_node_red")
				secondaryText: nodeRedItem.valid && nodeRedItem.value === VenusOS.NodeRed_Mode_Disabled
					? CommonWords.disabled : nodeRedItem.value === VenusOS.NodeRed_Mode_Enabled
						//% "Enabled (safe mode)"
						? CommonWords.enabled : qsTrId("settings_large_enabled_safe_mode")
				preferredVisible: nodeRedItem.valid
			}
		}
	}

	Component.onCompleted: {
		// Check for updates
		if (firmwareReleaseCheckItem.valid && firmwareReleaseCheckItem.value === 0) {
			firmwareReleaseCheckItem.setValue(2)
		}

		// Run system integrity check
		startModificationCheckItem.setValue(1)
	}
}

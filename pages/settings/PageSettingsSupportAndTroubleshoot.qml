/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import QZXing
import QtQuick.Templates as T

Page {
	id: root

    // readonly property string firmwareInstalledBuild: firmwareInstalledBuildItem.isValid ? firmwareInstalledBuildItem.value : ""
	// readonly property string firmwareInstalledVersion: firmwareInstalledVersionItem.isValid ? firmwareInstalledVersionItem.value : ""
    readonly property string firmwareOnlineAvailableBuild: firmwareOnlineAvailableBuildItem.isValid ? firmwareOnlineAvailableBuildItem.value : ""
    readonly property string firmwareOnlineAvailableVersion: firmwareOnlineAvailableVersionItem.isValid ? firmwareOnlineAvailableVersionItem.value : ""
    readonly property bool firmwareOnlineCheck: firmwareOnlineCheckItem.isValid ? firmwareOnlineCheckItem.value : false
    readonly property int firmwareState: firmwareStateItem.isValid ? firmwareStateItem.value : FirmwareUpdater.Idle
    readonly property int fsModifiedState: fsModifiedStateItem.isValid ? fsModifiedStateItem.value : -1
    readonly property int systemHooksState: systemHooksStateItem.isValid ? systemHooksStateItem.value : -1

	property bool restoreFirmwareIntegrityPressed: false

    function getSystemState() {
        if (fsModifiedState === 0 && systemHooksState === 0 && modelItem.value.indexOf("Raspberry") === -1) {
            //% "Supported"
            return "Supported"
        } else {
            //% "No Victron Energy support"
            return "No Victron Energy support"
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
		if (fsModifiedState === 0) {
			//% "Ok"
            return "Ok"
		} else if (fsModifiedState === 1) {
            //% "Modified"
            return "Modified"
		} else {
            //% "Unknown: %1"
            return "Unknown: %1".arg(fsModifiedState)
        }
	}

	function getSystemHooksState() {
		if (systemHooksState === 0) {
			//% "No"
            return "No"
		} else if (systemHooksState === 1) {
            //% "No, but enable at next boot (rc.local)"
            return "No, but enable at next boot (rc.local)"
        } else if (systemHooksState === 2) {
            //% "No, but enable at next boot (rcS.local)"
            return "No, but enable at next boot (rcS.local)"
        } else if (systemHooksState === 3) {
            //% "No, but enable at next boot (rc.local and rcS.local)"
            return "No, but enable at next boot (rc.local and rcS.local)"
		} else if (systemHooksState === 4) {
            //% "Yes, but disable at next boot"
            return "Yes, but disable at next boot"
		} else if (systemHooksState === 5) {
            //% "Yes (rc.local)"
            return "Yes (rc.local)"
		} else if (systemHooksState === 6) {
            //% "Yes (rcS.local)"
            return "Yes (rcS.local)"
		} else if (systemHooksState === 7) {
            //% "Yes (rc.local and rcS.local)"
            return "Yes (rc.local and rcS.local)"
		} else {
            //% "Unknown: %1"
            return "Unknown: %1".arg(systemHooksState)
        }
	}

    function getFirmwareState(returnString = true) {

        let result = ""
        let isOk = false

        if (firmwareOnlineAvailableBuild == "" && firmwareOnlineAvailableVersion == "") {
            //% ""
            result = "Yes"
            isOk = true
        } else if (Global.firmwareUpdate.checkingForUpdate) {
            //% ""
            result = "Checking..."
        } else if (firmwareState == FirmwareUpdater.ErrorDuringChecking) {
            //% ""
            result = "Online check failed"
        } else {
            //: %1 = firmware version
            //% "No, %1 is available"
            result = qsTr("No, %1 is available").arg(Global.firmwareUpdate.onlineAvailableVersion)
        }

        return returnString ? result : isOk
    }

    VeQuickItem {
        id: allModificationsDisabledItem
        uid: Global.systemSettings.serviceUid + "/Settings/System/SystemIntegrity/AllModificationsDisabled"
    }

	VeQuickItem {
		id: hqSerialNumberItem
		uid: Global.venusPlatform.serviceUid + "/Device/HQSerialNumber"
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

    /*
	VeQuickItem {
		id: firmwareInstalledBuildItem
		uid: Global.venusPlatform.serviceUid + "/Firmware/Installed/Build"
	}
	VeQuickItem {
		id: firmwareInstalledVersionItem
		uid: Global.venusPlatform.serviceUid + "/Firmware/Installed/Version"
	}
    */
    VeQuickItem {
        id: firmwareOnlineAvailableBuildItem
        uid: Global.venusPlatform.serviceUid + "/Firmware/Online/AvailableVersion"
    }
    VeQuickItem {
        id: firmwareOnlineAvailableVersionItem
        uid: Global.venusPlatform.serviceUid + "/Firmware/Online/AvailableBuild"
    }
    VeQuickItem {
        id: firmwareOnlineCheckItem
        uid: Global.venusPlatform.serviceUid + "/Firmware/Online/Check"
    }
    VeQuickItem {
        id: firmwareProgressItem
        uid: Global.venusPlatform.serviceUid + "/Firmware/Progress"
    }
    VeQuickItem {
        id: firmwareStateItem
        uid: Global.venusPlatform.serviceUid + "/Firmware/State"
    }
    VeQuickItem {
        id: dataPartitionFreeSpaceItem
        uid: Global.venusPlatform.serviceUid + "/SystemIntegrity/DataPartitionFreeSpace"
    }
    VeQuickItem {
        id: forceFirmwareReinstallItem
        uid: Global.venusPlatform.serviceUid + "/SystemIntegrity/ForceFirmwareReinstall"
    }
    VeQuickItem {
        id: systemIntegritySshKeyForRootPresentItem
        uid: Global.venusPlatform.serviceUid + "/SystemIntegrity/SshKeyForRootPresent"
    }
    VeQuickItem {
        id: systemIntegrityStartCheckItem
        uid: Global.venusPlatform.serviceUid + "/SystemIntegrity/StartCheck"
    }
    VeQuickItem {
        id: fsModifiedStateItem
        uid: Global.venusPlatform.serviceUid + "/SystemIntegrity/FsModifiedState"
    }
    VeQuickItem {
        id: systemHooksStateItem
        uid: Global.venusPlatform.serviceUid + "/SystemIntegrity/SystemHooksState"
    }


	GradientListView {
		id: supportAndTroubleshootListView

		model: ObjectModel {

			ListNavigation {
				//% ""
				text: "Customization checks"
                secondaryText: getSystemState()
                secondaryLabel.color: fsModifiedState === 0 && systemHooksState === 0 ? Theme.color_font_primary : Theme.color_red
				onClicked: {
					Global.pageManager.pushPage(systemIntegrityList, {"title": text})
				}

				Component {
					id: systemIntegrityList

					Page {
						GradientListView {
							model: ObjectModel {

                                PrimaryListLabel {
                                    //% ""
                                    text: "Customization checks"
                                }

                                ListText {
                                    //% ""
                                    text: "System state"
                                    secondaryText: getSystemState()
                                    secondaryLabel.color: fsModifiedState === 0 && systemHooksState === 0 ? Theme.color_green : Theme.color_red
                                }

                                ListText {
                                    //% "Device model"
                                    text: "Device model"
                                    secondaryText: modelItem.value
                                    secondaryLabel.color: modelItem.value.indexOf("Raspberry") === -1 ? Theme.color_green : Theme.color_red
                                }

                                ListText {
                                    //% "HQ serial number"
                                    text: "HQ serial number"
                                    //% ""
                                    // secondaryText: hqSerialNumberItem.value != "" ? hqSerialNumberItem.value : "Unknown"
                                    secondaryText: hqSerialNumberItem.value
                                    // Value is missing on older devices, therefore do not use colors on that
                                    // secondaryLabel.color: hqSerialNumberItem.value != "" ? Theme.color_green : Theme.color_red
                                    allowed: defaultAllowed && hqSerialNumberItem.value != ""
                                }

                                ListText {
                                    //% ""
                                    text: "Data partition free space"
                                    secondaryText: scaleBytes(dataPartitionFreeSpaceItem.value)
                                    // see https://github.com/victronenergy/meta-victronenergy-private/blob/d7ac2aa359412115a0173afd7953e83ab574edf7/recipes-ve/support-keys/support.sh#L22-L24
                                    secondaryLabel.color: {
                                        if (dataPartitionFreeSpaceItem.value < 1024 * 1024 * 10) {
                                            return Theme.color_red;
                                        } else {
                                            return Theme.color_green;
                                        }
                                    }
                                }

                                ListText {
                                    //% ""
                                    text: "Modifications loaded at boot"
                                    secondaryText: getSystemHooksState()
                                    secondaryLabel.color: systemHooksState === 0 ? Theme.color_green : systemHooksState < 4 ? Theme.color_orange : Theme.color_red
                                }

                                ListText {
                                    //% ""
                                    text: "Firmware integrity"
                                    secondaryText: getFsModifiedState()
                                    secondaryLabel.color: fsModifiedState === 0 ? Theme.color_green : Theme.color_red
                                }

                                ListText {
                                    //% ""
                                    text: "Latest firmware version installed?"
                                    secondaryText: getFirmwareState()
                                    secondaryLabel.color: getFirmwareState(false) ? Theme.color_green : Theme.color_red
                                    }

                                ListText {
                                    // text: CommonWords.firmware_version
                                    text: "Installed firmware version"
                                    secondaryText: FirmwareVersion.versionText(dataItem.value, "venus")
                                    dataItem.uid: Global.venusPlatform.serviceUid + "/Firmware/Installed/Version"
                                }

                                ListText {
                                    // text: qsTrId("settings_build_date_time")
                                    text: "Installed build date/time"
                                    dataItem.uid: Global.venusPlatform.serviceUid + "/Firmware/Installed/Build"
                                }

                                ListText {
                                    //% ""
                                    text: "Installed image type"
                                    secondaryText: signalKItem.isValid || nodeRedItem.isValid ? qsTrId("settings_firmware_large") : qsTrId("settings_firmware_normal")
                                }

                                ListText {
                                    //% ""
                                    text: "User SSH key present"
                                    secondaryText: systemIntegritySshKeyForRootPresentItem.value === 1 ? "Yes" : "No"
                                }



                                PrimaryListLabel {
                                    text: "Tools to normalize the system"
                                }

                                ListSwitch {
                                    id: disableAllModifications
                                    //% ""
                                    text: "Disable all modifications"
                                    /*
                                    Venus Platform
                                    - Save the current state of Signal K and Node-RED
                                    - Disable (service) and lock (GUI buttons) Signal K
                                    - Disable (service) and lock (GUI buttons) Node-RED
                                    - Disable rc.local by renaming it to rc.local.disabled
                                    - Disable rcS.local by renaming it to rcS.local.disabled
                                    */
                                    dataItem.uid: Global.systemSettings.serviceUid + "/Settings/System/SystemIntegrity/AllModificationsDisabled"

                                    bottomContentChildren: [
                                        PrimaryListLabel {
                                            width: Math.min(implicitWidth, disableAllModifications.maximumContentWidth)
                                            topPadding: 0
                                            bottomPadding: 0
                                            color: Theme.color_font_secondary
                                            text: "This disables all modifications, including SignalK and Node-RED."
                                        }
                                    ]

                                    onCheckedChanged: {
                                        // Show the dialog only if
                                        // - restore integrity button was not pressed
                                        // - it doesn't match the current state
                                        if (
                                            !restoreFirmwareIntegrityPressed
                                            &&
                                            (
                                                (!disableAllModifications.checked && systemHooksState < 4)
                                                ||
                                                (disableAllModifications.checked && systemHooksState >= 4)
                                            )
                                        ) {
                                            Global.dialogLayer.open(askForRebootDialogComponent)
                                        } else {
                                            systemIntegrityStartCheckItem.setValue(1)
                                        }
                                    }

                                    Component {
                                        id: askForRebootDialogComponent

                                        ModalWarningDialog {
                                            //% ""
                                            title: "To apply changes a reboot is needed.<br>Press 'OK' to reboot now."
                                            dialogDoneOptions: VenusOS.ModalDialog_DoneOptions_OkAndCancel
                                            onClosed: {
                                                if (result === T.Dialog.Accepted) {
                                                    Global.venusPlatform.reboot()
                                                    Qt.callLater(Global.dialogLayer.open, rebootingDialogComponent)
                                                } else {
                                                    systemIntegrityStartCheckItem.setValue(1)
                                                }
                                            }
                                        }
                                    }
                                }

                                ListButton {
                                    //% ""
                                    text: "Reboot now to apply changes"
                                    //% "Reboot now"
                                    button.text: qsTrId("settings_reboot_now")
                                    writeAccessLevel: VenusOS.User_AccessType_User
                                    allowed: defaultAllowed && systemHooksState >= 1 && systemHooksState <= 4
                                    onClicked: Global.dialogLayer.open(confirmRebootDialogComponent)

                                    Component {
                                        id: confirmRebootDialogComponent

                                        ModalWarningDialog {
                                            //% "Press 'OK' to reboot"
                                            title: qsTrId("press_ok_to_reboot")
                                            dialogDoneOptions: VenusOS.ModalDialog_DoneOptions_OkAndCancel
                                            onClosed: {
                                                if (result === T.Dialog.Accepted) {
                                                    Global.venusPlatform.reboot()
                                                    Qt.callLater(Global.dialogLayer.open, rebootingDialogComponent)
                                                }
                                            }
                                        }
                                    }

                                    Component {
                                        id: rebootingDialogComponent

                                        ModalWarningDialog {
                                            title: BackendConnection.type === BackendConnection.DBusSource
                                                //% "Rebooting..."
                                                ? qsTrId("dialoglayer_rebooting")
                                                //% "Device has been rebooted."
                                                : qsTrId("dialoglayer_rebooted")

                                            // On device, dialog cannot be dismissed; just wait until device is rebooted.
                                            dialogDoneOptions: VenusOS.ModalDialog_DoneOptions_OkOnly
                                            footer.enabled: BackendConnection.type !== BackendConnection.DBusSource
                                            footer.opacity: footer.enabled ? 1 : 0
                                        }
                                    }
                                }

                                ListButton {
                                    //% ""
                                    text: "Firmware: Restore clean state"
                                    //% ""
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
                                            //% ""
                                            "Press to restore"
                                        }
                                    }
                                    writeAccessLevel: VenusOS.User_AccessType_User
                                    onClicked: Global.dialogLayer.open(confirmReinstallDialogComponent)

                                    Component {
                                        id: confirmReinstallDialogComponent

                                        ModalWarningDialog {
                                            //% ""
                                            title: "This will disable all modifications, download and reinstall the latest available firmware.<br>Internet connectivity is required.<br>Press 'OK' to continue."
                                            dialogDoneOptions: VenusOS.ModalDialog_DoneOptions_OkAndCancel
                                            onClosed: {
                                                if (result === T.Dialog.Accepted) {
                                                    restoreFirmwareIntegrityPressed = true
                                                    allModificationsDisabledItem.setValue(1)
                                                    forceFirmwareReinstallItem.setValue(1)
                                                }
                                            }
                                        }
                                    }

                                }

                                ListNavigation {
                                    //% ""
                                    text: qsTrId("Firmware: Online update")
                                    onClicked: {
                                        Global.pageManager.pushPage("/pages/settings/PageSettingsFirmwareOnline.qml", { title: text })
                                    }
                                }

                                ListNavigation {
                                    //% ""
                                    text: qsTrId("Firmware: Install from SD/USB")
                                    onClicked: {
                                        Global.pageManager.pushPage("/pages/settings/PageSettingsFirmwareOffline.qml", { title: text })
                                    }
                                }
                            }
                        }

                        Component.onCompleted: {
                            // Check for updates
                            if (firmwareOnlineCheck === false) {
                                Global.firmwareUpdate.checkForUpdate(VenusOS.Firmware_UpdateType_Online)
                            }

                            // Run system integrity check
                            systemIntegrityStartCheckItem.setValue(1)

                        }
                    }
                }
            }

            ListNavigation {
                //% ""
                text: "Useful links"
                onClicked: {
                    Global.pageManager.pushPage(usefulLinksList, {"title": text})
                }

                Component {
                    id: usefulLinksList

                    Page {
                        GradientListView {
                            model: ObjectModel {

                                ListButton {
                                    //% ""
                                    text: "Check the FAQ"
                                    //% ""
                                    button.text: "Open in a new tab"
                                    allowed: defaultAllowed && Qt.platform.os === "wasm"
                                    onClicked: BackendConnection.openUrl("https://www.victronenergy.com/media/pg/Energy_Storage_System/en/faq.html")
                                }

                                ListItem {
                                    //% ""
                                    text: "Check the FAQ"
                                    // allowed: defaultAllowed && Qt.platform.os !== "wasm"
                                    content.children: [
                                        Image {
                                            source: "image://QZXing/encode/" + "https://www.victronenergy.com/media/pg/Energy_Storage_System/en/faq.html" +
                                                    "?correctionLevel=M" +
                                                    "&format=qrcode"
                                            sourceSize.width: 200
                                            sourceSize.height: 200

                                            width: 200
                                            height: 200
                                        }
                                    ]
                                }

                                ListButton {
                                    //% ""
                                    text: "Check how to troubleshoot"
                                    //% ""
                                    button.text: "Open in a new tab"
                                    allowed: defaultAllowed && Qt.platform.os === "wasm"
                                    onClicked: BackendConnection.openUrl("https://www.victronenergy.com/media/pg/Venus_GX/en/troubleshooting.html")
                                }

                                ListItem {
                                    //% ""
                                    text: "Check how to troubleshoot"
                                    // allowed: defaultAllowed && Qt.platform.os !== "wasm"
                                    content.children: [
                                        Image {
                                            source: "image://QZXing/encode/" + "https://www.victronenergy.com/media/pg/Venus_GX/en/troubleshooting.html" +
                                                    "?correctionLevel=S" +
                                                    "&format=qrcode"
                                            sourceSize.width: 200
                                            sourceSize.height: 200

                                            width: 200
                                            height: 200

                                            anchors.topMargin: 10
                                            anchors.bottomMargin: 10
                                        }
                                    ]
                                }

                                ListButton {
                                    //% ""
                                    text: "Check the forum"
                                    //% ""
                                    button.text: "Open in a new tab"
                                    allowed: defaultAllowed && Qt.platform.os === "wasm"
                                    onClicked: BackendConnection.openUrl("https://community.victronenergy.com/")
                                }

                                ListItem {
                                    //% ""
                                    text: "Check the forum"
                                    // allowed: defaultAllowed && Qt.platform.os !== "wasm"
                                    content.children: [
                                        Image {
                                            source: "image://QZXing/encode/" + "https://community.victronenergy.com/" +
                                                    "?correctionLevel=M" +
                                                    "&format=qrcode"
                                            sourceSize.width: 200
                                            sourceSize.height: 200

                                            width: 200
                                            height: 200
                                        }
                                    ]
                                }

                                ListButton {
                                    //% ""
                                    text: "Find a local distributor"
                                    //% ""
                                    button.text: "Open in a new tab"
                                    allowed: defaultAllowed && Qt.platform.os === "wasm"
                                    onClicked: BackendConnection.openUrl("https://www.victronenergy.com/where-to-buy")
                                }

                                ListItem {
                                    //% ""
                                    text: "Find a local distributor"
                                    // allowed: defaultAllowed && Qt.platform.os !== "wasm"
                                    content.children: [
                                        Image {
                                            source: "image://QZXing/encode/" + "https://www.victronenergy.com/where-to-buy" +
                                                    "?correctionLevel=M" +
                                                    "&format=qrcode"
                                            sourceSize.width: 200
                                            sourceSize.height: 200

                                            width: 200
                                            height: 200
                                        }
                                    ]
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        systemIntegrityStartCheckItem.setValue(1)
    }
}

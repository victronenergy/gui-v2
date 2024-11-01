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

    readonly property string firmwareInstalledBuild: firmwareInstalledBuildItem.isValid ? firmwareInstalledBuildItem.value : ""
	readonly property string firmwareInstalledVersion: firmwareInstalledVersionItem.isValid ? firmwareInstalledVersionItem.value : ""
    readonly property string firmwareOnlineAvailableBuild: firmwareOnlineAvailableBuildItem.isValid ? firmwareOnlineAvailableBuildItem.value : ""
    readonly property string firmwareOnlineAvailableVersion: firmwareOnlineAvailableVersionItem.isValid ? firmwareOnlineAvailableVersionItem.value : ""
    readonly property bool firmwareOnlineCheck: firmwareOnlineCheckItem.isValid ? firmwareOnlineCheckItem.value : false
    readonly property int firmwareState: firmwareStateItem.isValid ? firmwareStateItem.value : FirmwareUpdater.Idle
    // readonly property int systemCheck: startCheckItem.isValid ? startCheckItem.value : 0
    readonly property int fsModifiedState: fsModifiedStateItem.isValid ? fsModifiedStateItem.value : -1
    readonly property int systemHooksState: systemHooksStateItem.isValid ? systemHooksStateItem.value : -1

    function getSystemState() {
        if (fsModifiedState === 0 && systemHooksState === 0) {
            //% "Supported"
            return "Supported"
        } else {
            //% "No Victron Energy support"
            return "No Victron Energy support"
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
            //% "Unknown"
            return "Unknown"
        }
	}

	function getSystemHooksState() {
		if (systemHooksState === 0) {
			//% "No"
            return "No"
		} else if (systemHooksState === 1) {
            //% "No, but enabled at next boot (rc.local)"
            return "No, but enabled at next boot (rc.local)"
        } else if (systemHooksState === 2) {
            //% "No, but enabled at next boot (rcS.local)"
            return "No, but enabled at next boot (rcS.local)"
        } else if (systemHooksState === 3) {
            //% "No, but enabled at next boot (rc.local and rcS.local)"
            return "No, but enabled at next boot (rc.local and rcS.local)"
		} else if (systemHooksState === 4) {
            //% "Yes, but disabled at next boot"
            return "Yes, but disabled at next boot"
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
            //% "Unknown"
            return "Unknown"
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
        } else if  (Global.firmwareUpdate.state === FirmwareUpdater.DownloadingAndInstalling) {
            if (progress.value) {
                //: Firmware update progress. %1 = firmware version, %2 = current update progress
                //% "Installing %1 %2%"
                result = qsTrId("settings_firmware_online_installing_progress").arg(Global.firmwareUpdate.onlineAvailableVersion).arg(progress.value)
            }
            //: %1 = firmware version
            //% "Installing %1..."
            result = qsTrId("settings_firmware_online_installing").arg(Global.firmwareUpdate.onlineAvailableVersion)
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
		id: firmwareInstalledBuildItem
		uid: Global.venusPlatform.serviceUid + "/Firmware/Installed/Build"
	}
	VeQuickItem {
		id: firmwareInstalledVersionItem
		uid: Global.venusPlatform.serviceUid + "/Firmware/Installed/Version"
	}
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
        id: firmwareStateItem
        uid: Global.venusPlatform.serviceUid + "/Firmware/State"
    }
    VeQuickItem {
        id: forceFirmwareReinstallItem
        uid: Global.venusPlatform.serviceUid + "/SystemIntegrity/ForceFirmwareReinstall"
    }
    VeQuickItem {
        id: startCheckItem
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

			ListNavigationItem {
				//% ""
				text: "System integrity"
                secondaryText: getSystemState()
                secondaryLabel.color: fsModifiedState === 0 && systemHooksState === 0 ? Theme.color_font_primary : Theme.color_red
				onClicked: {
					Global.pageManager.pushPage(systemIntegrityListItem, {"title": text})
				}

				Component {
					id: systemIntegrityListItem

					Page {
						GradientListView {
							model: ObjectModel {

                                ListLabel {
                                    //% ""
                                    text: "System integrity checks"
                                }

                                ListTextItem {
                                    //% ""
                                    text: "System state"
                                    secondaryText: getSystemState()
                                    secondaryLabel.color: fsModifiedState === 0 && systemHooksState === 0 ? Theme.color_green : Theme.color_red
                                }

                                ListTextItem {
                                    //% ""
                                    text: "System hooks enabled"
                                    secondaryText: getSystemHooksState()
                                    secondaryLabel.color: systemHooksState === 0 ? Theme.color_green : systemHooksState < 4 ? Theme.color_orange : Theme.color_red
                                }

                                ListTextItem {
                                    //% ""
                                    text: "Firmware integrity"
                                    secondaryText: getFsModifiedState()
                                    secondaryLabel.color: fsModifiedState === 0 ? Theme.color_green : Theme.color_red
                                }

                                ListTextItem {
                                    //% ""
                                    text: "Latest firmware version installed?"
                                    secondaryText: getFirmwareState()
                                    secondaryLabel.color: getFirmwareState(false) ? Theme.color_green : Theme.color_red
                                    }

                                ListTextItem {
                                    text: CommonWords.firmware_version
                                    secondaryText: FirmwareVersion.versionText(dataItem.value, "venus")
                                    dataItem.uid: Global.venusPlatform.serviceUid + "/Firmware/Installed/Version"
                                }

                                ListTextItem {
                                    //% "Build date/time"
                                    text: qsTrId("settings_build_date_time")
                                    dataItem.uid: Global.venusPlatform.serviceUid + "/Firmware/Installed/Build"
                                }

                                ListTextItem {
                                    //% "HQ serial number"
                                    text: "HQ serial number"
                                    dataItem.uid: Global.venusPlatform.serviceUid + "/Device/HQSerialNumber"
                                }



                                ListLabel {
                                    text: "Tools to recover system integrity"
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

                                    onCheckedChanged: {
                                        if (disableAllModifications.checked) {
                                            Global.dialogLayer.open(askForRebootDialogComponent)
                                        } else {
                                            // Run system integrity check
                                            startCheckItem.setValue(1)
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
                                                    // Run system integrity check
                                                    startCheckItem.setValue(1)
                                                }
                                            }
                                        }
                                    }
                                }

                                ListButton {
                                    //% ""
                                    text: "Restore firmware integrity"
                                    //% ""
                                    button.text: "Press to restore"
                                    writeAccessLevel: VenusOS.User_AccessType_User
                                    onClicked: Global.dialogLayer.open(confirmReinstallDialogComponent)

                                    Component {
                                        id: confirmReinstallDialogComponent

                                        ModalWarningDialog {
                                            //% ""
                                            title: "This will disable all modifications, download and reinstall the firmware.<br>Internet connectivity is required.<br>Press 'OK' to continue."
                                            dialogDoneOptions: VenusOS.ModalDialog_DoneOptions_OkAndCancel
                                            onClosed: {
                                                if (result === T.Dialog.Accepted) {
                                                    allModificationsDisabledItem.setValue(1)
                                                    forceFirmwareReinstallItem.setValue(1)
                                                }
                                            }
                                        }
                                    }

                                }

                                /*
                                ListButton {
                                    id: installUpdate

                                    text: "Is Venus OS on the latest version?"
                                    button.text: {
                                        if (firmwareOnlineAvailableBuild == "" && firmwareOnlineAvailableVersion == "") {
                                            return "Yes"
                                        } else if (Global.firmwareUpdate.checkingForUpdate) {
                                            return "Checking..."
                                        } else if (firmwareState == FirmwareUpdater.ErrorDuringChecking) {
                                            return "Online check failed"
                                        } else if  (Global.firmwareUpdate.state === FirmwareUpdater.DownloadingAndInstalling) {
                                            if (progress.value) {
                                                //: Firmware update progress. %1 = firmware version, %2 = current update progress
                                                //% "Installing %1 %2%"
                                                return qsTrId("settings_firmware_online_installing_progress").arg(Global.firmwareUpdate.onlineAvailableVersion).arg(progress.value)
                                            }
                                            //: %1 = firmware version
                                            //% "Installing %1..."
                                            return qsTrId("settings_firmware_online_installing").arg(Global.firmwareUpdate.onlineAvailableVersion)
                                        } else {
                                            //: %1 = firmware version
                                            //% "Press to update to %1"
                                            return qsTrId("settings_firmware_online_press_to_update_to").arg(Global.firmwareUpdate.onlineAvailableVersion)
                                        }
                                    }

                                    enabled: !Global.firmwareUpdate.busy && !!Global.firmwareUpdate.onlineAvailableVersion && !Global.firmwareUpdate.checkingForUpdate
                                    writeAccessLevel: VenusOS.User_AccessType_User
                                    onClicked: {
                                        Global.firmwareUpdate.installUpdate(VenusOS.Firmware_UpdateType_Online)
                                    }

                                    VeQuickItem {
                                        id: progress
                                        uid: Global.venusPlatform.serviceUid + "/Firmware/Progress"
                                    }
                                }
                                */

                                ListNavigationItem {
                                    //% ""
                                    text: qsTrId("Firmware: Online update")
                                    onClicked: {
                                        Global.pageManager.pushPage("/pages/settings/PageSettingsFirmwareOnline.qml", { title: text })
                                    }
                                }

                                ListNavigationItem {
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
                            startCheckItem.setValue(1)

                        }
                    }
                }
            }

            ListNavigationItem {
                //% ""
                text: "Useful links"
                onClicked: {
                    Global.pageManager.pushPage(usefulLinksListItem, {"title": text})
                }

                Component {
                    id: usefulLinksListItem

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
        // Run system integrity check
        startCheckItem.setValue(1)
    }
}

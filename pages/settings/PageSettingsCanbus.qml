/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	required property CanbusProfile canbusProfile
	readonly property string _vecanSettingsPrefix: Global.systemSettings.serviceUid + "/Settings/Vecan/" + canbusProfile.gateway
	readonly property string _rvcSettingsPrefix: Global.systemSettings.serviceUid + "/Settings/Rvc/" + canbusProfile.gateway

	/* VE.Can and RV-C are mutually exclusive */
	readonly property bool _isRvc: rvcSameUniqueNameUsed.valid
	readonly property bool _isVecan: vecanSameUniqueNameUsed.valid

	CanbusServiceFinder {
		id: canbusService
		gateway: canbusProfile.gateway
	}

	VeQuickItem {
		id: vecanSameUniqueNameUsed
		uid: canbusService.vecanServiceUid ? canbusService.vecanServiceUid + "/Alarms/SameUniqueNameUsed" : ""
		onValueChanged: if (value === 1) timer.running = false
	}

	VeQuickItem {
		id: rvcSameUniqueNameUsed
		uid: canbusService.rvcServiceUid ? canbusService.rvcServiceUid + "/Alarms/SameUniqueNameUsed" : ""
		onValueChanged: if (value === 1) timer.running = false
	}

	GradientListView {
		model: VisibleItemModel {
			ListRadioButtonGroup {
				//% "CAN-bus profile"
				text: qsTrId("settings_canbus_profile")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Canbus/" + canbusProfile.gateway + "/Profile"
				optionModel: canbusProfile.optionModel
			}

			ListNavigation {
				text: CommonWords.devices
				preferredVisible: root._isVecan || root._isRvc
				onClicked: {
					if (root._isVecan) {
						Global.pageManager.pushPage("/pages/settings/PageSettingsVecanDevices.qml",
								{ serviceUid: canbusService.vecanServiceUid })
					} else if (root._isRvc) {
						Global.pageManager.pushPage("/pages/settings/PageSettingsRvcDevices.qml",
								{ serviceUid: canbusService.rvcServiceUid })
					}
				}
			}

			ListNavigation {
                                //% "NMEA2000-out"
                                text: qsTrId("settings_canbus_nmea2000out")
                                onClicked: {
                                        Global.pageManager.pushPage("/pages/settings/PageSettingsCanbusN2KGateway.qml",
                                                { canbusProfile: canbusProfile, title: qsTrId("settings_canbus_nmea2000out")})
                                }
                                preferredVisible: root._isVecan
                        }


			ListSpinBox {
				//% "Unique identity number selector"
				text: qsTrId("settings_canbus_unique_id_select")
				preferredVisible: root._isVecan || root._isRvc
				dataItem.uid: (root._isRvc ? root._rvcSettingsPrefix : root._vecanSettingsPrefix) + "/VenusUniqueId"
				caption: root._isVecan
					//% "Above selector sets which block of unique identity numbers to use for the NAME Unique Identity Numbers in the PGN 60928 NAME field. Change only when using multiple GX Devices in one VE.Can network."
					? qsTrId("settings_canbus_unique_id_vecan_description")
					: root._isRvc
						//% "Above selector sets which block of unique identity numbers to use for the Serial number in the DGN 60928 ADDRESS_CLAIM field. Change only when using multiple GX Devices in one RV-C network."
						? qsTrId("settings_canbus_unique_id_rvc_description")
						: ""
				onSelectorAccepted: {
					//% "Please wait, changing and checking the unique number takes a while"
					Global.showToastNotification(VenusOS.Notification_Info, qsTrId("settings_canbus_unique_id_wait"), 5000)
					uniqueCheck.startCheck(3)
				}
			}

			ListButton {
				id: uniqueCheck

				property bool testDone

				function startCheck(timeout) {
					timer.remainingTime = timeout
					timer.running = true
					testDone = false
				}

				//% "Check Unique id numbers"
				text: qsTrId("settings_canbus_unique_id_choose")
				preferredVisible: root._isVecan || root._isRvc
				secondaryText: timer.running
					? Utils.secondsToString(timer.remainingTime)
					  //% "Press to check"
					: qsTrId("settings_canbus_unique_id_press_to_check")
				height: visible
						? (implicitHeight
							+ (uniqueIdConflictLabel.visible ? uniqueIdConflictLabel.height : 0)
							+ (uniqueIdOkLabel.visible ? uniqueIdOkLabel.height : 0))
						: 0

				bottomContentChildren: [
					PrimaryListLabel {
						id: uniqueIdConflictLabel
						topPadding: 0
						bottomPadding: 0
						//% "There is another device connected with this unique number, please select a new number."
						text: qsTrId("settings_canbus_unique_id_conflict")
						preferredVisible: vecanSameUniqueNameUsed.value === 1 || rvcSameUniqueNameUsed.value === 1
					},
					PrimaryListLabel {
						id: uniqueIdOkLabel
						topPadding: 0
						bottomPadding: 0
						//% "OK: No other device is connected with this unique number."
						text: qsTrId("settings_canbus_unique_id_ok")
						preferredVisible: (vecanSameUniqueNameUsed.value === 0 || rvcSameUniqueNameUsed.value === 0) && uniqueCheck.testDone
					}
				]

				onClicked: {
					if (root._isRvc) {
						rvcSameUniqueNameUsed.setValue(0)
					} else {
						vecanSameUniqueNameUsed.setValue(0)
					}
					startCheck(3)
				}

				Timer {
					id: timer

					property int remainingTime

					interval: 1000
					repeat: true
					onTriggered: {
						if (--remainingTime === 0) {
							running = false
							uniqueCheck.testDone = true
						}
					}
				}
			}

			ListNavigation {
				text: CommonWords.network_status
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/PageCanbusStatus.qml",
						{ gateway: canbusProfile.gateway, title: root.title })
				}
			}
		}
	}
}

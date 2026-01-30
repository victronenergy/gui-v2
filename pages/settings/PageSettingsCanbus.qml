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

	VeQuickItem {
		id: n2kOutEnabled
		uid: root._vecanSettingsPrefix + "/N2kGatewayEnabled"
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

			ListSwitch {
				//% "NMEA2000-out"
				text: qsTrId("settings_canbus_nmea2000out")
				valueTrue: 1
				dataItem.value: n2kOutEnabled.value & valueTrue
				preferredVisible: root._isVecan && n2kOutEnabled.valid
				onClicked: n2kOutEnabled.setValue(checked ? (n2kOutEnabled.value & ~valueTrue) : (n2kOutEnabled.value | valueTrue))
			}

			ListSwitch {
				//% "NMEA2000 outbound alerts"
				text: qsTrId("settings_canbus_nmea2000out_alerts")
				valueTrue: 2
				dataItem.value: n2kOutEnabled.value & valueTrue
				preferredVisible: root._isVecan && n2kOutEnabled.valid && n2kOutEnabled.value & 1
				onClicked: n2kOutEnabled.setValue(checked ? (n2kOutEnabled.value & ~valueTrue) : (n2kOutEnabled.value | valueTrue))
			}

			ListSwitch {
				//% "Reverse current polarity"
				text: qsTrId("settings_canbus_rvc_reverse_current_polarity")
				dataItem.uid: root._rvcSettingsPrefix + "/ReverseCurrent"
				preferredVisible: root._isRvc && dataItem.valid
				//% "When enabled, the current polarity in the CHARGER_AC_STATUS_1, CHARGER_STATUS_2, INVERTER_AC_STATUS_1, and SOLAR_CONTROLLER_BATTERY_STATUS DGNs is reversed."
				caption: qsTrId("settings_canbus_rvc_reverse_current_polarity_description")
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
				caption: {
					if (vecanSameUniqueNameUsed.value === 1 || rvcSameUniqueNameUsed.value === 1) {
						//% "There is another device connected with this unique number, please select a new number."
						return qsTrId("settings_canbus_unique_id_conflict")
					} else if ((vecanSameUniqueNameUsed.value === 0 || rvcSameUniqueNameUsed.value === 0) && uniqueCheck.testDone) {
						//% "OK: No other device is connected with this unique number."
						return qsTrId("settings_canbus_unique_id_ok")
					} else {
						return ""
					}
				}

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
						{ gateway: canbusProfile.gateway, title: CommonWords.network_status })
				}
			}

			ListNavigation {
				//% "CANopen motor drives"
				text: qsTrId("pagesettingsintegrations_canopenmotordrive")
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/PageSettingsCanOpenMotordrive.qml",
						{ gateway: canbusProfile.gateway, title: text })
				}
				preferredVisible: canbusProfile.canbusProfile.value === VenusOS.CanBusProfile_CanOpenMotordrive250 || canbusProfile.canbusProfile.value === VenusOS.CanBusProfile_CanOpenMotordrive500
			}
		}
	}
}

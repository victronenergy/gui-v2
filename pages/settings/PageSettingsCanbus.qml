/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Utils

Page {
	id: root

	property string gateway
	property int canConfig

	readonly property string _vecanSettingsPrefix: Global.systemSettings.serviceUid + "/Settings/Vecan/" + gateway
	readonly property string _rvcSettingsPrefix: Global.systemSettings.serviceUid + "/Settings/Rvc/" + gateway

	/* VE.Can and RV-C are mutually exclusive */
	readonly property bool _isRvc: rvcSameUniqueNameUsed.valid
	readonly property bool _isVecan: vecanSameUniqueNameUsed.valid

	CanbusServiceFinder {
		id: canbusService
		gateway: root.gateway
	}

	DataPoint {
		id: vecanSameUniqueNameUsed
		source: canbusService.vecanServiceUid + "/Alarms/SameUniqueNameUsed"
		onValueChanged: if (value === 1) timer.running = false
	}

	DataPoint {
		id: rvcSameUniqueNameUsed
		source: canbusService.rvcServiceUid + "/Alarms/SameUniqueNameUsed"
		onValueChanged: if (value === 1) timer.running = false
	}

	GradientListView {
		model: ObjectModel {
			ListRadioButtonGroup {
				function isReadOnly(profile) {
					switch (root.canConfig) {
					case VenusOS.CanBusConfig_ForcedVeCan:
						return profile !== VenusOS.CanBusProfile_Vecan
					case VenusOS.CanBusConfig_ForcedCanBusBms:
						return profile !== VenusOS.CanBusProfile_CanBms500
					default:
						return false
					}
				}

				//% "CAN-bus profile"
				text: qsTrId("settings_canbus_profile")
				dataSource: Global.systemSettings.serviceUid + "/Settings/Canbus/" + root.gateway + "/Profile"
				optionModel: [
					{
						//% "Disabled"
						display: qsTrId("settings_disabled"),
						value: VenusOS.CanBusProfile_Disabled
					},
					{
						//% "VE.Can & Lynx Ion BMS (250 kbit/s)"
						display: qsTrId("settings_canbus_vecan_lynx_ion_bms"),
						value: VenusOS.CanBusProfile_Vecan,
						readOnly: isReadOnly(VenusOS.CanBusProfile_Vecan)
					},
					{
						//% "VE.Can & CAN-bus BMS (250 kbit/s)"
						display: qsTrId("settings_canbus_vecan_and_can_bus_bms"),
						value: VenusOS.CanBusProfile_VecanAndCanBms,
						readOnly: isReadOnly(VenusOS.CanBusProfile_VecanAndCanBms)
					},
					{
						//% "CAN-bus BMS (500 kbit/s)"
						display: qsTrId("settings_canbus_bms"),
						value: VenusOS.CanBusProfile_CanBms500,
						readOnly: isReadOnly(VenusOS.CanBusProfile_CanBms500)
					},
					{
						//% "Oceanvolt (250 kbit/s)"
						display: qsTrId("settings_oceanvolt"),
						value: VenusOS.CanBusProfile_Oceanvolt,
						readOnly: isReadOnly(VenusOS.CanBusProfile_Oceanvolt)
					},
					{
						//% "RV-C (250 kbit/s)"
						display: qsTrId("settings_rvc"),
						value: VenusOS.CanBusProfile_RvC,
						readOnly: isReadOnly(VenusOS.CanBusProfile_RvC)
					},
					{
						//% "Up, but no services (250 kbit/s)"
						display: qsTrId("settings_up_bu_no_services"),
						value: VenusOS.CanBusProfile_None250,
						readOnly: true
					}
				]
			}

			ListNavigationItem {
				//% "Devices"
				text: qsTrId("settings_devices")
				visible: root._isVecan || root._isRvc
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
				dataSource: root._vecanSettingsPrefix + "/N2kGatewayEnabled"
				visible: root._isVecan
			}

			ListSpinBox {
				//% "Unique identity number selector"
				text: qsTrId("settings_canbus_unique_id_select")
				visible: root._isVecan || root._isRvc
				dataSource: (root._isRvc ? root._rvcSettingsPrefix : root._vecanSettingsPrefix) + "/VenusUniqueId"

				bottomContent.children: ListLabel {
					visible: text.length > 0
					color: Theme.color_font_secondary
					text: root._isVecan
						//% "Above selector sets which block of unique identity numbers to use for the NAME Unique Identity Numbers in the PGN 60928 NAME field. Change only when using multiple GX Devices in one VE.Can network."
						? qsTrId("settings_canbus_unique_id_vecan_description")
						: root._isRvc
							//% "Above selector sets which block of unique identity numbers to use for the Serial number in the DGN 60928 ADDRESS_CLAIM field. Change only when using multiple GX Devices in one RV-C network."
							? qsTrId("settings_canbus_unique_id_rvc_description")
							: ""
				}

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
				visible: root._isVecan || root._isRvc
				button.text: timer.running
					? Utils.secondsToString(timer.remainingTime)
					  //% "Press to check"
					: qsTrId("settings_canbus_unique_id_press_to_check")
				height: visible
						? (implicitHeight
							+ (uniqueIdConflictLabel.visible ? uniqueIdConflictLabel.height : 0)
							+ (uniqueIdOkLabel.visible ? uniqueIdOkLabel.height : 0))
						: 0

				bottomContent.children: [
					ListLabel {
						id: uniqueIdConflictLabel
						topPadding: 0
						bottomPadding: 0
						//% "There is another device connected with this unique number, please select a new number."
						text: qsTrId("settings_canbus_unique_id_conflict")
						visible: vecanSameUniqueNameUsed.value === 1 || rvcSameUniqueNameUsed.value === 1
					},
					ListLabel {
						id: uniqueIdOkLabel
						topPadding: 0
						bottomPadding: 0
						//% "OK: No other device is connected with this unique number."
						text: qsTrId("settings_canbus_unique_id_ok")
						visible: (vecanSameUniqueNameUsed.value === 0 || rvcSameUniqueNameUsed.value === 0) && uniqueCheck.testDone
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

			ListNavigationItem {
				//% "Network status"
				text: qsTrId("settings_network_status")
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/PageCanbusStatus.qml",
						{ gateway: root.gateway, title: root.title })
				}
			}
		}
	}
}

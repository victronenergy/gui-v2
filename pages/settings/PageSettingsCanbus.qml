/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "/components/Utils.js" as Utils

Page {
	id: root

	property string gateway
	property int canConfig

	readonly property string _vecanSettingsPrefix: "com.victronenergy.settings/Settings/Vecan/" + gateway
	readonly property string _vecanServicePrefix: "com.victronenergy.vecan." + gateway

	readonly property string _rvcSettingsPrefix: "com.victronenergy.settings/Settings/Rvc/" + gateway
	readonly property string _rvcServicePrefix: "com.victronenergy.rvc." + gateway

	/* VE.Can and RV-C are mutually exclusive */
	readonly property bool _isRvc: rvcSameUniqueNameUsed.valid
	readonly property bool _isVecan: vecanSameUniqueNameUsed.valid

	DataPoint {
		id: vecanSameUniqueNameUsed
		source: root._vecanServicePrefix + "/Alarms/SameUniqueNameUsed"
		onValueChanged: if (value === 1) timer.running = false
	}

	DataPoint {
		id: rvcSameUniqueNameUsed
		source: root._rvcServicePrefix + "/Alarms/SameUniqueNameUsed"
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
				source: "com.victronenergy.settings/Settings/Canbus/" + root.gateway + "/Profile"
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
				visible: root._isVecan
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/PageSettingsVecanDevices.qml",
						{ gateway: root.gateway })
				}
			}

			ListSwitch {
				//% "NMEA2000-out"
				text: qsTrId("settings_canbus_nmea2000out")
				source: root._vecanSettingsPrefix + "/N2kGatewayEnabled"
				visible: root._isVecan
			}

			ListSpinBox {
				//% "Unique identity number selector"
				text: qsTrId("settings_canbus_unique_id_select")
				visible: root._isVecan || root._isRvc
				source: (root._isRvc ? root._rvcSettingsPrefix : root._vecanSettingsPrefix) + "/VenusUniqueId"
				height: visible ? (implicitHeight + uniqueIdDescriptionLabel.height) : 0

				onSelectorAccepted: {
					//% "Please wait, changing and checking the unique number takes a while"
					Global.showToastNotification(VenusOS.Notification_Info, qsTrId("settings_canbus_unique_id_wait"), 5000)
					uniqueCheck.startCheck(3)
				}

				ListLabel {
					id: uniqueIdDescriptionLabel

					anchors {
						bottom: parent.bottom
						bottomMargin: Theme.geometry.listItem.content.verticalMargin
					}
					text: root._isVecan
						  //% "Above selector sets which block of unique identity numbers to use for the NAME Unique Identity Numbers in the PGN 60928 NAME field. Change only when using multiple GX Devices in one VE.Can network."
						? qsTrId("settings_canbus_unique_id_vecan_description")
						  //% "Above selector sets which block of unique identity numbers to use for the Serial number in the DGN 60928 ADDRESS_CLAIM field. Change only when using multiple GX Devices in one RV-C network."
						: qsTrId("settings_canbus_unique_id_rvc_description")
					visible: root._isVecan || root._isRvc
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

				ListLabel {
					id: uniqueIdConflictLabel

					anchors {
						bottom: parent.bottom
						bottomMargin: Theme.geometry.listItem.content.verticalMargin
					}
					//% "There is another device connected with this unique number, please select a new number."
					text: qsTrId("settings_canbus_unique_id_conflict")
					visible: vecanSameUniqueNameUsed.value === 1 || rvcSameUniqueNameUsed.value === 1
				}

				ListLabel {
					id: uniqueIdOkLabel

					anchors {
						bottom: parent.bottom
						bottomMargin: Theme.geometry.listItem.content.verticalMargin
					}
					//% "OK: No other device is connected with this unique number."
					text: qsTrId("settings_canbus_unique_id_ok")
					visible: (vecanSameUniqueNameUsed.value === 0 || rvcSameUniqueNameUsed.value === 0) && uniqueCheck.testDone
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

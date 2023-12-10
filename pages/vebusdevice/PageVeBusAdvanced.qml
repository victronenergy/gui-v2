/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQml
import Victron.VenusOS
import Victron.Units

Page {
	id: root

	property var veBusDevice
	readonly property bool isMulti: veBusDevice.numberOfAcInputs > 0
	property bool startManualEq: false
	readonly property bool isEssOrHub4: systemType.value === "ESS" || systemType.value === 'Hub-4'
	property int forceEqCmd: 1


	DataPoint {
		id: systemType
		source: "com.victronenergy.system/SystemType"
	}

	DataPoint {
		id: setChargerState
		source: root.veBusDevice.serviceUid + "/VebusSetChargeState"
	}

	DataPoint {
		id: vebusSubState
		source: root.veBusDevice.serviceUid + "/VebusChargeState"
		onValueChanged: {
			if (value === VenusOS.VeBusDevice_ChargeState_Equalize) {
				startManualEq = false
			}
		}
	}

	DataPoint {
		id: redetectSystem
		source: root.veBusDevice.serviceUid + "/RedetectSystem"
	}

	DataPoint {
		id: systemReset
		source: root.veBusDevice.serviceUid + "/SystemReset"
	}

	DataPoint {
		id: firmwareVersion
		source: root.veBusDevice.serviceUid + "/FirmwareVersion"
	}

	DataPoint {
		id: masterHasNetworkQuality

		source: root.veBusDevice.serviceUid + "/Devices/0/ExtendStatus/VeBusNetworkQualityCounter"
	}

	Timer {
		id: startTimer
		interval: 250
		repeat: true
		running: vebusSubState.value !== VenusOS.VeBusDevice_ChargeState_Equalize && startManualEq
	}

	Timer {
		id: interruptTimer
		interval: 250
		onRunningChanged: repeat = true
		onTriggered: repeat = vebusSubState.value === VenusOS.VeBusDevice_ChargeState_Equalize
	}

	GradientListView {
		id:  gradientListView
		model: ObjectModel {

			ListButton {
				property bool interrupt: vebusSubState.value === VenusOS.VeBusDevice_ChargeState_Equalize

				function showEqStartToast()
				{
					let text = ""
					if (isEssOrHub4) {
						//% "Warning: Activating equalization in an ESS system with solar chargers can cause charging the battery at high voltage with a too high current."
						text = qsTrId("vebus_device_warning")
					}

					//% "The system will automatically switch over to float once the Equalization charge has been completed."
					text += qsTrId("vebus_device_switch_to_float")

					Global.showToastNotification(VenusOS.Notification_Info, text, 15000)
				}

				text: interrupt
						//% "Interrupt equalization"
					  ? qsTrId("vebus_device_interrupt_equalization")
						//% "Equalization"
					  : qsTrId("vebus_device_equalization")
				button.text: {
					if (interruptTimer.running)
						//% "Interrupting..."
						return qsTrId("vebus_device_interrupting")
					if (startTimer.running)
						//% "Starting..."
						return qsTrId("vebus_device_starting")
					if (interrupt)
						//% "Press to interrupt"
						return qsTrId("vebus_device_press_to_interrupt")
					//% "Press to start"
					return qsTrId("vebus_device_press_to_start")
				}
				enabled: !isNaN(setChargerState.value) && !isNaN(vebusSubState.value) && !startTimer.running && !interruptTimer.running

				onClicked: {
					if (firmwareVersion.value < 0x400) {
						//% "This feature requires firmware version 400 or higher, contact your installer to update your Multi/Quattro."
						Global.showToastNotification(VenusOS.Notification_Info, qsTrId("vebus_device_update_firmware"), 5000)
					}

					switch (vebusSubState.value) {
					case VenusOS.VeBusDevice_ChargeState_InitializingCharger:
						//% "Charger not ready, equalization cannot be started."
						Global.showToastNotification(VenusOS.Notification_Info, qsTrId("vebus_device_charger_not_ready"), 5000)
						break;
					case VenusOS.VeBusDevice_ChargeState_Bulk:
						//% "Equalization cannot be triggered during bulk charge state."
						Global.showToastNotification(VenusOS.Notification_Info, qsTrId("vebus_device_no_equalisation_during_bulk"), 5000)
						break;
					case VenusOS.VeBusDevice_ChargeState_Equalize:
						stopEq.clicked()
						break;
					default:
						setChargerState.setValue(forceEqCmd)
						startManualEq = true
						showEqStartToast()
					}
				}
			}

			ListRadioButtonGroup {
				id: stopEq

				readonly property int localValue: optionModel[currentIndex].value

				//% "Interrupt equalization"
				text: qsTrId("vebus_device_interrupt_equalization")
				optionModel: [
					{
						//% "Interrupt and restart absorption"
						display: qsTrId("vebus_device_interrupt_and_restart_absorption"),
						value: VenusOS.VeBusDevice_ChargeState_Absorption,
						readOnly: vebusSubState.value !== VenusOS.VeBusDevice_ChargeState_Equalize
					},
					{
						//% "Interrupt and go to float"
						display: qsTrId("vebus_device_interrupt_and_go_to_float"),
						value: VenusOS.VeBusDevice_ChargeState_Float,
						readOnly: vebusSubState.value !== VenusOS.VeBusDevice_ChargeState_Equalize
					},
					{
						//% "Interrupt"
						display: qsTrId("vebus_device_interrupt"),
						value: VenusOS.VeBusDevice_ChargeState_Bulk,
						readOnly: vebusSubState.value === VenusOS.VeBusDevice_ChargeState_Equalize
					},
					{
						//% "Do not interrupt"
						display: qsTrId("vebus_device_do_not_interrupt"),
						value: VenusOS.VeBusDevice_ChargeState_InitializingCharger,
						readOnly: false
					}
				]
				currentIndex: 0
				visible: false
				onOptionClicked: function(index) {
					if (localValue !== VenusOS.VeBusDevice_ChargeState_InitializingCharger) {
						interruptTimer.start()
						if (localValue !== VenusOS.VeBusDevice_ChargeState_Bulk) {
							setChargerState.setValue(localValue)
						}
					}
				}

				onAboutToPop: function() {
					// Return back to float as default option
					currentIndex = 1
				}
			}

			ListButton {
				//% "Redetect VE.Bus system"
				text: qsTrId("vebus_device_redectect_vebus_system")
				button.text: redetectSystem.value === 1
								//% "Redetecting..."
							 ? qsTrId("vebus_device_redetecting")
								//% "Press to redetect"
							 : qsTrId("vebus_device_press_to_redetect")
				writeAccessLevel: VenusOS.User_AccessType_User
				enabled: redetectSystem.valid
				onClicked: redetectSystem.setValue(1)
			}

			ListButton {
				//% "Restart VE.Bus system"
				text: qsTrId("vebus_device_restart_vebus_system")
				button.text: systemReset.value === 1
								//% "Restarting..."
							 ? qsTrId("vebus_device_restarting")
								//% "Press to restart"
							 : qsTrId("vebus_device_press_to_restart")
				writeAccessLevel: VenusOS.User_AccessType_User
				enabled: systemReset.valid
				onClicked: systemReset.setValue(1)
			}

			ListTextItem {
				//% "AC input 1 ignored"
				text: qsTrId("vebus_device_ac_input_1_ignored")
				secondaryText: dataValue ? CommonWords.yes : CommonWords.no
				dataSource: root.veBusDevice.serviceUid + "/Ac/State/IgnoreAcIn1"
				visible: dataValid && isMulti
			}

			ListTextItem {
				//% "AC input 2 ignored"
				text: qsTrId("vebus_device_ac_input_2_ignored")
				secondaryText: dataValue ? CommonWords.yes : CommonWords.no
				dataSource: root.veBusDevice.serviceUid + "/Ac/State/IgnoreAcIn2"
				visible: dataValid && isMulti
			}

			ListRadioButtonGroup {
				//% "ESS Relay test"
				text: qsTrId("vebus_device_ess_relay_test")
				dataSource: root.veBusDevice.serviceUid + "/Devices/0/ExtendStatus/WaitingForRelayTest"
				enabled: false
				visible: dataValid && isEssOrHub4 && isMulti
				optionModel: [
					//% "Completed"
					{ display: qsTrId("vebus_device_ess_relay_test_completed"), value: 0 },
					//% "Pending"
					{ display: qsTrId("vebus_device_ess_relay_test_pending"), value: 1 }
				]
			}


			ListNavigationItem {
				//% "VE.Bus diagnostics"
				text: qsTrId("vebus_diagnostics")
				showAccessLevel: VenusOS.User_AccessType_Service
				visible: defaultVisible && masterHasNetworkQuality.valid
				onClicked: Global.pageManager.pushPage(vebusDiagnosticsPage)

				Component {
					id: vebusDiagnosticsPage

					Page {
						GradientListView {
							model: ObjectModel {
								Column {
									width: parent ? parent.width : 0

									Repeater {
										model: 18

										ListTextItem {
											//% "Network quality counter Phase L%1, device %2 (%3)"
											text: qsTrId("vebus_veice_network_quality_counter").arg((index % 3) + 1).arg(Math.floor(index / 3) + 1).arg(index)
											dataSource: root.veBusDevice.serviceUid + "/Devices/" + index + "/ExtendStatus/VeBusNetworkQualityCounter"
											visible: dataValid
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}
}

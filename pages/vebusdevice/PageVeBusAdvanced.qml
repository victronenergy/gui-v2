/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQml
import Victron.VenusOS

Page {
	id: root

	required property string bindPrefix
	readonly property bool isMulti: numberOfAcInputs.valid && numberOfAcInputs.value > 0
	property bool startManualEq: false
	readonly property bool isEssOrHub4: systemType.value === "ESS" || systemType.value === 'Hub-4'
	property int forceEqCmd: 1

	VeQuickItem {
		id: numberOfAcInputs
		uid: root.bindPrefix + "/Ac/NumberOfAcInputs"
	}

	VeQuickItem {
		id: systemType
		uid: Global.system.serviceUid + "/SystemType"
	}

	VeQuickItem {
		id: setChargerState
		uid: root.bindPrefix + "/VebusSetChargeState"
	}

	VeQuickItem {
		id: vebusSubState
		uid: root.bindPrefix + "/VebusChargeState"
		onValueChanged: {
			if (value === VenusOS.VeBusDevice_ChargeState_Equalize) {
				startManualEq = false
			}
		}
	}

	VeQuickItem {
		id: redetectSystem
		uid: root.bindPrefix + "/RedetectSystem"
	}

	VeQuickItem {
		id: systemReset
		uid: root.bindPrefix + "/SystemReset"
	}

	VeQuickItem {
		id: firmwareVersion
		uid: root.bindPrefix + "/FirmwareVersion"
	}

	VeQuickItem {
		id: masterHasNetworkQuality

		uid: root.bindPrefix + "/Devices/0/ExtendStatus/VeBusNetworkQualityCounter"
	}

	VeQuickItem {
		id: mkConnection

		uid: root.bindPrefix + "/Interfaces/Mk2/Connection"
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
		model: VisibleItemModel {

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
				secondaryText: {
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
				interactive: !isNaN(setChargerState.value) &&
							 !isNaN(vebusSubState.value) &&
							 !startTimer.running &&
							 !interruptTimer.running
				preferredVisible: root.isMulti

				onClicked: {
					if (firmwareVersion.value < 0x400) {
						//% "This feature requires firmware version 400 or higher. Contact your installer to update your Multi/Quattro."
						Global.showToastNotification(VenusOS.Notification_Info, qsTrId("vebus_device_update_firmware"), 5000)
					}

					switch (vebusSubState.value) {
					case VenusOS.VeBusDevice_ChargeState_InitializingCharger:
						//% "Charger not ready, equalization cannot be started"
						Global.showToastNotification(VenusOS.Notification_Info, qsTrId("vebus_device_charger_not_ready"), 5000)
						break;
					case VenusOS.VeBusDevice_ChargeState_Bulk:
						//% "Equalization cannot be triggered during bulk charge state"
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
				currentIndex: 1 // float state is always selected
				preferredVisible: false
				onOptionClicked: function(index) {
					const localValue = optionModel[index].value
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
				secondaryText: redetectSystem.value === 1
								//% "Redetecting..."
							 ? qsTrId("vebus_device_redetecting")
								//% "Press to redetect"
							 : qsTrId("vebus_device_press_to_redetect")
				writeAccessLevel: VenusOS.User_AccessType_User
				onClicked: redetectSystem.setValue(1)
			}

			ListButton {
				//% "Restart VE.Bus system"
				text: qsTrId("vebus_device_restart_vebus_system")
				secondaryText: systemReset.value === 1
								//% "Restarting..."
							 ? qsTrId("vebus_device_restarting")
								//% "Press to restart"
							 : qsTrId("vebus_device_press_to_restart")
				writeAccessLevel: VenusOS.User_AccessType_User
				onClicked: Global.dialogLayer.open(restartVEBusComponent)

				Component {
					id: restartVEBusComponent

					ModalWarningDialog {
						//% "Are you sure?"
						title: qsTrId("vebus_device_restart_vebus_system_restart_confirmation_title")
						//% "Restarting the VE.Bus system will reset any inverter on the bus, and result in a loss of power to their outputs."
						description: qsTrId("vebus_device_restart_vebus_system_restart_confirmation_description")
						dialogDoneOptions: VenusOS.ModalDialog_DoneOptions_OkAndCancel
						onAccepted: systemReset.setValue(1)
					}
				}
			}

			ListText {
				//% "AC input 1 ignored"
				text: qsTrId("vebus_device_ac_input_1_ignored")
				secondaryText: dataItem.value ? CommonWords.yes : CommonWords.no
				dataItem.uid: root.bindPrefix + "/Ac/State/IgnoreAcIn1"
				preferredVisible: dataItem.valid && isMulti
			}

			ListText {
				//% "AC input 2 ignored"
				text: qsTrId("vebus_device_ac_input_2_ignored")
				secondaryText: dataItem.value ? CommonWords.yes : CommonWords.no
				dataItem.uid: root.bindPrefix + "/Ac/State/IgnoreAcIn2"
				preferredVisible: dataItem.valid && isMulti
			}

			ListRadioButtonGroup {
				//% "ESS Relay test"
				text: qsTrId("vebus_device_ess_relay_test")
				dataItem.uid: root.bindPrefix + "/Devices/0/ExtendStatus/WaitingForRelayTest"
				interactive: false
				preferredVisible: dataItem.valid && isEssOrHub4 && isMulti
				optionModel: [
					//% "Completed"
					{ display: qsTrId("vebus_device_ess_relay_test_completed"), value: 0 },
					//% "Pending"
					{ display: qsTrId("vebus_device_ess_relay_test_pending"), value: 1 }
				]
			}

			ListNavigation {
				//% "Backup & Restore"
				text: qsTrId("backup_and_restore")
				preferredVisible: mkConnection.valid
				onClicked: Global.pageManager.pushPage("/pages/vebusdevice/PageVeBusBackupRestore.qml", {
					"title": text,
					"serialVebus": mkConnection.value.split("/").pop()
				})
			}

			ListNavigation {
				//% "VE.Bus diagnostics"
				text: qsTrId("vebus_diagnostics")
				showAccessLevel: VenusOS.User_AccessType_Service
				preferredVisible: masterHasNetworkQuality.valid
				onClicked: Global.pageManager.pushPage(vebusDiagnosticsPage, {"title": text})

				Component {
					id: vebusDiagnosticsPage

					Page {
						GradientListView {
							model: VisibleItemModel {
								SettingsColumn {
									width: parent ? parent.width : 0

									Repeater {
										model: 18

										ListText {
											//% "Network quality counter Phase L%1, device %2 (%3)"
											text: qsTrId("vebus_veice_network_quality_counter").arg((index % 3) + 1).arg(Math.floor(index / 3) + 1).arg(index)
											dataItem.uid: root.bindPrefix + "/Devices/" + index + "/ExtendStatus/VeBusNetworkQualityCounter"
											preferredVisible: dataItem.valid
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

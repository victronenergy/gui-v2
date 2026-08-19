/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	Provides a list of settings for a vebus device.
*/
DevicePage {
	id: root

	required property string bindPrefix
	readonly property bool isMulti: numberOfAcInputs.valid && numberOfAcInputs.value > 0
	readonly property bool chargeInProcess: preferRenewableEnergy.value === 0

	VeQuickItem {
		id: temperatureItem
		uid: root.bindPrefix + "/Dc/0/Temperature"
	}
	VeQuickItem {
		id: numberOfAcInputs
		uid: root.bindPrefix + "/Ac/NumberOfAcInputs"
	}
	VeQuickItem {
		id: bmsMode

		uid: root.bindPrefix + "/Devices/Bms/Version"
	}
	VeQuickItem {
		id: bmsType

		uid: root.bindPrefix + "/Bms/BmsType"
	}
	VeQuickItem {
		id: bmsExpected

		uid: root.bindPrefix + "/Bms/BmsExpected"
	}
	VeQuickItem {
		id: mkVersion

		uid: root.bindPrefix + "/Interfaces/Mk2/Version"
	}
	VeQuickItem {
		id: mk3Update

		uid: Global.systemSettings.serviceUid + "/Settings/Vebus/AllowMk3Fw212Update"
	}
	VeQuickItem {
		id: preferRenewableEnergy

		uid: root.bindPrefix + "/Dc/0/PreferRenewableEnergy"
	}
	VeQuickItem {
		id: firmwareVersion
		uid: root.bindPrefix + "/FirmwareVersion"
	}
	VeQuickItem {
		id: state
		uid: root.bindPrefix + "/State"
	}

	serviceUid: bindPrefix

	settingsModel: DelegateComponentModel {
		DelegateComponent {
			ListInverterChargerModeButton {
				serviceUid: root.bindPrefix
			}
		}

		DelegateComponent {
			ListText {
				text: CommonWords.state
				secondaryText: VenusOS.system_stateToText(state.value)
			}
		}

		DelegateComponent {
			id: mk3firmwareDC
			preferredVisible: mkVersion.value === 1170212 && mk3Update.value === 0
			PrimaryListLabel {
				id: mk3firmware

				function doUpdate() { mk3Update.setValue(1) }

				//% "A new MK3 version is available.\nNOTE: The update might temporarily stop the system."
				text: qsTrId("vebus_mk3_new_version_available")
			}
		}

		DelegateComponent {
			preferredVisible: mk3firmwareDC.preferredVisible
			ListButton {
				//% "Update the MK3"
				text: qsTrId("vebus_device_update_the_mk3")
				//: Trigger an update action
				//% "Update"
				secondaryText: qsTrId("vebus_device_press_update")
				writeAccessLevel: VenusOS.User_AccessType_User
				onClicked: {
					//% "Updating the MK3, values will reappear after the update is complete"
					Global.showToastNotification(VenusOS.Notification_Info, qsTrId("vebus_device_updating_the_mk3"), 10000)
					mk3Update.setValue(1)
				}
			}
		}

		DelegateComponent {
			/*	This shows the current limits for Ac/In/<x>/CurrentLimit.
				Note that gui-v1 instead shows a single current limit based on Ac/ActiveIn/CurrentLimit, which is deprecated in the dbus doco. */
			SettingsColumn {
				width: parent ? parent.width : 0
				preferredVisible: inputSettingsModel.count > 0

				Repeater {
					model: AcInputSettingsModel {
						id: inputSettingsModel
						serviceUid: root.bindPrefix
					}
					delegate: ListCurrentLimitButton {
						required property AcInputSettings inputSettings

						serviceUid: root.bindPrefix
						inputNumber: inputSettings.inputNumber
						inputType: inputSettings.inputType
					}
				}
			}
		}

		DelegateComponent {
			preferredVisible: preferRenewableEnergy.value === 2
			ListText {
				//% "Charging the battery to 100%"
				text: qsTrId("vebus_device_charging_to_100")
				//% "In progress"
				secondaryText: qsTrId("vebus_device_in_progress")
			}
		}

		DelegateComponent {
			preferredVisible: preferRenewableEnergy.valid && preferRenewableEnergy.value !== 2
			ListNavigation {
				text: chargeInProcess ? CommonWords.stop_action : CommonWords.start_action
				secondaryText: chargeInProcess ?
								   //% "Charging the battery to 100%"
								   qsTrId("vebus_device_charging_the_battery_to_100")
								 :
								   //% "Charge the battery to 100%"
								   qsTrId("vebus_device_charge_the_battery_to_100")
				onClicked: Global.pageManager.pushPage(newPageComponent)

				Component {
					id: newPageComponent

					Page {
						//% "The system will return to normal operation, prioritizing renewable energy.\nDo you want to continue?"
						readonly property string returnToNormal: qsTrId("vebus_device_return_to_normal_operation")

						//% "Charge battery"
						title: qsTrId("page_vebus_charge_battery")

						GradientListView {

							Timer {
								id: popTimer

								interval: Theme.animation_settings_radioButtonPage_autoClose_duration
								onTriggered: Global.pageManager.popPage()
							}

							model: DelegateComponentModel {
								DelegateComponent {
									ListText {
										text: {
											var message = ""
											if (firmwareVersion.value < 0x506) { // Partial support S&W support
												message = !chargeInProcess
														? //% "Shore power will be used when available and the \"Solar & wind priority\" option will be ignored.\nDo you want to continue?"
														  qsTrId("vebus_device_use_shore_power")
														: returnToNormal
											} else {
												message = !chargeInProcess
														? //% "Shore power will be used to complete a full battery charge for one time.\nAfter the charging process is complete, the system will return to normal operation, prioritizing solar and wind energy.\nDo you want to continue?"
														  qsTrId("ebus_device_use_shore_power_once")
														: returnToNormal
											}
											return message
										}
									}
								}

								DelegateComponent {
									ListButton {
										secondaryText: CommonWords.yes
										onClicked: {
											preferRenewableEnergy.setValue(chargeInProcess ? 1 : 0)
											popTimer.restart()
										}
									}
								}

								DelegateComponent {
									ListButton {
										secondaryText: CommonWords.no
										onClicked: popTimer.restart()
									}
								}
							}
						}
					}
				}
			}
		}

		DelegateComponent {
			ListQuantity {
				dataItem.uid: root.bindPrefix + "/Dc/0/Voltage"
				//% "DC Voltage"
				text: qsTrId("vebus_device_page_dc_voltage")
				unit: VenusOS.Units_Volt_DC
			}
		}

		DelegateComponent {
			ListQuantity {
				dataItem.uid: root.bindPrefix + "/Dc/0/Current"
				//% "DC Current"
				text: qsTrId("vebus_device_page_dc_current")
				unit: VenusOS.Units_Amp
			}
		}

		DelegateComponent {
			preferredVisible: root.isMulti
			ListQuantity {
				dataItem.uid: root.bindPrefix + "/Soc"
				text: CommonWords.state_of_charge
				unit:VenusOS.Units_Percentage
			}
		}

		DelegateComponent {
			preferredVisible: temperatureItem.valid && root.isMulti
			ListTemperature {
				dataItem.uid: root.bindPrefix + "/Dc/0/Temperature"
				text: CommonWords.battery_temperature
			}
		}

		DelegateComponent {
			preferredVisible: root.isMulti
			ListActiveAcInput {
				bindPrefix: root.bindPrefix
			}
		}

		DelegateComponent {
			VeBusAcIODisplay {
				serviceUid: root.bindPrefix
			}
		}

		DelegateComponent {
			id: modeDC
			dataItem: VeQuickItem { uid: root.bindPrefix + "/MicroGrid/Mode" }
			preferredVisible: modeDC.dataItem.valid
			ListNavigation {
				//% "Microgrid parameters"
				text: qsTrId("vebus_device_page_microgrid_parameters")
				onClicked: Global.pageManager.pushPage("/pages/vebusdevice/PageMicrogrid.qml", { "bindPrefix": root.bindPrefix })

				VeQuickItem {
					id: mode
					uid: root.bindPrefix + "/MicroGrid/Mode"
				}
			}
		}

		DelegateComponent {
			ListNavigation {
				//% "Advanced"
				text: qsTrId("vebus_device_page_advanced")
				onClicked: Global.pageManager.pushPage("/pages/vebusdevice/PageVeBusAdvanced.qml",
													   { "bindPrefix": root.bindPrefix,
														   "title": text
													   })
			}
		}

		DelegateComponent {
			ListNavigation {
				text: CommonWords.alarm_status
				onClicked: Global.pageManager.pushPage("/pages/vebusdevice/PageVeBusAlarms.qml",
													   {
														   "bindPrefix": root.bindPrefix,
														   "isMulti": root.isMulti
													   })
			}
		}

		DelegateComponent {
			ListNavigation {
				text: CommonWords.alarm_setup
				onClicked: Global.pageManager.pushPage("/pages/vebusdevice/PageVeBusAlarmSettings.qml",
													   {
														   "title": text,
														   "isMulti": root.isMulti
													   })

			}
		}

		DelegateComponent {
			preferredVisible: bmsMode.valid
			PrimaryListLabel {
				//% "A VE.Bus BMS automatically turns the system off when needed to protect the battery. Controlling the system from the GX device is therefore not possible."
				text: qsTrId("vebus_device_bms_message")
			}
		}

		DelegateComponent {
			preferredVisible: bmsType.value === VenusOS.VeBusDevice_Bms_Type_VeBus && !bmsMode.valid
			PrimaryListLabel {
				//% "A BMS assistant is installed configured for a VE.Bus BMS, but the VE.Bus BMS is not found!"
				text: qsTrId("vebus_device_bms_not_found")
			}
		}

		DelegateComponent {
			preferredVisible: bmsExpected.value === 1
			ListNavigation {
				//% "VE.Bus BMS"
				text: qsTrId("vebus_device_vebus_bms")
				onClicked: Global.pageManager.pushPage("/pages/vebusdevice/PageVeBusBms.qml", {
														   "title": text,
														   "bindPrefix": root.bindPrefix
													   })
			}
		}

		DelegateComponent {
			ListNavigation {
				text: CommonWords.ac_sensors
				showAccessLevel: VenusOS.User_AccessType_Service
				onClicked: Global.pageManager.pushPage("/pages/vebusdevice/PageAcSensors.qml", {
														   "title": text,
														   "bindPrefix": root.bindPrefix + "/AcSensor"
													   }
													   )
			}
		}

		DelegateComponent {
			ListNavigation {
				text: CommonWords.debug
				showAccessLevel: VenusOS.User_AccessType_Service
				onClicked: Global.pageManager.pushPage("/pages/vebusdevice/PageVeBusDebug.qml", {
														   "title": text,
														   "bindPrefix": root.bindPrefix
													   }
													   )
			}
		}
	}

	extraDeviceInfo: SettingsColumn {
		width: parent?.width ?? 0
		preferredVisible: deviceInfoModel.count > 0

		Repeater {
			model: VeBusDeviceInfoModel { id: deviceInfoModel }

			ListText {
				text: displayText
				dataItem.uid: root.bindPrefix + pathSuffix
			}
		}

		ListNavigation {
			//% "Serial numbers"
			text: qsTrId("vebus_device_serial_numbers")
			onClicked: {
				Global.pageManager.pushPage("/pages/vebusdevice/PageVeBusSerialNumbers.qml", {
					//% "Serial numbers"
					"title": qsTrId("vebus_device_serial_numbers"),
					"bindPrefix": root.bindPrefix
				})
			}
		}
	}
}
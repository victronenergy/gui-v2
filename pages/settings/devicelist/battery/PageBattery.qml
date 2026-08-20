/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	Provides a list of settings for a battery device.
*/
DevicePage {
	id: root

	required property string bindPrefix
	readonly property bool isFiamm48TL: productId.value === ProductInfo.ProductId_Battery_Fiamm48TL
	readonly property bool isParallelBms: nrOfBmsesDC.dataItem.valid

	VeQuickItem {
		id: bussVoltageItem
		uid: root.bindPrefix + "/BussVoltage"
	}
	VeQuickItem {
		id: consumedAmphoursItem
		uid: root.bindPrefix + "/ConsumedAmphours"
	}
	VeQuickItem {
		id: midVoltageDeviationItem
		uid: root.bindPrefix + "/Dc/0/MidVoltageDeviation"
	}
	VeQuickItem {
		id: busVoltageItem
		uid: root.bindPrefix + "/BusVoltage"
	}
	VeQuickItem {
		id: voltageItem
		uid: root.bindPrefix + "/Dc/1/Voltage"
	}
	VeQuickItem {
		id: airTemperatureItem
		uid: root.bindPrefix + "/AirTemperature"
	}
	VeQuickItem {
		id: temperatureItem
		uid: root.bindPrefix + "/Dc/0/Temperature"
	}
	VeQuickItem {
		id: sohItem
		uid: root.bindPrefix + "/Soh"
	}
	VeQuickItem {
		id: errorCodeItem
		uid: root.bindPrefix + "/ErrorCode"
	}
	VeQuickItem {
		id: errorCommItem
		uid: root.bindPrefix + "/Errors/SmartLithium/Communication"
	}
	VeQuickItem {
		id: errorVoltageItem
		uid: root.bindPrefix + "/Errors/SmartLithium/Voltage"
	}
	VeQuickItem {
		id: errorNrOfBatteriesItem
		uid: root.bindPrefix + "/Errors/SmartLithium/NrOfBatteries"
	}
	VeQuickItem {
		id: errorInvalidConfigItem
		uid: root.bindPrefix + "/Errors/SmartLithium/InvalidConfiguration"
	}
	VeQuickItem {
		id: stateItem
		uid: root.bindPrefix + "/State"
	}
	VeQuickItem {
		id: modeItem
		uid: root.bindPrefix + "/Mode"
	}
	VeQuickItem {
		id: cvlItem
		uid: root.bindPrefix + "/Info/MaxChargeVoltage"
	}
	VeQuickItem {
		id: cclItem
		uid: root.bindPrefix + "/Info/MaxChargeCurrent"
	}
	VeQuickItem {
		id: dclItem
		uid: root.bindPrefix + "/Info/MaxDischargeCurrent"
	}
	VeQuickItem {
		id: midVoltage
		uid: root.bindPrefix + "/Dc/0/MidVoltage"
	}
	VeQuickItem {
		id: batteryVoltageItem
		uid: root.bindPrefix + "/Dc/0/Voltage"
	}
	VeQuickItem {
		id: productId
		uid: root.bindPrefix + "/ProductId"
	}
	VeQuickItem {
		id: hasSettings
		uid: root.bindPrefix + "/Settings/HasSettings"
	}

	serviceUid: bindPrefix
	settingsModel: DelegateComponentModel {
		DelegateComponent {
			preferredVisible: modeItem.valid
			ListRadioButtonGroup {
				text: CommonWords.switch_mode
				dataItem.uid: root.bindPrefix + "/Mode"
				optionModel: [
					{ display: CommonWords.off, value: 4, readOnly: true },
					{ display: CommonWords.standby, value: 0xfc },
					{ display: CommonWords.on, value: 3 },
				]
			}
		}

		DelegateComponent {
			preferredVisible: stateItem.valid
			ListText {
				text: CommonWords.state
				dataItem.uid: root.bindPrefix + "/State"
				secondaryText: {
					if (!dataItem.valid) {
						return ""
					}
					if (dataItem.value >= 0 && dataItem.value <= 8) {
						//% "Initializing"
						return qsTrId("devicelist_battery_initializing")
					}
					switch (dataItem.value) {
					case VenusOS.Battery_State_Running:
						return CommonWords.running_status
					case VenusOS.Battery_State_Error:
						return CommonWords.error
					// case Battery_State_Unknown is omitted
					case VenusOS.Battery_State_Shutdown:
						//: Status is 'Shutdown'
						//% "Shutdown"
						return qsTrId("devicelist_battery_shutdown")
					case VenusOS.Battery_State_Updating:
						//: Status is 'Updating'
						//% "Updating"
						return qsTrId("devicelist_battery_updating")
					case VenusOS.Battery_State_Standby:
						return CommonWords.standby
					case VenusOS.Battery_State_GoingToRun:
						//: Status is 'Going to run'
						//% "Going to run"
						return qsTrId("devicelist_battery_going_to_run")
					case VenusOS.Battery_State_Precharging:
						//: Status is 'Pre-Charging'
						//% "Pre-Charging"
						return qsTrId("devicelist_battery_pre_charging")
					case VenusOS.Battery_State_ContactorCheck:
						//: Status is 'Contactor check'
						//% "Contactor check"
						return qsTrId("devicelist_battery_contactor_check")
					case VenusOS.Battery_State_Pending:
						return CommonWords.pending
					default:
						return ""
					}
				}
			}
		}

		DelegateComponent {
			preferredVisible: errorCodeItem.valid
			ListText {
				text: CommonWords.error
				dataItem.uid: root.bindPrefix + "/ErrorCode"
				secondaryText: BmsError.description(dataItem.value)
			}
		}

		DelegateComponent {
			preferredVisible: errorCommItem.valid || errorVoltageItem.valid || errorNrOfBatteriesItem.valid || errorInvalidConfigItem.valid
			ListText {
				//% "Battery bank error"
				text: qsTrId("battery_bank_error")
				dataItem.uid: root.bindPrefix + "/ErrorCode"
				secondaryText: {
					if (errorCommItem.valid && errorCommItem.value) {
						//% "Communication error"
						return qsTrId("battery_bank_error_communication")
					} else if (errorVoltageItem.valid && errorVoltageItem.value) {
						//% "Battery voltage not supported"
						return qsTrId("battery_bank_error_voltage_not_supported")
					} else if (errorNrOfBatteriesItem.valid && errorNrOfBatteriesItem.value) {
						//% "Incorrect number of batteries"
						return qsTrId("battery_bank_error_incorrect_number_of_batteries")
					} else if (errorInvalidConfigItem.valid && errorInvalidConfigItem.value) {
						//% "Invalid battery configuration"
						return qsTrId("battery_bank_error_invalid_configuration")
					} else {
						return CommonWords.none_errors
					}
				}
			}
		}

		DelegateComponent {
			ListQuantityGroup {
				text: CommonWords.battery
				model: QuantityObjectModel {
					QuantityObject { object: batteryVoltageItem; unit: VenusOS.Units_Volt_DC }
					QuantityObject { object: batteryCurrent; unit: VenusOS.Units_Amp }
					QuantityObject { object: batteryPower; unit: VenusOS.Units_Watt }
				}

				VeQuickItem {
					id: batteryCurrent
					uid: root.bindPrefix + "/Dc/0/Current"
				}

				VeQuickItem {
					id: batteryPower
					uid: root.bindPrefix + "/Dc/0/Power"
				}
			}
		}

		DelegateComponent {
			preferredVisible: root.isParallelBms
			ListQuantity {
				//% "Total Capacity"
				text: qsTrId("devicelist_battery_total_capacity")
				dataItem.uid: root.bindPrefix + "/Capacity"
				unit: VenusOS.Units_AmpHour
			}
		}

		DelegateComponent {
			id: batteryStateDC
			dataItem: VeQuickItem { uid: root.bindPrefix + "/State" }
			preferredVisible: !root.isParallelBms && batteryStateDC.dataItem.value === VenusOS.Battery_State_Pending
			ListQuantity {
				readonly property VeQuickItem _n2kDeviceInstance: VeQuickItem {
					uid: root.bindPrefix + "/N2kDeviceInstance"
				}

				//% "System voltage"
				text: qsTrId("devicelist_battery_system_voltage")
				dataItem.uid: BackendConnection.serviceUidFromName("com.victronenergy.battery.lynxparallel" + _n2kDeviceInstance.value, _n2kDeviceInstance.value) + "/Dc/0/Voltage"
				unit: VenusOS.Units_Volt_DC

				VeQuickItem {
					id: batteryState
					uid: root.bindPrefix + "/State"
				}
			}
		}

		DelegateComponent {
			id: nrOfBmsesDC
			dataItem: VeQuickItem { uid: root.bindPrefix + "/NumberOfBmses" }
			preferredVisible: root.isParallelBms
			ListText {
				id: nrOfBmses
				//% "Number of BMSes"
				text: qsTrId("devicelist_battery_number_of_bmses")
				dataItem.uid: root.bindPrefix + "/NumberOfBmses"
			}
		}

		DelegateComponent {
			ListQuantity {
				text: CommonWords.state_of_charge
				dataItem.uid: root.bindPrefix + "/Soc"
				unit: VenusOS.Units_Percentage
			}
		}

		DelegateComponent {
			preferredVisible: sohItem.valid
			ListQuantity {
				//% "State of health"
				text: qsTrId("battery_state_of_health")
				dataItem.uid: root.bindPrefix + "/Soh"
				unit: VenusOS.Units_Percentage
			}
		}

		DelegateComponent {
			preferredVisible: temperatureItem.valid
			ListTemperature {
				text: CommonWords.battery_temperature
				dataItem.uid: root.bindPrefix + "/Dc/0/Temperature"
				unit: Global.systemSettings.temperatureUnit
			}
		}

		DelegateComponent {
			preferredVisible: airTemperatureItem.valid
			ListTemperature {
				//% "Air temperature"
				text: qsTrId("battery_air_temp")
				dataItem.uid: root.bindPrefix + "/AirTemperature"
			}
		}

		DelegateComponent {
			preferredVisible: voltageItem.valid
			ListQuantity {
				//% "Starter voltage"
				text: qsTrId("battery_starter_voltage")
				dataItem.uid: root.bindPrefix + "/Dc/1/Voltage"
				unit: VenusOS.Units_Volt_DC
			}
		}

		DelegateComponent {
			preferredVisible: busVoltageItem.valid
			ListQuantity {
				//% "Bus voltage"
				text: qsTrId("battery_bus_voltage")
				dataItem.uid: root.bindPrefix + "/BusVoltage"
				unit: VenusOS.Units_Volt_DC
			}
		}

		DelegateComponent {
			preferredVisible: midVoltage.valid
			ListQuantity {
				//% "Top section voltage"
				text: qsTrId("battery_top_section_voltage")
				value: midVoltage.valid && batteryVoltageItem.valid ? batteryVoltageItem.value - midVoltage.value : NaN
				unit: VenusOS.Units_Volt_DC
			}
		}

		DelegateComponent {
			preferredVisible: midVoltage.valid
			ListQuantity {
				//% "Bottom section voltage"
				text: qsTrId("battery_bottom_section_voltage")
				value: midVoltage.value === undefined ? NaN : midVoltage.value
				unit: VenusOS.Units_Volt_DC
			}
		}

		DelegateComponent {
			preferredVisible: midVoltageDeviationItem.valid
			ListQuantity {
				//% "Mid-point deviation"
				text: qsTrId("battery_mid_point_deviation")
				dataItem.uid: root.bindPrefix + "/Dc/0/MidVoltageDeviation"
				unit: VenusOS.Units_Percentage
			}
		}

		DelegateComponent {
			preferredVisible: consumedAmphoursItem.valid
			ListQuantity {
				//% "Consumed AmpHours"
				text: qsTrId("battery_consumed_amphours")
				dataItem.uid: root.bindPrefix + "/ConsumedAmphours"
				unit: VenusOS.Units_AmpHour
			}
		}

		DelegateComponent {
			preferredVisible: bussVoltageItem.valid
			ListQuantity {
				//% "Bus voltage"
				text: qsTrId("battery_buss_voltage")
				dataItem.uid: root.bindPrefix + "/BussVoltage"
				unit: VenusOS.Units_Volt_DC
			}
		}

		DelegateComponent {
			dataItem: VeQuickItem { uid: root.bindPrefix + "/TimeToGo" }
			preferredVisible: dataItem.seen
			ListText {
				//% "Time-to-go"
				text: qsTrId("battery_time_to_go")
				dataItem.uid: root.bindPrefix + "/TimeToGo"
				secondaryText: Utils.secondsToString(dataItem.value)
			}
		}

		DelegateComponent {
			ListRelayState {
				dataItem.uid: root.bindPrefix + "/Relay/0/State"
			}
		}

		DelegateComponent {
			ListAlarmState {
				dataItem.uid: root.bindPrefix + "/Alarms/Alarm"
			}
		}

		DelegateComponent {
			id: batteryRequestIdDC
			dataItem: VeQuickItem { uid: root.bindPrefix + "/Battery/Request/Id" }
			preferredVisible: batteryRequestIdDC.dataItem.valid
			ListNavigation {
				//% "Individual Battery Info"
				text: qsTrId("battery_individual_info")
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/devicelist/battery/PageLynxIonBatteryInfo.qml",
							{ "title": text, "bindPrefix": root.bindPrefix })
				}

				VeQuickItem {
					id: batteryRequestId
					uid: root.bindPrefix + "/Battery/Request/Id"
				}
			}
		}

		DelegateComponent {
			preferredVisible: batteryDetails.hasAllowedItem
			ListNavigation {
				//% "Details"
				text: qsTrId("battery_details")
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/devicelist/battery/PageBatteryDetails.qml",
							{ "title": text, "bindPrefix": root.bindPrefix, "details": batteryDetails })
				}
			}
		}

		DelegateComponent {
			preferredVisible: !root.isParallelBms
			ListNavigation {
				text: CommonWords.alarms
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/devicelist/battery/PageBatteryAlarms.qml",
							{ "title": text, "bindPrefix": root.bindPrefix })
				}
			}
		}

		DelegateComponent {
			preferredVisible: moduleAlarmModel.rowCount > 0
			ListNavigation {
				//% "Module level alarms"
				text: qsTrId("battery_module_level_alarms")
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/devicelist/battery/PageBatteryModuleAlarms.qml",
							{ "title": text, "bindPrefix": root.bindPrefix, alarmModel: moduleAlarmModel })
				}
			}
		}

		DelegateComponent {
			preferredVisible: !isFiamm48TL && batteryHistory.hasAllowedItem
			ListNavigation {
				text: CommonWords.history
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/devicelist/battery/PageBatteryHistory.qml",
							{ "title": text, "bindPrefix": root.bindPrefix, "history": batteryHistory })
				}
			}
		}

		DelegateComponent {
			preferredVisible: hasSettings.value === 1
			ListNavigation {
				text: CommonWords.settings
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/devicelist/battery/PageBatterySettings.qml",
							{ "title": text, "bindPrefix": root.bindPrefix })
				}
			}
		}

		DelegateComponent {
			id: lastErrorDC
			dataItem: VeQuickItem { uid: root.bindPrefix + "/Diagnostics/LastErrors/1/Error" }
			preferredVisible: lastErrorDC.dataItem.valid
			ListNavigation {
				id: lynxIonDiagnostics

				//% "Diagnostics"
				text: qsTrId("battery_settings_diagnostics")
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/devicelist/battery/PageLynxIonDiagnostics.qml",
							{ "title": text, "bindPrefix": root.bindPrefix })
				}

				VeQuickItem {
					id: lastError
					uid: root.bindPrefix + "/Diagnostics/LastErrors/1/Error"
				}
			}
		}

		DelegateComponent {
			preferredVisible: isFiamm48TL
			ListNavigation {
				//% "Diagnostics"
				text: qsTrId("battery_settings_diagnostics")

				onClicked: {
					Global.pageManager.pushPage("/pages/settings/devicelist/battery/Page48TlDiagnostics.qml",
							{ "title": text, "bindPrefix": root.bindPrefix })
				}
			}
		}

		DelegateComponent {
			id: nrOfDistributorsDC
			dataItem: VeQuickItem { uid: root.bindPrefix + "/NrOfDistributors" }
			preferredVisible: nrOfDistributorsDC.dataItem.valid && nrOfDistributorsDC.dataItem.value > 0
			ListNavigation {
				//% "Fuses"
				text: qsTrId("battery_settings_fuses")

				onClicked: {
					Global.pageManager.pushPage("/pages/settings/devicelist/battery/PageLynxDistributorList.qml",
							{ "title": text, "bindPrefix": root.bindPrefix })
				}

				VeQuickItem {
					id: nrOfDistributors
					uid: root.bindPrefix + "/NrOfDistributors"
				}
			}
		}

		DelegateComponent {
			id: allowToChargeDC
			dataItem: VeQuickItem { uid: root.bindPrefix + "/Io/AllowToCharge" }
			preferredVisible: allowToChargeDC.dataItem.valid
			ListNavigation {
				//% "IO"
				text: qsTrId("battery_settings_io")
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/devicelist/battery/PageLynxIonIo.qml",
							{ "title": text, "bindPrefix": root.bindPrefix })
				}

				VeQuickItem {
					id: allowToCharge
					uid: root.bindPrefix + "/Io/AllowToCharge"
				}
			}
		}

		DelegateComponent {
			id: nrOfBatteriesDC
			dataItem: VeQuickItem { uid: root.bindPrefix +"/System/NrOfBatteries" }
			preferredVisible: nrOfBatteriesDC.dataItem.valid
			ListNavigation {
				//% "System"
				text: qsTrId("battery_settings_system")
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/devicelist/battery/PageLynxIonSystem.qml",
							{ "title": text, "bindPrefix": root.bindPrefix })
				}

				VeQuickItem {
					id: nrOfBatteries
					uid: root.bindPrefix +"/System/NrOfBatteries"
				}
			}
		}

		DelegateComponent {
			preferredVisible: cvlItem.valid || cclItem.valid || dclItem.valid
			ListNavigation {
				//% "Parameters"
				text: qsTrId("battery_settings_parameters")
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/devicelist/battery/PageBatteryParameters.qml",
							{ "title": text, "bindPrefix": root.bindPrefix })
				}

				VeQuickItem {
					id: cvl
					uid: root.bindPrefix + "/Info/MaxChargeVoltage"
				}

				VeQuickItem {
					id: ccl
					uid: root.bindPrefix + "/Info/MaxChargeCurrent"
				}

				VeQuickItem {
					id: dcl
					uid: root.bindPrefix + "/Info/MaxDischargeCurrent"
				}
			}
		}

		DelegateComponent {
			id: redetectDC
			dataItem: VeQuickItem { uid: root.bindPrefix + "/Redetect" }
			preferredVisible: redetectDC.dataItem.valid
			ListButton {
				//% "Redetect Battery"
				text: qsTrId("battery_redetect_battery")
				secondaryText: CommonWords.redetect
				interactive: redetect.value === 0
				writeAccessLevel: VenusOS.User_AccessType_User
				onClicked: {
					redetect.setValue(1)
					//% "Redetecting the battery may take up time 60 seconds. Meanwhile the name of the battery may be incorrect."
					Global.showToastNotification(VenusOS.Notification_Info, qsTrId("battery_redetecting_the_battery_note"), 10000)
				}

				VeQuickItem {
					id: redetect
					uid: root.bindPrefix + "/Redetect"
				}
			}
		}
	}
	BatteryDetails {
		id: batteryDetails
		bindPrefix: root.bindPrefix
	}
	BatteryHistory {
		id: batteryHistory
		bindPrefix: root.bindPrefix
	}
	VeQItemSortTableModel {
		id: moduleAlarmModel

		filterRegExp: "\/Module[0-9]\/Id$"
		filterFlags: VeQItemSortTableModel.FilterExcludesValue | VeQItemSortTableModel.FilterInvalid
		filterExcludedValue: ""
		model: VeQItemTableModel {
			uids: [root.bindPrefix + "/Diagnostics"]
		}
	}
}
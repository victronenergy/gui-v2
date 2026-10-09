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

	readonly property bool isFiamm48TL: productId.value === ProductInfo.ProductId_Battery_Fiamm48TL
	readonly property bool isParallelBms: nrOfBmses.dataItem.valid

	settingsModel: VisibleItemModel {
		ListRadioButtonGroup {
			text: CommonWords.switch_mode
			dataItem.uid: root.serviceUid + "/Mode"
			preferredVisible: dataItem.valid
			optionModel: [
				{ display: CommonWords.off, value: 4, readOnly: true },
				{ display: CommonWords.standby, value: 0xfc },
				{ display: CommonWords.on, value: 3 },
			]
		}

		ListText {
			text: CommonWords.state
			dataItem.uid: root.serviceUid + "/State"
			preferredVisible: dataItem.valid
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
					//% "Pre-charging"
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

		ListText {
			text: CommonWords.error
			dataItem.uid: root.serviceUid + "/ErrorCode"
			preferredVisible: dataItem.valid
			secondaryText: BmsError.description(dataItem.value)
		}

		ListText {
			//% "Battery bank error"
			text: qsTrId("battery_bank_error")
			dataItem.uid: root.serviceUid + "/ErrorCode"
			preferredVisible: errorComm.valid || errorVoltage.valid || errorNrOfBatteries.valid || errorInvalidConfig.valid
			secondaryText: {
				if (errorComm.valid && errorComm.value) {
					//% "Communication error"
					return qsTrId("battery_bank_error_communication")
				} else if (errorVoltage.valid && errorVoltage.value) {
					//% "Battery voltage not supported"
					return qsTrId("battery_bank_error_voltage_not_supported")
				} else if (errorNrOfBatteries.valid && errorNrOfBatteries.value) {
					//% "Incorrect number of batteries"
					return qsTrId("battery_bank_error_incorrect_number_of_batteries")
				} else if (errorInvalidConfig.valid && errorInvalidConfig.value) {
					//% "Invalid battery configuration"
					return qsTrId("battery_bank_error_invalid_configuration")
				} else {
					return CommonWords.none_errors
				}
			}

			VeQuickItem { id: errorComm; uid: root.serviceUid + "/Errors/SmartLithium/Communication" }
			VeQuickItem { id: errorVoltage; uid: root.serviceUid + "/Errors/SmartLithium/Voltage" }
			VeQuickItem { id: errorNrOfBatteries; uid: root.serviceUid + "/Errors/SmartLithium/NrOfBatteries" }
			VeQuickItem { id: errorInvalidConfig; uid: root.serviceUid + "/Errors/SmartLithium/InvalidConfiguration" }
		}

		ListQuantityGroup {
			text: CommonWords.battery
			model: QuantityObjectModel {
				QuantityObject { object: batteryVoltage; unit: VenusOS.Units_Volt_DC }
				QuantityObject { object: batteryCurrent; unit: VenusOS.Units_Amp }
				QuantityObject { object: batteryPower; unit: VenusOS.Units_Watt }
			}

			VeQuickItem {
				id: batteryVoltage
				uid: root.serviceUid + "/Dc/0/Voltage"
			}

			VeQuickItem {
				id: batteryCurrent
				uid: root.serviceUid + "/Dc/0/Current"
			}

			VeQuickItem {
				id: batteryPower
				uid: root.serviceUid + "/Dc/0/Power"
			}
		}

		ListQuantity {
			//% "Total capacity"
			text: qsTrId("devicelist_battery_total_capacity")
			dataItem.uid: root.serviceUid + "/Capacity"
			preferredVisible: root.isParallelBms
			unit: VenusOS.Units_AmpHour
		}

		ListQuantity {
			readonly property VeQuickItem _n2kDeviceInstance: VeQuickItem {
				uid: root.serviceUid + "/N2kDeviceInstance"
			}

			//% "System voltage"
			text: qsTrId("devicelist_battery_system_voltage")
			dataItem.uid: BackendConnection.serviceUidFromName("com.victronenergy.battery.lynxparallel" + _n2kDeviceInstance.value, _n2kDeviceInstance.value) + "/Dc/0/Voltage"
			preferredVisible: !root.isParallelBms && batteryState.value === VenusOS.Battery_State_Pending
			unit: VenusOS.Units_Volt_DC

			VeQuickItem {
				id: batteryState
				uid: root.serviceUid + "/State"
			}
		}

		ListText {
			id: nrOfBmses
			//% "Number of BMSes"
			text: qsTrId("devicelist_battery_number_of_bmses")
			dataItem.uid: root.serviceUid + "/NumberOfBmses"
			preferredVisible: root.isParallelBms
		}

		ListQuantity {
			text: CommonWords.state_of_charge
			dataItem.uid: root.serviceUid + "/Soc"
			unit: VenusOS.Units_Percentage
		}

		ListQuantity {
			//% "State of health"
			text: qsTrId("battery_state_of_health")
			dataItem.uid: root.serviceUid + "/Soh"
			preferredVisible: dataItem.valid
			unit: VenusOS.Units_Percentage
		}

		ListTemperature {
			text: CommonWords.battery_temperature
			dataItem.uid: root.serviceUid + "/Dc/0/Temperature"
			preferredVisible: dataItem.valid
			unit: Global.systemSettings.temperatureUnit
		}

		ListTemperature {
			//% "Air temperature"
			text: qsTrId("battery_air_temp")
			dataItem.uid: root.serviceUid + "/AirTemperature"
			preferredVisible: dataItem.valid
		}

		ListQuantity {
			//% "Starter voltage"
			text: qsTrId("battery_starter_voltage")
			dataItem.uid: root.serviceUid + "/Dc/1/Voltage"
			preferredVisible: dataItem.valid
			unit: VenusOS.Units_Volt_DC
		}

		ListQuantity {
			//% "Bus voltage"
			text: qsTrId("battery_bus_voltage")
			dataItem.uid: root.serviceUid + "/BusVoltage"
			preferredVisible: dataItem.valid
			unit: VenusOS.Units_Volt_DC
		}

		ListQuantity {
			//% "Top section voltage"
			text: qsTrId("battery_top_section_voltage")
			preferredVisible: midVoltage.valid
			value: midVoltage.valid && batteryVoltage.valid ? batteryVoltage.value - midVoltage.value : NaN
			unit: VenusOS.Units_Volt_DC
		}

		ListQuantity {
			//% "Bottom section voltage"
			text: qsTrId("battery_bottom_section_voltage")
			value: midVoltage.value === undefined ? NaN : midVoltage.value
			preferredVisible: midVoltage.valid
			unit: VenusOS.Units_Volt_DC
		}

		ListQuantity {
			//% "Mid-point deviation"
			text: qsTrId("battery_mid_point_deviation")
			dataItem.uid: root.serviceUid + "/Dc/0/MidVoltageDeviation"
			preferredVisible: dataItem.valid
			unit: VenusOS.Units_Percentage
		}

		ListQuantity {
			//% "Consumed AmpHours"
			text: qsTrId("battery_consumed_amphours")
			dataItem.uid: root.serviceUid + "/ConsumedAmphours"
			preferredVisible: dataItem.valid
			unit: VenusOS.Units_AmpHour
		}

		ListQuantity {
			//% "Bus voltage"
			text: qsTrId("battery_buss_voltage")
			dataItem.uid: root.serviceUid + "/BussVoltage"
			preferredVisible: dataItem.valid
			unit: VenusOS.Units_Volt_DC
		}

		ListText {
			//% "Time-to-go"
			text: qsTrId("battery_time_to_go")
			dataItem.uid: root.serviceUid + "/TimeToGo"
			preferredVisible: dataItem.seen
			secondaryText: Utils.secondsToString(dataItem.value)
		}

		ListRelayState {
			dataItem.uid: root.serviceUid + "/Relay/0/State"
		}

		ListAlarmState {
			dataItem.uid: root.serviceUid + "/Alarms/Alarm"
		}

		ListNavigation {
			//% "Individual battery info"
			text: qsTrId("battery_individual_info")
			preferredVisible: batteryRequestId.valid
			onClicked: {
				Global.pageManager.pushPage("/pages/settings/devicelist/battery/PageLynxIonBatteryInfo.qml",
						{ "title": text, "bindPrefix": root.serviceUid })
			}

			VeQuickItem {
				id: batteryRequestId
				uid: root.serviceUid + "/Battery/Request/Id"
			}
		}

		ListNavigation {
			//% "Details"
			text: qsTrId("battery_details")
			preferredVisible: batteryDetails.hasAllowedItem
			onClicked: {
				Global.pageManager.pushPage("/pages/settings/devicelist/battery/PageBatteryDetails.qml",
						{ "title": text, "bindPrefix": root.serviceUid, "details": batteryDetails })
			}

			BatteryDetails {
				id: batteryDetails
				bindPrefix: root.serviceUid
			}
		}

		ListNavigation {
			text: CommonWords.alarms
			preferredVisible: !root.isParallelBms
			onClicked: {
				Global.pageManager.pushPage("/pages/settings/devicelist/battery/PageBatteryAlarms.qml",
						{ "title": text, "bindPrefix": root.serviceUid })
			}
		}

		ListNavigation {
			//% "Module level alarms"
			text: qsTrId("battery_module_level_alarms")
			preferredVisible: moduleAlarmModel.rowCount > 0
			onClicked: {
				Global.pageManager.pushPage("/pages/settings/devicelist/battery/PageBatteryModuleAlarms.qml",
						{ "title": text, "bindPrefix": root.serviceUid, alarmModel: moduleAlarmModel })
			}
		}

		ListNavigation {
			text: CommonWords.history
			preferredVisible: !isFiamm48TL && batteryHistory.hasAllowedItem
			onClicked: {
				Global.pageManager.pushPage("/pages/settings/devicelist/battery/PageBatteryHistory.qml",
						{ "title": text, "bindPrefix": root.serviceUid, "history": batteryHistory })
			}

			BatteryHistory {
				id: batteryHistory
				bindPrefix: root.serviceUid
			}
		}

		ListNavigation {
			text: CommonWords.settings
			preferredVisible: hasSettings.value === 1
			onClicked: {
				Global.pageManager.pushPage("/pages/settings/devicelist/battery/PageBatterySettings.qml",
						{ "title": text, "bindPrefix": root.serviceUid })
			}
		}

		ListNavigation {
			id: lynxIonDiagnostics

			//% "Diagnostics"
			text: qsTrId("battery_settings_diagnostics")
			preferredVisible: lastError.valid
			onClicked: {
				Global.pageManager.pushPage("/pages/settings/devicelist/battery/PageLynxIonDiagnostics.qml",
						{ "title": text, "bindPrefix": root.serviceUid })
			}

			VeQuickItem {
				id: lastError
				uid: root.serviceUid + "/Diagnostics/LastErrors/1/Error"
			}
		}

		ListNavigation {
			text: lynxIonDiagnostics.text
			preferredVisible: isFiamm48TL

			onClicked: {
				Global.pageManager.pushPage("/pages/settings/devicelist/battery/Page48TlDiagnostics.qml",
						{ "title": text, "bindPrefix": root.serviceUid })
			}
		}

		ListNavigation {
			//% "Fuses"
			text: qsTrId("battery_settings_fuses")
			preferredVisible: nrOfDistributors.valid && nrOfDistributors.value > 0

			onClicked: {
				Global.pageManager.pushPage("/pages/settings/devicelist/battery/PageLynxDistributorList.qml",
						{ "title": text, "bindPrefix": root.serviceUid })
			}

			VeQuickItem {
				id: nrOfDistributors
				uid: root.serviceUid + "/NrOfDistributors"
			}
		}

		ListNavigation {
			//% "IO"
			text: qsTrId("battery_settings_io")
			preferredVisible: allowToCharge.valid
			onClicked: {
				Global.pageManager.pushPage("/pages/settings/devicelist/battery/PageLynxIonIo.qml",
						{ "title": text, "bindPrefix": root.serviceUid })
			}

			VeQuickItem {
				id: allowToCharge
				uid: root.serviceUid + "/Io/AllowToCharge"
			}
		}

		ListNavigation {
			//% "System"
			text: qsTrId("battery_settings_system")
			preferredVisible: nrOfBatteries.valid
			onClicked: {
				Global.pageManager.pushPage("/pages/settings/devicelist/battery/PageLynxIonSystem.qml",
						{ "title": text, "bindPrefix": root.serviceUid })
			}

			VeQuickItem {
				id: nrOfBatteries
				uid: root.serviceUid +"/System/NrOfBatteries"
			}
		}

		ListNavigation {
			//% "Parameters"
			text: qsTrId("battery_settings_parameters")
			preferredVisible: cvl.valid || ccl.valid || dcl.valid
			onClicked: {
				Global.pageManager.pushPage("/pages/settings/devicelist/battery/PageBatteryParameters.qml",
						{ "title": text, "bindPrefix": root.serviceUid })
			}

			VeQuickItem {
				id: cvl
				uid: root.serviceUid + "/Info/MaxChargeVoltage"
			}

			VeQuickItem {
				id: ccl
				uid: root.serviceUid + "/Info/MaxChargeCurrent"
			}

			VeQuickItem {
				id: dcl
				uid: root.serviceUid + "/Info/MaxDischargeCurrent"
			}
		}

		ListButton {
			//% "Redetect battery"
			text: qsTrId("battery_redetect_battery")
			secondaryText: CommonWords.redetect
			interactive: redetect.value === 0
			preferredVisible: redetect.valid
			writeAccessLevel: VenusOS.User_AccessType_User
			onClicked: {
				redetect.setValue(1)
				//% "Redetecting the battery may take up time 60 seconds. Meanwhile the name of the battery may be incorrect."
				Global.showToastNotification(VenusOS.Notification_Info, qsTrId("battery_redetecting_the_battery_note"), 10000)
			}

			VeQuickItem {
				id: redetect
				uid: root.serviceUid + "/Redetect"
			}
		}
	}

	VeQuickItem {
		id: midVoltage
		uid: root.serviceUid + "/Dc/0/MidVoltage"
	}

	VeQuickItem {
		id: productId
		uid: root.serviceUid + "/ProductId"
	}

	VeQuickItem {
		id: hasSettings
		uid: root.serviceUid + "/Settings/HasSettings"
	}

	VeQItemSortTableModel {
		id: moduleAlarmModel

		filterRegExp: "\/Module[0-9]\/Id$"
		filterFlags: VeQItemSortTableModel.FilterExcludesValue | VeQItemSortTableModel.FilterInvalid
		filterExcludedValue: ""
		model: VeQItemTableModel {
			uids: [root.serviceUid + "/Diagnostics"]
		}
	}
}

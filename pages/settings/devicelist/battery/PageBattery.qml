/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil
import "/components/Utils.js" as Utils

Page {
	id: root

	property var battery

	readonly property bool isFiamm48TL: productId.value === 0xB012

	title: battery.name

	GradientListView {
		model: ObjectModel {
			ListRadioButtonGroup {
				//: Change the battery mode
				//% "Switch"
				text: qsTrId("battery_switch")
				dataSource: root.battery.serviceUid + "/Mode"
				visible: defaultVisible && dataValid
				optionModel: [
					{ display: CommonWords.off, value: 4, readOnly: true },
					{ display: CommonWords.standby, value: 0xfc },
					{ display: CommonWords.on, value: 3 },
				]
			}

			ListTextItem {
				text: CommonWords.state
				dataSource: root.battery.serviceUid + "/State"
				visible: defaultVisible && dataValid
				secondaryText: {
					if (!dataValid) {
						return ""
					}
					if (dataValue >= 0 && dataValue <= 8) {
						//% "Initializing"
						return qsTrId("devicelist_battery_initializing")
					}
					switch (dataValue) {
					case 9:
						return CommonWords.running_status
					case 10:
						return CommonWords.error
					// case 11 (Unknown) is omitted
					case 12:
						//: Status is 'Shutdown'
						//% "Shutdown"
						return qsTrId("devicelist_battery_shutdown")
					case 13:
						//: Status is 'Updating'
						//% "Updating"
						return qsTrId("devicelist_battery_updating")
					case 14:
						return CommonWords.standby
					case 15:
						//: Status is 'Going to run'
						//% "Going to run"
						return qsTrId("devicelist_battery_going_to_run")
					case 16:
						//: Status is 'Pre-Charging'
						//% "Pre-Charging"
						return qsTrId("devicelist_battery_pre_charging")
					case 17:
						//: Status is 'Contactor check'
						//% "Contactor check"
						return qsTrId("devicelist_battery_contactor_check")
					default:
						return ""
					}
				}
			}

			// TODO this should translate the error code into a BMS error, when the error can be
			// converted into a readable string via veutil. See issue #302
			ListTextItem {
				text: CommonWords.error
				dataSource: root.battery.serviceUid + "/ErrorCode"
				visible: defaultVisible && dataValid
			}

			ListQuantityGroup {
				text: CommonWords.battery
				textModel: [
					{ value: root.battery.voltage, unit: VenusOS.Units_Volt },
					{ value: root.battery.current, unit: VenusOS.Units_Amp },
					{ value: root.battery.power, unit: VenusOS.Units_Watt }
				]
			}

			ListQuantityItem {
				text: CommonWords.state_of_charge
				value: root.battery.stateOfCharge
				unit: VenusOS.Units_Percentage
			}

			ListQuantityItem {
				//% "State of health"
				text: qsTrId("battery_state_of_health")
				dataSource: root.battery.serviceUid + "/Soh"
				visible: defaultVisible && dataValid
				unit: VenusOS.Units_Percentage
			}

			ListQuantityItem {
				//% "Battery temperature"
				text: qsTrId("battery_temp")
				visible: defaultVisible && !isNaN(root.battery.temperature_celsius)
				value: Global.systemSettings.convertTemperature(root.battery.temperature_celsius)
				unit: Global.systemSettings.temperatureUnit.value
			}

			ListQuantityItem {
				//% "Air temperature"
				text: qsTrId("battery_air_temp")
				dataSource: root.battery.serviceUid + "/AirTemperature"
				visible: defaultVisible && dataValid
				value: dataValue ? Global.systemSettings.convertTemperature(dataValue) : NaN
				unit: Global.systemSettings.temperatureUnit.value
			}

			ListQuantityItem {
				//% "Starter voltage"
				text: qsTrId("battery_starter_voltage")
				dataSource: root.battery.serviceUid + "/Dc/1/Voltage"
				visible: defaultVisible && dataValid
				unit: VenusOS.Units_Volt
				precision: 2
			}

			ListQuantityItem {
				//% "Bus voltage"
				text: qsTrId("battery_bus_voltage")
				dataSource: root.battery.serviceUid + "/BusVoltage"
				visible: defaultVisible && dataValid
				unit: VenusOS.Units_Volt
				precision: 2
			}

			ListQuantityItem {
				//% "Top section voltage"
				text: qsTrId("battery_top_section_voltage")
				visible: midVoltage.valid
				value: midVoltage.valid && !isNaN(root.battery.voltage) ? root.battery.voltage - midVoltage.value : NaN
				unit: VenusOS.Units_Volt
				precision: 2
			}

			ListQuantityItem {
				//% "Bottom section voltage"
				text: qsTrId("battery_bottom_section_voltage")
				value: midVoltage.value === undefined ? NaN : midVoltage.value
				visible: midVoltage.valid
				unit: VenusOS.Units_Volt
				precision: 2
			}

			ListQuantityItem {
				//% "Mid-point deviation"
				text: qsTrId("battery_mid_point_deviation")
				dataSource: root.battery.serviceUid + "/Dc/0/MidVoltageDeviation"
				visible: defaultVisible && dataValid
				unit: VenusOS.Units_Percentage
			}

			ListQuantityItem {
				//% "Consumed AmpHours"
				text: qsTrId("battery_consumed_amphours")
				dataSource: root.battery.serviceUid + "/ConsumedAmphours"
				visible: defaultVisible && dataValid
				unit: VenusOS.Units_AmpHour
			}

			ListQuantityItem {
				//% "Bus voltage"
				text: qsTrId("battery_buss_voltage")
				dataSource: root.battery.serviceUid + "/BussVoltage"
				visible: defaultVisible && dataValid
				unit: VenusOS.Units_Volt
				precision: 2
			}

			ListTextItem {
				//% "Time-to-go"
				text: qsTrId("battery_time_to_go")
				visible: defaultVisible && dataSeen
				secondaryText: Utils.secondsToString(root.battery.timeToGo)
			}

			ListTextItem {
				//% "Relay state"
				text: qsTrId("battery_relay_state")
				dataSource: root.battery.serviceUid + "/Relay/0/State"
				visible: defaultVisible && dataValid
				secondaryText: CommonWords.onOrOff(dataValue)
			}

			ListTextItem {
				//% "Alarm state"
				text: qsTrId("battery_alarm_state")
				dataSource: root.battery.serviceUid + "/Alarms/Alarm"
				visible: defaultVisible && dataValid
				secondaryText: {
					if (dataValue === 0) {
						return CommonWords.ok
					} else if (dataValue === 1) {
						//: Alarm state is active
						//% "Alarm"
						return qsTrId("devicelist_battery_alarm_state")
					} else {
						return ""
					}
				}
			}

			ListNavigationItem {
				//% "Details"
				text: qsTrId("battery_details")
				visible: defaultVisible && batteryDetails.anyItemValid
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/devicelist/battery/PageBatteryDetails.qml",
							{ "title": text, "bindPrefix": root.battery.serviceUid, "details": batteryDetails })
				}

				BatteryDetails {
					id: batteryDetails
					bindPrefix: root.battery.serviceUid
				}
			}

			ListNavigationItem {
				text: CommonWords.alarms
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/devicelist/battery/PageBatteryAlarms.qml",
							{ "title": text, "bindPrefix": root.battery.serviceUid })
				}
			}

			ListNavigationItem {
				//% "Module level alarms"
				text: qsTrId("battery_module_level_alarms")
				visible: moduleAlarmModel.rowCount > 0
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/devicelist/battery/PageBatteryModuleAlarms.qml",
							{ "title": text, "bindPrefix": root.battery.serviceUid, alarmModel: moduleAlarmModel })
				}
			}

			ListNavigationItem {
				text: CommonWords.history
				visible: !isFiamm48TL
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/devicelist/battery/PageBatteryHistory.qml",
							{ "title": text, "bindPrefix": root.battery.serviceUid })
				}
			}

			ListNavigationItem {
				text: CommonWords.settings
				visible: hasSettings.value === 1
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/devicelist/battery/PageBatterySettings.qml",
							{ "title": text, "bindPrefix": root.battery.serviceUid })
				}
			}

			ListNavigationItem {
				id: lynxIonDiagnostics

				//% "Diagnostics"
				text: qsTrId("battery_settings_diagnostics")
				visible: lastError.valid
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/devicelist/battery/PageLynxIonDiagnostics.qml",
							{ "title": text, "bindPrefix": root.battery.serviceUid })
				}

				DataPoint {
					id: lastError
					source: root.battery.serviceUid + "/Diagnostics/LastErrors/1/Error"
				}
			}

			ListNavigationItem {
				text: lynxIonDiagnostics.text
				visible: isFiamm48TL

				onClicked: {
					Global.pageManager.pushPage("/pages/settings/devicelist/battery/Page48TlDiagnostics.qml",
							{ "title": text, "bindPrefix": root.battery.serviceUid })
				}
			}

			ListNavigationItem {
				//% "Fuses"
				text: qsTrId("battery_settings_fuses")
				visible: nrOfDistributors.valid && nrOfDistributors.value > 0

				onClicked: {
					Global.pageManager.pushPage("/pages/settings/devicelist/battery/PageLynxDistributorList.qml",
							{ "title": text, "bindPrefix": root.battery.serviceUid })
				}

				DataPoint {
					id: nrOfDistributors
					source: root.battery.serviceUid + "/NrOfDistributors"
				}
			}

			ListNavigationItem {
				//% "IO"
				text: qsTrId("battery_settings_io")
				visible: allowToCharge.valid
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/devicelist/battery/PageLynxIonIo.qml",
							{ "title": text, "bindPrefix": root.battery.serviceUid })
				}

				DataPoint {
					id: allowToCharge
					source: root.battery.serviceUid + "/Io/AllowToCharge"
				}
			}

			ListNavigationItem {
				//% "System"
				text: qsTrId("battery_settings_system")
				visible: nrOfBatteries.valid
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/devicelist/battery/PageLynxIonSystem.qml",
							{ "title": text, "bindPrefix": root.battery.serviceUid })
				}

				DataPoint {
					id: nrOfBatteries
					source: root.battery.serviceUid +"/System/NrOfBatteries"
				}
			}

			ListNavigationItem {
				text: CommonWords.device_info_title
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/PageDeviceInfo.qml",
							{ "title": text, "bindPrefix": root.battery.serviceUid })
				}
			}

			ListNavigationItem {
				//% "Parameters"
				text: qsTrId("battery_settings_parameters")
				visible: cvl.valid || ccl.valid || dcl.valid
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/devicelist/battery/PageBatteryParameters.qml",
							{ "title": text, "bindPrefix": root.battery.serviceUid })
				}

				DataPoint {
					id: cvl
					source: root.battery.serviceUid + "/Info/MaxChargeVoltage"
				}

				DataPoint {
					id: ccl
					source: root.battery.serviceUid + "/Info/MaxChargeCurrent"
				}

				DataPoint {
					id: dcl
					source: root.battery.serviceUid + "/Info/MaxDischargeCurrent"
				}
			}

			ListButton {
				//% "Redetect Battery"
				text: qsTrId("battery_redetect_battery")
				//% "Press to redetect"
				secondaryText: qsTrId("battery_press_to_redetect")
				enabled: redetect.value === 0
				visible: redetect.valid
				writeAccessLevel: VenusOS.User_AccessType_User
				onClicked: {
					redetect.setValue(1)
					//% "Redetecting the battery may take up time 60 seconds. Meanwhile the name of the battery may be incorrect."
					Global.showToastNotification(VenusOS.Notification_Info, qsTrId("battery_redetecting_the_battery_note"), 10000)
				}

				DataPoint {
					id: redetect
					source: root.battery.serviceUid + "/Redetect"
				}
			}
		}
	}

	DataPoint {
		id: midVoltage
		source: root.battery.serviceUid + "/Dc/0/MidVoltage"
	}

	DataPoint {
		id: productId
		source: root.battery.serviceUid + "/ProductId"
	}

	DataPoint {
		id: hasSettings
		source: root.battery.serviceUid + "/Settings/HasSettings"
	}

	VeQItemSortTableModel {
		id: moduleAlarmModel

		filterRegExp: "\/Module[0-9]\/Id$"
		filterFlags: VeQItemSortTableModel.FilterInvalid
		model: VeQItemTableModel {
			uids: BackendConnection.type === BackendConnection.DBusSource ? [root.battery.serviceUid + "/Diagnostics"]
				: BackendConnection.type === BackendConnection.MqttSource ? [root.battery.serviceUid + "/Diagnostics"]
				: []
		}
	}
}

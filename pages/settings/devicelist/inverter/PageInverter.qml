/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string bindPrefix

	readonly property bool isInverterCharger: isInverterChargerItem.value === 1

	readonly property var rsAlarms: [
		{ text: CommonWords.low_state_of_charge, alarmSuffix: "/LowSoc", pathSuffix: "/Settings/AlarmLevel/LowSoc" },
		{ text: CommonWords.low_battery_voltage, alarmSuffix: "/LowVoltage", pathSuffix: "/Settings/AlarmLevel/LowVoltage" },
		{ text: CommonWords.high_battery_voltage, alarmSuffix: "/HighVoltage", pathSuffix: "/Settings/AlarmLevel/HighVoltage" },
		{ text: CommonWords.high_temperature, alarmSuffix: "/HighTemperature", pathSuffix: "/Settings/AlarmLevel/HighTemperature" },
		//% "Low AC OUT voltage"
		{ text: qsTrId("rs_alarm_low_ac_out_voltage"), alarmSuffix: "/LowVoltageAcOut", pathSuffix: "/Settings/AlarmLevel/LowVoltageAcOut" },
		//% "High AC OUT voltage"
		{ text: qsTrId("rs_alarm_high_ac_out_voltage"), alarmSuffix: "/HighVoltageAcOut", pathSuffix: "/Settings/AlarmLevel/HighVoltageAcOut" },
		{ text: CommonWords.alarm_setting_overload, alarmSuffix: "/Overload", pathSuffix: "/Settings/AlarmLevel/Overload" },
		{ text: CommonWords.alarm_setting_dc_ripple, alarmSuffix: "/Ripple", pathSuffix: "/Settings/AlarmLevel/Ripple" },
		//% "Short circuit"
		{ text: qsTrId("rs_alarm_short_circuit"), alarmSuffix: "/ShortCircuit", pathSuffix: "/Settings/AlarmLevel/ShortCircuit" }
	]

	VeQuickItem {
		id: isInverterChargerItem
		uid: root.bindPrefix + "/IsInverterCharger"
	}

	GradientListView {
		model: ObjectModel {

			ListRadioButtonGroup {
				id: modeSwitch

				text: CommonWords.switch_mode
				dataItem.uid: root.bindPrefix + "/Mode"
				allowed: defaultAllowed && !root.isInverterCharger
				optionModel: [
					{ display: CommonWords.off, value: VenusOS.Inverter_Mode_Off },
					{ display: CommonWords.on, value: VenusOS.Inverter_Mode_On },
					{ display: CommonWords.inverter_mode_eco, value: VenusOS.Inverter_Mode_Eco },
				]
			}

			ListRadioButtonGroup {
				text: modeSwitch.text
				dataItem.uid: root.bindPrefix + "/Mode"
				allowed: defaultAllowed && root.isInverterCharger
				optionModel: [
					{ display: CommonWords.off, value: VenusOS.InverterCharger_Mode_Off },
					//: Inverter 'Charger Only' mode
					//% "Charger Only"
					{ display: qsTrId("inverter_charger_only"), value: VenusOS.InverterCharger_Mode_ChargerOnly },
					//: Inverter 'Inverter Only' mode
					//% "Inverter Only"
					{ display: qsTrId("inverter_inverter_only"), value: VenusOS.InverterCharger_Mode_InverterOnly },
					{ display: CommonWords.on, value: VenusOS.InverterCharger_Mode_On },
				]
			}

			ListTextItem {
				text: CommonWords.state
				secondaryText: Global.system.systemStateToText(dataItem.value)
				dataItem.uid: root.bindPrefix + "/State"
			}

			InverterAcOutQuantityGroup {
				bindPrefix: root.bindPrefix
				isInverterCharger: root.isInverterCharger
			}

			ListQuantityGroup {
				text: CommonWords.dc
				textModel: [
					{ value: dcVoltage.value, unit: VenusOS.Units_Volt_DC },
					{ value: dcCurrent.value, unit: VenusOS.Units_Amp },
				]

				VeQuickItem {
					id: dcVoltage
					uid: root.bindPrefix + "/Dc/0/Voltage"
				}

				VeQuickItem {
					id: dcCurrent
					uid: root.bindPrefix + "/Dc/0/Current"
				}
			}

			ListQuantityGroup {
				//% "PV"
				text: qsTrId("inverter_pv")
				allowed: pvV.isValid || pvYield.isValid
				textModel: [
					{ value: pvV.value, unit: VenusOS.Units_Volt_DC },
					{ value: pvYield.value, unit: VenusOS.Units_Watt },
				]

				VeQuickItem {
					id: pvV
					uid: root.bindPrefix + "/Pv/V"
				}

				VeQuickItem {
					id: pvYield
					uid: root.bindPrefix + "/Yield/Power"
				}
			}

			ListQuantityItem {
				//% "Total yield"
				text: qsTrId("inverter_total_yield")
				allowed: defaultAllowed && dataItem.isValid
				unit: VenusOS.Units_Energy_KiloWattHour
				dataItem.uid: root.bindPrefix + "/Yield/User"
			}

			ListQuantityItem {
				//% "System yield"
				text: qsTrId("inverter_system_yield")
				allowed: defaultAllowed && dataItem.isValid
				unit: VenusOS.Units_Energy_KiloWattHour
				dataItem.uid: root.bindPrefix + "/Yield/System"
			}

			ListQuantityItem {
				text: CommonWords.state_of_charge
				allowed: defaultAllowed && root.isInverterCharger
				unit: VenusOS.Units_Percentage
				dataItem.uid: root.bindPrefix + "/Soc"
			}

			ListTemperatureItem {
				text: CommonWords.battery_temperature
				dataItem.uid: root.bindPrefix + "/Dc/0/Temperature"
				allowed: defaultAllowed && dataItem.isValid
			}

			ListTextItem {
				text: CommonWords.error
				dataItem.uid: root.bindPrefix + "/ErrorCode"
				allowed: defaultAllowed && root.isInverterCharger
				secondaryText: ChargerError.description(dataItem.value)
			}

			ListRelayState {
				dataItem.uid: root.bindPrefix + "/Relay/0/State"
			}

			ListNavigationItem {
				property SolarHistory solarHistory

				//% "Daily history"
				text: qsTrId("inverter_daily_history")
				allowed: (numberOfTrackers.value || 0) > 0
				onClicked: {
					if (!solarHistory) {
						solarHistory = solarHistoryComponent.createObject(root)
					}
					Global.pageManager.pushPage("/pages/solar/SolarHistoryPage.qml",
							{ "solarHistory": solarHistory })
				}

				VeQuickItem {
					id: numberOfTrackers
					uid: root.bindPrefix + "/NrOfTrackers"
				}

				Component {
					id: solarHistoryComponent

					SolarHistory {
						id: solarHistory

						bindPrefix: root.bindPrefix
						deviceName: solarDevice.name
						trackerCount: numberOfTrackers.value || 0

						readonly property Device solarDevice: Device {
							serviceUid: root.bindPrefix
						}
					}
				}
			}

			ListNavigationItem {
				text: CommonWords.overall_history
				allowed: root.isInverterCharger
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/devicelist/inverter/PageSolarStats.qml",
							{ "title": text, "bindPrefix": root.bindPrefix })
				}
			}

			ListNavigationItem {
				text: CommonWords.alarm_status
				allowed: root.isInverterCharger
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/devicelist/rs/PageRsAlarms.qml",
							{ "title": text, "bindPrefix": root.bindPrefix, "rsModel": root.rsAlarms })
				}
			}

			ListNavigationItem {
				text: CommonWords.alarm_setup
				allowed: root.isInverterCharger
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/devicelist/rs/PageRsAlarmSettings.qml",
							{ "title": text, "bindPrefix": root.bindPrefix, "rsModel": root.rsAlarms })
				}
			}

			ListNavigationItem {
				text: CommonWords.device_info_title
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/PageDeviceInfo.qml",
							{ "title": text, "bindPrefix": root.bindPrefix })
				}
			}
		}
	}
}

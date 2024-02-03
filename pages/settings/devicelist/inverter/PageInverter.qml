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
		{ text: CommonWords.low_state_of_charge, alarmSuffix: "/LowSoc", pathSuffix: "/Settings/Alarms/LowSoc" },
		{ text: CommonWords.low_battery_voltage, alarmSuffix: "/LowVoltage", pathSuffix: "/Settings/Alarms/LowVoltage" },
		{ text: CommonWords.high_battery_voltage, alarmSuffix: "/HighVoltage", pathSuffix: "/Settings/Alarms/HighVoltage" },
		{ text: CommonWords.high_temperature, alarmSuffix: "/HighTemperature", pathSuffix: "/Settings/Alarms/HighTemperature" },
		//% "Low AC OUT voltage"
		{ text: qsTrId("rs_alarm_low_ac_out_voltage"), alarmSuffix: "/LowVoltageAcOut", pathSuffix: "/Settings/Alarms/LowVoltageAcOut" },
		//% "High AC OUT voltage"
		{ text: qsTrId("rs_alarm_high_ac_out_voltage"), alarmSuffix: "/HighVoltageAcOut", pathSuffix: "/Settings/Alarms/HighVoltageAcOut" },
		{ text: CommonWords.alarm_setting_overload, alarmSuffix: "/Overload", pathSuffix: "/Settings/Alarms/Overload" },
		{ text: CommonWords.alarm_setting_dc_ripple, alarmSuffix: "/Ripple", pathSuffix: "/Settings/Alarms/Ripple" }
	]

	VeQuickItem {
		id: isInverterChargerItem
		uid: root.bindPrefix + "/IsInverterCharger"
	}

	AcOutput {
		id: inverterData

		serviceUid: root.bindPrefix
	}

	GradientListView {
		model: ObjectModel {

			ListRadioButtonGroup {
				id: modeSwitch

				text: CommonWords.switch_mode
				dataItem.uid: root.bindPrefix + "/Mode"
				visible: defaultVisible && !root.isInverterCharger
				optionModel: [
					{ display: CommonWords.off, value: 4 },
					{ display: CommonWords.on, value: 2 },
					//: Inverter 'Eco' mode
					//% "Eco"
					{ display: qsTrId("inverter_eco"), value: 5 },
				]
			}

			ListRadioButtonGroup {
				text: modeSwitch.text
				dataItem.uid: root.bindPrefix + "/Mode"
				visible: defaultVisible && root.isInverterCharger
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

			ListQuantityGroup {
				//% "AC-Out"
				text: qsTrId("inverter_ac-out")
				visible: !root.isInverterCharger
				textModel: [
					{ value: inverterData.phase1.voltage, unit: VenusOS.Units_Volt },
					{ value: inverterData.phase1.current, unit: VenusOS.Units_Amp },
					{ value: inverterData.phase1.power, unit: VenusOS.Units_Watt },
				]
			}

			ListQuantityGroup {
				readonly property AcPhase acPhase: acPhaseNumber.value === 2 ? inverterData.phase3
						: acPhaseNumber.value === 1 ? inverterData.phase2
						: inverterData.phase1

				//: %1 = phase number (1-3)
				//% "AC-Out L%1"
				text: qsTrId("inverter_ac-out_num").arg(isNaN(acPhase.value) ? 1 : acPhase.value + 1)
				visible: root.isInverterCharger
				textModel: [
					{ value: acPhase.voltage, unit: VenusOS.Units_Volt },
					{ value: acPhase.current, unit: VenusOS.Units_Amp },
					{ value: acPhase.power, unit: VenusOS.Units_Watt },
					{ value: acPhase.frequency, unit: VenusOS.Units_Hertz },
				]

				VeQuickItem {
					id: acPhaseNumber
					uid: root.bindPrefix + "/Settings/System/AcPhase"
				}
			}

			ListQuantityGroup {
				//% "DC"
				text: qsTrId("inverter_dc")
				textModel: [
					{ value: dcVoltage.value, unit: VenusOS.Units_Volt, precision: 2 },
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
				visible: pvV.isValid || pvYield.isValid
				textModel: [
					{ value: pvV.value, unit: VenusOS.Units_Volt, precision: 2 },
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
				visible: defaultVisible && dataItem.isValid
				unit: VenusOS.Units_Energy_KiloWattHour
				dataItem.uid: root.bindPrefix + "/Yield/User"
			}

			ListQuantityItem {
				//% "System yield"
				text: qsTrId("inverter_system_yield")
				visible: defaultVisible && dataItem.isValid
				unit: VenusOS.Units_Energy_KiloWattHour
				dataItem.uid: root.bindPrefix + "/Yield/System"
			}

			ListQuantityItem {
				text: CommonWords.state_of_charge
				visible: defaultVisible && root.isInverterCharger
				unit: VenusOS.Units_Percentage
				dataItem.uid: root.bindPrefix + "/Soc"
			}

			ListTemperatureItem {
				text: CommonWords.battery_temperature
				dataItem.uid: root.bindPrefix + "/Dc/0/Temperature"
				visible: defaultVisible && dataItem.isValid
			}

			ListTextItem {
				text: CommonWords.error
				dataItem.uid: root.bindPrefix + "/ErrorCode"
				visible: defaultVisible && root.isInverterCharger
				secondaryText: ChargerError.description(dataItem.value)
			}

			ListRelayState {
				dataItem.uid: root.bindPrefix + "/Relay/0/State"
			}

			ListNavigationItem {
				property SolarHistory solarHistory

				//% "Daily history"
				text: qsTrId("inverter_daily_history")
				visible: (numberOfTrackers.value || 0) > 0
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
				//% "Overall history"
				text: qsTrId("inverter_overall_history")
				visible: root.isInverterCharger
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/devicelist/inverter/PageSolarStats.qml",
							{ "title": text, "bindPrefix": root.bindPrefix })
				}
			}

			ListNavigationItem {
				text: CommonWords.alarm_status
				visible: root.isInverterCharger
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/devicelist/inverter/PageRsAlarms.qml",
							{ "title": text, "bindPrefix": root.bindPrefix, "rsModel": root.rsAlarms })
				}
			}

			ListNavigationItem {
				text: CommonWords.alarm_setup
				visible: root.isInverterCharger
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/devicelist/inverter/PageRsAlarmSettings.qml",
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

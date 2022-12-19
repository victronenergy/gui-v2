/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	readonly property string batteryService: {
		for (let i = 0; i < Global.dataServices.length; ++i) {
			if (Global.dataServices[i].startsWith("com.victronenergy.battery.")) {
				return Global.dataServices[i]
			}
		}
		return ""
	}

	//% "Grid Setpoint"
	title: qsTrId("settings_ess_debug_grid_setpoint")

	SettingsListView {
		model: ObjectModel {
			SettingsListSpinBox {
				id: gridSetpoint

				height: implicitHeight + gridSetpointSlider.height
				text: root.title
				source: "com.victronenergy.settings/Settings/CGwacs/AcPowerSetPoint"
				suffix: "W"
				from: -15000
				to: 15000
				stepSize: 10

				SettingsSlider {
					id: gridSetpointSlider

					anchors {
						bottom: parent.bottom
						bottomMargin: Theme.geometry.settingsListItem.content.verticalMargin
					}
					source: "com.victronenergy.settings/Settings/CGwacs/AcPowerSetPoint"
					from: -15000
					to: 15000
					stepSize: 50
				}
			}

			SettingsListTextItem {
				//% "AC-In setpoint"
				text: qsTrId("settings_ess_debug_ac_in_setpoint")
				source: "com.victronenergy.vebus.ttyO1/Hub4/L1/AcPowerSetpoint"
			}

			SettingsListTextGroup {
				//% "Battery"
				text: qsTrId("settings_ess_debug_battery")
				textModel: [
					//% "Current: %1"
					qsTrId("settings_ess_debug_battery_current").arg(batteryCurrent.value || "--"),
					//% "Voltage: %1"
					qsTrId("settings_ess_debug_battery_voltage").arg(batteryVoltage.value || "--"),
				]

				DataPoint {
					id: batteryCurrent
					source: root.batteryService + "/Dc/0/Current"
				}

				DataPoint {
					id: batteryVoltage
					source: root.batteryService + "/Dc/0/Voltage"
				}
			}

			SettingsListTextGroup {
				//% "Limits (I)"
				text: qsTrId("settings_ess_debug_limits_i")
				textModel: [
					//% "Charge: %1"
					qsTrId("settings_ess_debug_battery_charge").arg(batteryChargeCurrent.value || "--"),
					//% "Discharge: %1"
					qsTrId("settings_ess_debug_battery_discharge").arg(batteryDischargeCurrent.value || "--"),
				]

				DataPoint {
					id: batteryChargeCurrent
					source: root.batteryService + "/Info/MaxChargeCurrent"
				}

				DataPoint {
					id: batteryDischargeCurrent
					source: root.batteryService + "/Info/MaxDischargeCurrent"
				}
			}

			SettingsListTextGroup {
				//% "Limits (P)"
				text: qsTrId("settings_ess_debug_limits_p")
				textModel: [
					//% "Charge: %1"
					qsTrId("settings_ess_debug_battery_charge").arg(batteryChargePower.value || "--"),
					//% "Discharge: %1"
					qsTrId("settings_ess_debug_battery_discharge").arg(batteryDischargePower.value || "--"),
				]

				DataPoint {
					id: batteryChargePower
					source: "com.victronenergy.settings/Settings/CGwacs/MaxChargePower"
				}

				DataPoint {
					id: batteryDischargePower
					source: "com.victronenergy.settings/Settings/CGwacs/MaxDischargePower"
				}
			}
		}
	}
}

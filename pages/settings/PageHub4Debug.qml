/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil

Page {
	id: root

	property string batteryService

	//% "Grid Setpoint"
	title: qsTrId("settings_ess_debug_grid_setpoint")

	GradientListView {
		model: ObjectModel {
			ListSpinBox {
				id: gridSetpoint

				text: root.title
				dataSource: "com.victronenergy.settings/Settings/CGwacs/AcPowerSetPoint"
				suffix: "W"
				from: -15000
				to: 15000
				stepSize: 10

				bottomContent.children: [
					SettingsSlider {
						id: gridSetpointSlider

						width: parent.width
						dataSource: "com.victronenergy.settings/Settings/CGwacs/AcPowerSetPoint"
						from: -15000
						to: 15000
						stepSize: 50
					}
				]
			}

			ListTextItem {
				//% "AC-In setpoint"
				text: qsTrId("settings_ess_debug_ac_in_setpoint")
				dataSource: "com.victronenergy.vebus.ttyO1/Hub4/L1/AcPowerSetpoint"
			}

			ListTextGroup {
				text: CommonWords.battery
				textModel: [
					//: Battery current, in amps
					//% "Current: %1"
					qsTrId("settings_ess_debug_battery_current").arg(batteryCurrent.value || "--"),
					//: Battery voltage, in volts
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

			ListTextGroup {
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

			ListTextGroup {
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

	Instantiator {
		active: BackendConnection.type === BackendConnection.DBusSource
		model: VeQItemSortTableModel {
			filterRole: VeQItemTableModel.UniqueIdRole
			filterRegExp: "^dbus/com\.victronenergy\.battery\."
			model: Global.dataServiceModel
		}
		delegate: QtObject {
			Component.onCompleted: {
				if (root.batteryService === "") {
					root.batteryService = model.uid
				}
			}
		}
	}

	Instantiator {
		active: BackendConnection.type === BackendConnection.MqttSource
		model: VeQItemTableModel {
			uids: ["mqtt/battery"]
			flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
		}
		delegate: QtObject {
			Component.onCompleted: {
				if (root.batteryService === "") {
					root.batteryService = model.uid
				}
			}
		}
	}
}

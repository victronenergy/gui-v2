/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	readonly property string batteryUid: batteryModel.firstObject?.serviceUid ?? ""

	//% "Grid Setpoint"
	title: qsTrId("settings_ess_debug_grid_setpoint")

	ServiceDeviceModel {
		id: batteryModel
		serviceType: "battery"
	}

	GradientListView {
		model: VisibleItemModel {
			ListSpinBox {
				id: gridSetpoint

				text: root.title
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/CGwacs/AcPowerSetPoint"
				suffix: Units.defaultUnitString(VenusOS.Units_Watt)
				from: -15000
				to: 15000
				stepSize: 10

				bottomContentChildren: [
					SettingsSlider {
						id: gridSetpointSlider

						width: parent.width
						dataItem.uid: Global.systemSettings.serviceUid + "/Settings/CGwacs/AcPowerSetPoint"
						from: -15000
						to: 15000
						stepSize: 50
					}
				]
			}

			ListText {
				//% "AC-In setpoint"
				text: qsTrId("settings_ess_debug_ac_in_setpoint")
				dataItem.uid: Global.system.veBus.serviceUid ? Global.system.veBus.serviceUid + "/Hub4/L1/AcPowerSetpoint" : ""
			}

			ListQuantityGroup {
				text: CommonWords.battery
				model: QuantityObjectModel {
					QuantityObject { object: batteryCurrent; key: "summary" }
					QuantityObject { object: batteryVoltage; key: "summary" }
				}

				VeQuickItem {
					id: batteryCurrent
					readonly property string summary: "Current: %1"
						.arg(isValid ? Units.getCombinedDisplayText(VenusOS.Units_Amp, value) : "--")
					uid: root.batteryUid ? root.batteryUid + "/Dc/0/Current" : ""
				}

				VeQuickItem {
					id: batteryVoltage
					readonly property string summary: "Voltage: %1"
						.arg(isValid ? Units.getCombinedDisplayText(VenusOS.Units_Volt_DC, value) : "--")
					uid: root.batteryUid ? root.batteryUid + "/Dc/0/Voltage" : ""
				}
			}

			ListQuantityGroup {
				//% "Limits (I)"
				text: qsTrId("settings_ess_debug_limits_i")
				model: QuantityObjectModel {
					QuantityObject { object: batteryChargeCurrent; key: "summary" }
					QuantityObject { object: batteryDischargeCurrent; key: "summary" }
				}

				VeQuickItem {
					id: batteryChargeCurrent
					readonly property string summary: "Charge: %1"
						.arg(isValid ? Units.getCombinedDisplayText(VenusOS.Units_Amp, value) : "--")
					uid: root.batteryUid ? root.batteryUid + "/Info/MaxChargeCurrent" : ""
				}

				VeQuickItem {
					id: batteryDischargeCurrent
					readonly property string summary: "Discharge: %1"
						.arg(isValid ? Units.getCombinedDisplayText(VenusOS.Units_Amp, value) : "--")

					uid: root.batteryUid ? root.batteryUid + "/Info/MaxDischargeCurrent" : ""
				}
			}

			ListQuantityGroup {
				//% "Limits (P)"
				text: qsTrId("settings_ess_debug_limits_p")
				model: QuantityObjectModel {
					QuantityObject { object: batteryChargePower; key: "summary" }
					QuantityObject { object: batteryDischargePower; key: "summary" }
				}

				VeQuickItem {
					id: batteryChargePower
					readonly property string summary: "Charge: %1"
						.arg(isValid ? Units.getCombinedDisplayText(VenusOS.Units_Watt, value) : "--")
					uid: Global.systemSettings.serviceUid + "/Settings/CGwacs/MaxChargePower"
				}

				VeQuickItem {
					id: batteryDischargePower
					readonly property string summary: "Discharge: %1"
						.arg(isValid ? Units.getCombinedDisplayText(VenusOS.Units_Watt, value) : "--")
					uid: Global.systemSettings.serviceUid + "/Settings/CGwacs/MaxDischargePower"
				}
			}
		}
	}
}

/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string bindPrefix

	GradientListView {
		model: ObjectModel {
			ListAlarm {
				text: CommonWords.low_battery_voltage
				dataItem.uid: root.bindPrefix + "/Alarms/LowVoltage"
				allowed: defaultAllowed && dataItem.isValid
			}

			ListAlarm {
				//% "High battery voltage"
				text: qsTrId("batteryalarms_high_battery_voltage")
				dataItem.uid: root.bindPrefix + "/Alarms/HighVoltage"
				allowed: defaultAllowed && dataItem.isValid
			}

			ListAlarm {
				//% "High charge current"
				text: qsTrId("batteryalarms_high_charge_current")
				dataItem.uid: root.bindPrefix + "/Alarms/HighChargeCurrent"
				allowed: defaultAllowed && dataItem.isValid
			}

			ListAlarm {
				//% "High discharge current"
				text: qsTrId("batteryalarms_high_discharge_current")
				dataItem.uid: root.bindPrefix + "/Alarms/HighDischargeCurrent"
				allowed: defaultAllowed && dataItem.isValid
			}

			ListAlarm {
				//% "Low SOC"
				text: qsTrId("batteryalarms_low_soc")
				dataItem.uid: root.bindPrefix + "/Alarms/LowSoc"
				allowed: defaultAllowed && dataItem.isValid
			}

			ListAlarm {
				//% "State of health"
				text: qsTrId("batteryalarms_state_of_health")
				dataItem.uid: root.bindPrefix + "/Alarms/StateOfHealth"
				allowed: defaultAllowed && dataItem.isValid
			}

			ListAlarm {
				//% "Low starter voltage"
				text: qsTrId("batteryalarms_low_starter_voltage")
				dataItem.uid: root.bindPrefix + "/Alarms/LowStarterVoltage"
				allowed: defaultAllowed && dataItem.isValid
			}

			ListAlarm {
				//% "High starter voltage"
				text: qsTrId("batteryalarms_high_starter_voltage")
				dataItem.uid: root.bindPrefix + "/Alarms/HighStarterVoltage"
				allowed: defaultAllowed && dataItem.isValid
			}

			ListAlarm {
				text: CommonWords.low_temperature
				dataItem.uid: root.bindPrefix + "/Alarms/LowTemperature"
				allowed: defaultAllowed && dataItem.isValid
			}

			ListAlarm {
				text: CommonWords.high_temperature
				dataItem.uid: root.bindPrefix + "/Alarms/HighTemperature"
				allowed: defaultAllowed && dataItem.isValid
			}

			ListAlarm {
				//% "Battery temperature sensor"
				text: qsTrId("batteryalarms_battery_temperature_sensor")
				dataItem.uid: root.bindPrefix + "/Alarms/BatteryTemperatureSensor"
				allowed: defaultAllowed && dataItem.isValid
			}

			ListAlarm {
				//% "Mid-point voltage"
				text: qsTrId("batteryalarms_mid_point_voltage")
				dataItem.uid: root.bindPrefix + "/Alarms/MidVoltage"
				allowed: defaultAllowed && dataItem.isValid
			}

			ListAlarm {
				//% "Fuse blown"
				text: qsTrId("batteryalarms_fuse_blown")
				dataItem.uid: root.bindPrefix + "/Alarms/FuseBlown"
				allowed: defaultAllowed && dataItem.isValid
			}

			ListAlarm {
				//% "High internal temperature"
				text: qsTrId("batteryalarms_high_internal_temperature")
				dataItem.uid: root.bindPrefix + "/Alarms/HighInternalTemperature"
				allowed: defaultAllowed && dataItem.isValid
			}

			ListAlarm {
				//% "Low charge temperature"
				text: qsTrId("batteryalarms_low_charge_temperature")
				dataItem.uid: root.bindPrefix + "/Alarms/LowChargeTemperature"
				allowed: defaultAllowed && dataItem.isValid
			}

			ListAlarm {
				//% "High charge temperature"
				text: qsTrId("batteryalarms_high_charge_temperature")
				dataItem.uid: root.bindPrefix + "/Alarms/HighChargeTemperature"
				allowed: defaultAllowed && dataItem.isValid
			}

			ListAlarm {
				//% "Internal failure"
				text: qsTrId("batteryalarms_internal_failure")
				dataItem.uid: root.bindPrefix + "/Alarms/InternalFailure"
				allowed: defaultAllowed && dataItem.isValid
			}

			ListAlarm {
				//% "Circuit breaker tripped"
				text: qsTrId("batteryalarms_circuit_breaker_tripped")
				dataItem.uid: Global.system.serviceUid + "/Dc/Battery/Alarms/CircuitBreakerTripped"
				allowed: defaultAllowed && dataItem.isValid
			}

			ListAlarm {
				//% "Cell imbalance"
				text: qsTrId("batteryalarms_cell_imbalance")
				dataItem.uid: root.bindPrefix + "/Alarms/CellImbalance"
				allowed: defaultAllowed && dataItem.isValid
			}

			ListAlarm {
				//% "Low cell voltage"
				text: qsTrId("batteryalarms_low_cell_voltage")
				dataItem.uid: root.bindPrefix + "/Alarms/LowCellVoltage"
				allowed: defaultAllowed && dataItem.isValid
			}
		}
	}
}

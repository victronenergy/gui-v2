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
				allowed: dataItem.isValid
			}

			ListAlarm {
				//% "High battery voltage"
				text: qsTrId("batteryalarms_high_battery_voltage")
				dataItem.uid: root.bindPrefix + "/Alarms/HighVoltage"
				allowed: dataItem.isValid
			}

			ListAlarm {
				//% "High cell voltage"
				text: qsTrId("batteryalarms_high_cell_voltage")
				dataItem.uid: root.bindPrefix + "/Alarms/HighCellVoltage"
				allowed: dataItem.isValid
			}

			ListAlarm {
				//% "High charge current"
				text: qsTrId("batteryalarms_high_charge_current")
				dataItem.uid: root.bindPrefix + "/Alarms/HighChargeCurrent"
				allowed: dataItem.isValid
			}

			ListAlarm {
				//% "High current"
				text: qsTrId("batteryalarms_high_current")
				dataItem.uid: root.bindPrefix + "/Alarms/HighCurrent"
				allowed: dataItem.isValid
			}

			ListAlarm {
				//% "High discharge current"
				text: qsTrId("batteryalarms_high_discharge_current")
				dataItem.uid: root.bindPrefix + "/Alarms/HighDischargeCurrent"
				allowed: dataItem.isValid
			}

			ListAlarm {
				//% "Low SOC"
				text: qsTrId("batteryalarms_low_soc")
				dataItem.uid: root.bindPrefix + "/Alarms/LowSoc"
				allowed: dataItem.isValid
			}

			ListAlarm {
				//% "State of health"
				text: qsTrId("batteryalarms_state_of_health")
				dataItem.uid: root.bindPrefix + "/Alarms/StateOfHealth"
				allowed: dataItem.isValid
			}

			ListAlarm {
				//% "Low starter voltage"
				text: qsTrId("batteryalarms_low_starter_voltage")
				dataItem.uid: root.bindPrefix + "/Alarms/LowStarterVoltage"
				allowed: dataItem.isValid
			}

			ListAlarm {
				//% "High starter voltage"
				text: qsTrId("batteryalarms_high_starter_voltage")
				dataItem.uid: root.bindPrefix + "/Alarms/HighStarterVoltage"
				allowed: dataItem.isValid
			}

			ListAlarm {
				text: CommonWords.low_temperature
				dataItem.uid: root.bindPrefix + "/Alarms/LowTemperature"
				allowed: dataItem.isValid
			}

			ListAlarm {
				text: CommonWords.high_temperature
				dataItem.uid: root.bindPrefix + "/Alarms/HighTemperature"
				allowed: dataItem.isValid
			}

			ListAlarm {
				//% "Battery temperature sensor"
				text: qsTrId("batteryalarms_battery_temperature_sensor")
				dataItem.uid: root.bindPrefix + "/Alarms/BatteryTemperatureSensor"
				allowed: dataItem.isValid
			}

			ListAlarm {
				//% "Mid-point voltage"
				text: qsTrId("batteryalarms_mid_point_voltage")
				dataItem.uid: root.bindPrefix + "/Alarms/MidVoltage"
				allowed: dataItem.isValid
			}

			ListAlarm {
				//% "Fuse blown"
				text: qsTrId("batteryalarms_fuse_blown")
				dataItem.uid: root.bindPrefix + "/Alarms/FuseBlown"
				allowed: dataItem.isValid
			}

			ListAlarm {
				//% "High internal temperature"
				text: qsTrId("batteryalarms_high_internal_temperature")
				dataItem.uid: root.bindPrefix + "/Alarms/HighInternalTemperature"
				allowed: dataItem.isValid
			}

			ListAlarm {
				//% "Low charge temperature"
				text: qsTrId("batteryalarms_low_charge_temperature")
				dataItem.uid: root.bindPrefix + "/Alarms/LowChargeTemperature"
				allowed: dataItem.isValid
			}

			ListAlarm {
				//% "High charge temperature"
				text: qsTrId("batteryalarms_high_charge_temperature")
				dataItem.uid: root.bindPrefix + "/Alarms/HighChargeTemperature"
				allowed: dataItem.isValid
			}

			ListAlarm {
				//% "Internal failure"
				text: qsTrId("batteryalarms_internal_failure")
				dataItem.uid: root.bindPrefix + "/Alarms/InternalFailure"
				allowed: dataItem.isValid
			}

			ListAlarm {
				//% "Circuit breaker tripped"
				text: qsTrId("batteryalarms_circuit_breaker_tripped")
				dataItem.uid: Global.system.serviceUid + "/Dc/Battery/Alarms/CircuitBreakerTripped"
				allowed: dataItem.isValid
			}

			ListAlarm {
				//% "Cell imbalance"
				text: qsTrId("batteryalarms_cell_imbalance")
				dataItem.uid: root.bindPrefix + "/Alarms/CellImbalance"
				allowed: dataItem.isValid
			}

			ListAlarm {
				//% "Low cell voltage"
				text: qsTrId("batteryalarms_low_cell_voltage")
				dataItem.uid: root.bindPrefix + "/Alarms/LowCellVoltage"
				allowed: dataItem.isValid
			}

			ListAlarm {
				//% "BMS cable fault"
				text: qsTrId("batteryalarms_bms_cable")
				dataItem.uid: root.bindPrefix + "/Alarms/BmsCable"
				allowed: dataItem.isValid
			}

			ListAlarm {
				//% "Bad contactor"
				text: qsTrId("batteryalarms_contactor")
				dataItem.uid: root.bindPrefix + "/Alarms/Contactor"
				allowed: dataItem.isValid
			}
		}
	}
}

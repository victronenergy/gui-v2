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
				visible: defaultVisible && dataItem.isValid
			}

			ListAlarm {
				//% "High battery voltage"
				text: qsTrId("batteryalarms_high_battery_voltage")
				dataItem.uid: root.bindPrefix + "/Alarms/HighVoltage"
				visible: defaultVisible && dataItem.isValid
			}

			ListAlarm {
				//% "High charge current"
				text: qsTrId("batteryalarms_high_charge_current")
				dataItem.uid: root.bindPrefix + "/Alarms/HighChargeCurrent"
				visible: defaultVisible && dataItem.isValid
			}

			ListAlarm {
				//% "High discharge current"
				text: qsTrId("batteryalarms_high_discharge_current")
				dataItem.uid: root.bindPrefix + "/Alarms/HighDischargeCurrent"
				visible: defaultVisible && dataItem.isValid
			}

			ListAlarm {
				//% "Low SOC"
				text: qsTrId("batteryalarms_low_soc")
				dataItem.uid: root.bindPrefix + "/Alarms/LowSoc"
				visible: defaultVisible && dataItem.isValid
			}

			ListAlarm {
				//% "State of health"
				text: qsTrId("batteryalarms_state_of_health")
				dataItem.uid: root.bindPrefix + "/Alarms/StateOfHealth"
				visible: defaultVisible && dataItem.isValid
			}

			ListAlarm {
				//% "Low starter voltage"
				text: qsTrId("batteryalarms_low_starter_voltage")
				dataItem.uid: root.bindPrefix + "/Alarms/LowStarterVoltage"
				visible: defaultVisible && dataItem.isValid
			}

			ListAlarm {
				//% "High starter voltage"
				text: qsTrId("batteryalarms_high_starter_voltage")
				dataItem.uid: root.bindPrefix + "/Alarms/HighStarterVoltage"
				visible: defaultVisible && dataItem.isValid
			}

			ListAlarm {
				text: CommonWords.low_temperature
				dataItem.uid: root.bindPrefix + "/Alarms/LowTemperature"
				visible: defaultVisible && dataItem.isValid
			}

			ListAlarm {
				text: CommonWords.high_temperature
				dataItem.uid: root.bindPrefix + "/Alarms/HighTemperature"
				visible: defaultVisible && dataItem.isValid
			}

			ListAlarm {
				//% "Battery temperature sensor"
				text: qsTrId("batteryalarms_battery_temperature_sensor")
				dataItem.uid: root.bindPrefix + "/Alarms/BatteryTemperatureSensor"
				visible: defaultVisible && dataItem.isValid
			}

			ListAlarm {
				//% "Mid-point voltage"
				text: qsTrId("batteryalarms_mid_point_voltage")
				dataItem.uid: root.bindPrefix + "/Alarms/MidVoltage"
				visible: defaultVisible && dataItem.isValid
			}

			ListAlarm {
				//% "Fuse blown"
				text: qsTrId("batteryalarms_fuse_blown")
				dataItem.uid: root.bindPrefix + "/Alarms/FuseBlown"
				visible: defaultVisible && dataItem.isValid
			}

			ListAlarm {
				//% "High internal temperature"
				text: qsTrId("batteryalarms_high_internal_temperature")
				dataItem.uid: root.bindPrefix + "/Alarms/HighInternalTemperature"
				visible: defaultVisible && dataItem.isValid
			}

			ListAlarm {
				//% "Low charge temperature"
				text: qsTrId("batteryalarms_low_charge_temperature")
				dataItem.uid: root.bindPrefix + "/Alarms/LowChargeTemperature"
				visible: defaultVisible && dataItem.isValid
			}

			ListAlarm {
				//% "High charge temperature"
				text: qsTrId("batteryalarms_high_charge_temperature")
				dataItem.uid: root.bindPrefix + "/Alarms/HighChargeTemperature"
				visible: defaultVisible && dataItem.isValid
			}

			ListAlarm {
				//% "Internal failure"
				text: qsTrId("batteryalarms_internal_failure")
				dataItem.uid: root.bindPrefix + "/Alarms/InternalFailure"
				visible: defaultVisible && dataItem.isValid
			}

			ListAlarm {
				//% "Circuit breaker tripped"
				text: qsTrId("batteryalarms_circuit_breaker_tripped")
				dataItem.uid: Global.system.serviceUid + "/Dc/Battery/Alarms/CircuitBreakerTripped"
				visible: defaultVisible && dataItem.isValid
			}

			ListAlarm {
				//% "Cell imbalance"
				text: qsTrId("batteryalarms_cell_imbalance")
				dataItem.uid: root.bindPrefix + "/Alarms/CellImbalance"
				visible: defaultVisible && dataItem.isValid
			}

			ListAlarm {
				//% "Low cell voltage"
				text: qsTrId("batteryalarms_low_cell_voltage")
				dataItem.uid: root.bindPrefix + "/Alarms/LowCellVoltage"
				visible: defaultVisible && dataItem.isValid
			}
		}
	}
}

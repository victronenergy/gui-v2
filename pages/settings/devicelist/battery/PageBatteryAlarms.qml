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
		model: VisibleItemModel {
			ListAlarm {
				text: CommonWords.low_battery_voltage
				dataItem.uid: root.bindPrefix + "/Alarms/LowVoltage"
				preferredVisible: dataItem.valid
			}

			ListAlarm {
				//% "High battery voltage"
				text: qsTrId("batteryalarms_high_battery_voltage")
				dataItem.uid: root.bindPrefix + "/Alarms/HighVoltage"
				preferredVisible: dataItem.valid
			}

			ListAlarm {
				//% "High cell voltage"
				text: qsTrId("batteryalarms_high_cell_voltage")
				dataItem.uid: root.bindPrefix + "/Alarms/HighCellVoltage"
				preferredVisible: dataItem.valid
			}

			ListAlarm {
				//% "High charge current"
				text: qsTrId("batteryalarms_high_charge_current")
				dataItem.uid: root.bindPrefix + "/Alarms/HighChargeCurrent"
				preferredVisible: dataItem.valid
			}

			ListAlarm {
				//% "High current"
				text: qsTrId("batteryalarms_high_current")
				dataItem.uid: root.bindPrefix + "/Alarms/HighCurrent"
				preferredVisible: dataItem.valid
			}

			ListAlarm {
				//% "High discharge current"
				text: qsTrId("batteryalarms_high_discharge_current")
				dataItem.uid: root.bindPrefix + "/Alarms/HighDischargeCurrent"
				preferredVisible: dataItem.valid
			}

			ListAlarm {
				//% "Low SOC"
				text: qsTrId("batteryalarms_low_soc")
				dataItem.uid: root.bindPrefix + "/Alarms/LowSoc"
				preferredVisible: dataItem.valid
			}

			ListAlarm {
				//% "State of health"
				text: qsTrId("batteryalarms_state_of_health")
				dataItem.uid: root.bindPrefix + "/Alarms/StateOfHealth"
				preferredVisible: dataItem.valid
			}

			ListAlarm {
				//% "Low starter voltage"
				text: qsTrId("batteryalarms_low_starter_voltage")
				dataItem.uid: root.bindPrefix + "/Alarms/LowStarterVoltage"
				preferredVisible: dataItem.valid
			}

			ListAlarm {
				//% "High starter voltage"
				text: qsTrId("batteryalarms_high_starter_voltage")
				dataItem.uid: root.bindPrefix + "/Alarms/HighStarterVoltage"
				preferredVisible: dataItem.valid
			}

			ListAlarm {
				text: CommonWords.low_temperature
				dataItem.uid: root.bindPrefix + "/Alarms/LowTemperature"
				preferredVisible: dataItem.valid
			}

			ListAlarm {
				text: CommonWords.high_temperature
				dataItem.uid: root.bindPrefix + "/Alarms/HighTemperature"
				preferredVisible: dataItem.valid
			}

			ListAlarm {
				//% "Battery temperature sensor"
				text: qsTrId("batteryalarms_battery_temperature_sensor")
				dataItem.uid: root.bindPrefix + "/Alarms/BatteryTemperatureSensor"
				preferredVisible: dataItem.valid
			}

			ListAlarm {
				//% "Mid-point voltage"
				text: qsTrId("batteryalarms_mid_point_voltage")
				dataItem.uid: root.bindPrefix + "/Alarms/MidVoltage"
				preferredVisible: dataItem.valid
			}

			ListAlarm {
				//% "Fuse blown"
				text: qsTrId("batteryalarms_fuse_blown")
				dataItem.uid: root.bindPrefix + "/Alarms/FuseBlown"
				preferredVisible: dataItem.valid
			}

			ListAlarm {
				//% "High internal temperature"
				text: qsTrId("batteryalarms_high_internal_temperature")
				dataItem.uid: root.bindPrefix + "/Alarms/HighInternalTemperature"
				preferredVisible: dataItem.valid
			}

			ListAlarm {
				//% "Low charge temperature"
				text: qsTrId("batteryalarms_low_charge_temperature")
				dataItem.uid: root.bindPrefix + "/Alarms/LowChargeTemperature"
				preferredVisible: dataItem.valid
			}

			ListAlarm {
				//% "High charge temperature"
				text: qsTrId("batteryalarms_high_charge_temperature")
				dataItem.uid: root.bindPrefix + "/Alarms/HighChargeTemperature"
				preferredVisible: dataItem.valid
			}

			ListAlarm {
				//% "Internal failure"
				text: qsTrId("batteryalarms_internal_failure")
				dataItem.uid: root.bindPrefix + "/Alarms/InternalFailure"
				preferredVisible: dataItem.valid
			}

			ListAlarm {
				//% "Circuit breaker tripped"
				text: qsTrId("batteryalarms_circuit_breaker_tripped")
				dataItem.uid: Global.system.serviceUid + "/Dc/Battery/Alarms/CircuitBreakerTripped"
				preferredVisible: dataItem.valid
			}

			ListAlarm {
				//% "Cell imbalance"
				text: qsTrId("batteryalarms_cell_imbalance")
				dataItem.uid: root.bindPrefix + "/Alarms/CellImbalance"
				preferredVisible: dataItem.valid
			}

			ListAlarm {
				//% "Low cell voltage"
				text: qsTrId("batteryalarms_low_cell_voltage")
				dataItem.uid: root.bindPrefix + "/Alarms/LowCellVoltage"
				preferredVisible: dataItem.valid
			}

			ListAlarm {
				//% "BMS cable fault"
				text: qsTrId("batteryalarms_bms_cable")
				dataItem.uid: root.bindPrefix + "/Alarms/BmsCable"
				preferredVisible: dataItem.valid
			}

			ListAlarm {
				//% "Bad contactor"
				text: qsTrId("batteryalarms_contactor")
				dataItem.uid: root.bindPrefix + "/Alarms/Contactor"
				preferredVisible: dataItem.valid
			}
		}
	}
}

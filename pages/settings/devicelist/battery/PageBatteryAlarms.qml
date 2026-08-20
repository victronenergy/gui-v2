/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string bindPrefix

	VeQuickItem {
		id: contactorItem
		uid: root.bindPrefix + "/Alarms/Contactor"
	}
	VeQuickItem {
		id: bmsCableItem
		uid: root.bindPrefix + "/Alarms/BmsCable"
	}
	VeQuickItem {
		id: lowCellVoltageItem
		uid: root.bindPrefix + "/Alarms/LowCellVoltage"
	}
	VeQuickItem {
		id: cellImbalanceItem
		uid: root.bindPrefix + "/Alarms/CellImbalance"
	}
	VeQuickItem {
		id: circuitBreakerTrippedItem
		uid: Global.system.serviceUid + "/Dc/Battery/Alarms/CircuitBreakerTripped"
	}
	VeQuickItem {
		id: internalFailureItem
		uid: root.bindPrefix + "/Alarms/InternalFailure"
	}
	VeQuickItem {
		id: highChargeTemperatureItem
		uid: root.bindPrefix + "/Alarms/HighChargeTemperature"
	}
	VeQuickItem {
		id: lowChargeTemperatureItem
		uid: root.bindPrefix + "/Alarms/LowChargeTemperature"
	}
	VeQuickItem {
		id: highInternalTemperatureItem
		uid: root.bindPrefix + "/Alarms/HighInternalTemperature"
	}
	VeQuickItem {
		id: fuseBlownItem
		uid: root.bindPrefix + "/Alarms/FuseBlown"
	}
	VeQuickItem {
		id: midVoltageItem
		uid: root.bindPrefix + "/Alarms/MidVoltage"
	}
	VeQuickItem {
		id: batteryTemperatureSensorItem
		uid: root.bindPrefix + "/Alarms/BatteryTemperatureSensor"
	}
	VeQuickItem {
		id: highTemperatureItem
		uid: root.bindPrefix + "/Alarms/HighTemperature"
	}
	VeQuickItem {
		id: lowTemperatureItem
		uid: root.bindPrefix + "/Alarms/LowTemperature"
	}
	VeQuickItem {
		id: highStarterVoltageItem
		uid: root.bindPrefix + "/Alarms/HighStarterVoltage"
	}
	VeQuickItem {
		id: lowStarterVoltageItem
		uid: root.bindPrefix + "/Alarms/LowStarterVoltage"
	}
	VeQuickItem {
		id: stateOfHealthItem
		uid: root.bindPrefix + "/Alarms/StateOfHealth"
	}
	VeQuickItem {
		id: lowSocItem
		uid: root.bindPrefix + "/Alarms/LowSoc"
	}
	VeQuickItem {
		id: highDischargeCurrentItem
		uid: root.bindPrefix + "/Alarms/HighDischargeCurrent"
	}
	VeQuickItem {
		id: highCurrentItem
		uid: root.bindPrefix + "/Alarms/HighCurrent"
	}
	VeQuickItem {
		id: highChargeCurrentItem
		uid: root.bindPrefix + "/Alarms/HighChargeCurrent"
	}
	VeQuickItem {
		id: highCellVoltageItem
		uid: root.bindPrefix + "/Alarms/HighCellVoltage"
	}
	VeQuickItem {
		id: highVoltageItem
		uid: root.bindPrefix + "/Alarms/HighVoltage"
	}
	VeQuickItem {
		id: lowVoltageItem
		uid: root.bindPrefix + "/Alarms/LowVoltage"
	}

	GradientListView {
		model: DelegateComponentModel {
			DelegateComponent {
				preferredVisible: lowVoltageItem.valid
				ListAlarm {
					text: CommonWords.low_battery_voltage
					dataItem.uid: root.bindPrefix + "/Alarms/LowVoltage"
				}
			}

			DelegateComponent {
				preferredVisible: highVoltageItem.valid
				ListAlarm {
					//% "High battery voltage"
					text: qsTrId("batteryalarms_high_battery_voltage")
					dataItem.uid: root.bindPrefix + "/Alarms/HighVoltage"
				}
			}

			DelegateComponent {
				preferredVisible: highCellVoltageItem.valid
				ListAlarm {
					//% "High cell voltage"
					text: qsTrId("batteryalarms_high_cell_voltage")
					dataItem.uid: root.bindPrefix + "/Alarms/HighCellVoltage"
				}
			}

			DelegateComponent {
				preferredVisible: highChargeCurrentItem.valid
				ListAlarm {
					//% "High charge current"
					text: qsTrId("batteryalarms_high_charge_current")
					dataItem.uid: root.bindPrefix + "/Alarms/HighChargeCurrent"
				}
			}

			DelegateComponent {
				preferredVisible: highCurrentItem.valid
				ListAlarm {
					//% "High current"
					text: qsTrId("batteryalarms_high_current")
					dataItem.uid: root.bindPrefix + "/Alarms/HighCurrent"
				}
			}

			DelegateComponent {
				preferredVisible: highDischargeCurrentItem.valid
				ListAlarm {
					//% "High discharge current"
					text: qsTrId("batteryalarms_high_discharge_current")
					dataItem.uid: root.bindPrefix + "/Alarms/HighDischargeCurrent"
				}
			}

			DelegateComponent {
				preferredVisible: lowSocItem.valid
				ListAlarm {
					//% "Low SOC"
					text: qsTrId("batteryalarms_low_soc")
					dataItem.uid: root.bindPrefix + "/Alarms/LowSoc"
				}
			}

			DelegateComponent {
				preferredVisible: stateOfHealthItem.valid
				ListAlarm {
					//% "State of health"
					text: qsTrId("batteryalarms_state_of_health")
					dataItem.uid: root.bindPrefix + "/Alarms/StateOfHealth"
				}
			}

			DelegateComponent {
				preferredVisible: lowStarterVoltageItem.valid
				ListAlarm {
					//% "Low starter voltage"
					text: qsTrId("batteryalarms_low_starter_voltage")
					dataItem.uid: root.bindPrefix + "/Alarms/LowStarterVoltage"
				}
			}

			DelegateComponent {
				preferredVisible: highStarterVoltageItem.valid
				ListAlarm {
					//% "High starter voltage"
					text: qsTrId("batteryalarms_high_starter_voltage")
					dataItem.uid: root.bindPrefix + "/Alarms/HighStarterVoltage"
				}
			}

			DelegateComponent {
				preferredVisible: lowTemperatureItem.valid
				ListAlarm {
					text: CommonWords.low_temperature
					dataItem.uid: root.bindPrefix + "/Alarms/LowTemperature"
				}
			}

			DelegateComponent {
				preferredVisible: highTemperatureItem.valid
				ListAlarm {
					text: CommonWords.high_temperature
					dataItem.uid: root.bindPrefix + "/Alarms/HighTemperature"
				}
			}

			DelegateComponent {
				preferredVisible: batteryTemperatureSensorItem.valid
				ListAlarm {
					//% "Battery temperature sensor"
					text: qsTrId("batteryalarms_battery_temperature_sensor")
					dataItem.uid: root.bindPrefix + "/Alarms/BatteryTemperatureSensor"
				}
			}

			DelegateComponent {
				preferredVisible: midVoltageItem.valid
				ListAlarm {
					//% "Mid-point voltage"
					text: qsTrId("batteryalarms_mid_point_voltage")
					dataItem.uid: root.bindPrefix + "/Alarms/MidVoltage"
				}
			}

			DelegateComponent {
				preferredVisible: fuseBlownItem.valid
				ListAlarm {
					//% "Fuse blown"
					text: qsTrId("batteryalarms_fuse_blown")
					dataItem.uid: root.bindPrefix + "/Alarms/FuseBlown"
				}
			}

			DelegateComponent {
				preferredVisible: highInternalTemperatureItem.valid
				ListAlarm {
					//% "High internal temperature"
					text: qsTrId("batteryalarms_high_internal_temperature")
					dataItem.uid: root.bindPrefix + "/Alarms/HighInternalTemperature"
				}
			}

			DelegateComponent {
				preferredVisible: lowChargeTemperatureItem.valid
				ListAlarm {
					//% "Low charge temperature"
					text: qsTrId("batteryalarms_low_charge_temperature")
					dataItem.uid: root.bindPrefix + "/Alarms/LowChargeTemperature"
				}
			}

			DelegateComponent {
				preferredVisible: highChargeTemperatureItem.valid
				ListAlarm {
					//% "High charge temperature"
					text: qsTrId("batteryalarms_high_charge_temperature")
					dataItem.uid: root.bindPrefix + "/Alarms/HighChargeTemperature"
				}
			}

			DelegateComponent {
				preferredVisible: internalFailureItem.valid
				ListAlarm {
					//% "Internal failure"
					text: qsTrId("batteryalarms_internal_failure")
					dataItem.uid: root.bindPrefix + "/Alarms/InternalFailure"
				}
			}

			DelegateComponent {
				preferredVisible: circuitBreakerTrippedItem.valid
				ListAlarm {
					//% "Circuit breaker tripped"
					text: qsTrId("batteryalarms_circuit_breaker_tripped")
					dataItem.uid: Global.system.serviceUid + "/Dc/Battery/Alarms/CircuitBreakerTripped"
				}
			}

			DelegateComponent {
				preferredVisible: cellImbalanceItem.valid
				ListAlarm {
					//% "Cell imbalance"
					text: qsTrId("batteryalarms_cell_imbalance")
					dataItem.uid: root.bindPrefix + "/Alarms/CellImbalance"
				}
			}

			DelegateComponent {
				preferredVisible: lowCellVoltageItem.valid
				ListAlarm {
					//% "Low cell voltage"
					text: qsTrId("batteryalarms_low_cell_voltage")
					dataItem.uid: root.bindPrefix + "/Alarms/LowCellVoltage"
				}
			}

			DelegateComponent {
				preferredVisible: bmsCableItem.valid
				ListAlarm {
					//% "BMS cable fault"
					text: qsTrId("batteryalarms_bms_cable")
					dataItem.uid: root.bindPrefix + "/Alarms/BmsCable"
				}
			}

			DelegateComponent {
				preferredVisible: contactorItem.valid
				ListAlarm {
					//% "Bad contactor"
					text: qsTrId("batteryalarms_contactor")
					dataItem.uid: root.bindPrefix + "/Alarms/Contactor"
				}
			}
		}
	}
}

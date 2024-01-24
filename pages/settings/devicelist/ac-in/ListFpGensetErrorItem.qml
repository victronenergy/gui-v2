/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListTextItem {
	property int nrOfPhases: 1

	secondaryText: {
		let errorText = ""
		switch (dataItem.value) {
		case 0:
			errorText = CommonWords.no_error
			break

		/* FP errors (alarms) < 128 with two codes; 0-63: low alarm; 64-127: high alarm */
		case 1 + 0x00:
			errorText = nrOfPhases > 1
				//% "AC voltage L1 too low"
				? qsTrId("fp-genset-error_ac_voltage_l1_too_low")
				//% "AC voltage too low"
				: qsTrId("fp-genset-error_ac_voltage_too_low")
			break;
		case 1 + 0x40:
			errorText = nrOfPhases > 1
				  //% "AC voltage L1 too high"
				? qsTrId("fp-genset-error_ac_voltage_l1_too_high")
				  //% "AC voltage too high"
				: qsTrId("fp-genset-error_ac_voltage_too_high")
			break;
		case 2 + 0x00:
			errorText = nrOfPhases > 1
				  //% "AC frequency L1 too low"
				? qsTrId("fp-genset-error_ac_frequency_l1_too_low")
				  //% "AC frequency too low"
				: qsTrId("fp-genset-error_ac_frequency_too_low")
			break;
		case 2 + 0x40:
			errorText = nrOfPhases > 1
				  //% "AC frequency L1 too high"
				? qsTrId("fp-genset-error_ac_frequency_l1_too_high")
				  //% "AC frequency too high"
				: qsTrId("fp-genset-error_ac_frequency_too_high")
			break;
		case 3 + 0x00:
			errorText = nrOfPhases > 1
				  //% "AC current L1 too low"
				? qsTrId("fp-genset-error_ac_current_l1_too_low")
				  //% "AC current too low"
				: qsTrId("fp-genset-error_ac_current_too_low")
			break;
		case 3 + 0x40:
			errorText = nrOfPhases > 1
				  //% "AC current L1 too high"
				? qsTrId("fp-genset-error_ac_current_l1_too_high")
				  //% "AC current too high"
				: qsTrId("fp-genset-error_ac_current_too_high")
			break;
		case 4 + 0x00:
			errorText = nrOfPhases > 1
				  //% "AC power L1 too low"
				? qsTrId("fp-genset-error_ac_power_l1_too_low")
				  //% "AC power too low"
				: qsTrId("fp-genset-error_ac_power_too_low")
			break;
		case 4 + 0x40:
			errorText = nrOfPhases > 1
				  //% "AC power L1 too high"
				? qsTrId("fp-genset-error_ac_power_l1_too_high")
				  //% "AC power too high"
				: qsTrId("fp-genset-error_ac_power_too_high")
			break;
		//% "Emergency stop"
		case 5 + 0x00: errorText = qsTrId("fp-genset-error_emergency_stop"); break;
		//% "Servo current too low"
		case 6 + 0x00: errorText = qsTrId("fp-genset-error_servo_current_too_low"); break;
		//% "Servo current too high"
		case 6 + 0x40: errorText = qsTrId("fp-genset-error_servo_current_too_high"); break;
		//% "Oil pressure too low"
		case 7 + 0x00: errorText = qsTrId("fp-genset-error_oil_pressure_too_low"); break;
		//% "Oil pressure too high"
		case 7 + 0x40: errorText = qsTrId("fp-genset-error_oil_pressure_too_high"); break;
		//% "Engine temperature too low"
		case 8 + 0x00: errorText = qsTrId("fp-genset-error_engine_temperature_too_low"); break;
		//% "Engine temperature too high"
		case 8 + 0x40: errorText = qsTrId("fp-genset-error_engine_temperature_too_high"); break;
		//% "Winding temperature too low"
		case 9 + 0x00: errorText = qsTrId("fp-genset-error_winding_temperature_too_low"); break;
		//% "Winding temperature too high"
		case 9 + 0x40: errorText = qsTrId("fp-genset-error_winding_temperature_too_high"); break;
		//% "Exhaust temperature too low"
		case 10 + 0x00: errorText = qsTrId("fp-genset-error_exhaust_temperature_too_low"); break;
		//% "Exhaust temperature too high"
		case 10 + 0x40: errorText = qsTrId("fp-genset-error_exhaust_temperature_too_high"); break;
		//% "Starter current too low"
		case 13 + 0x00: errorText = qsTrId("fp-genset-error_starter_current_too_low"); break;
		//% "Starter current too high"
		case 13 + 0x40: errorText = qsTrId("fp-genset-error_starter_current_too_high"); break;
		//% "Glow current too low"
		case 14 + 0x00: errorText = qsTrId("fp-genset-error_glow_current_too_low"); break;
		//% "Glow current too high"
		case 14 + 0x40: errorText = qsTrId("fp-genset-error_glow_current_too_high"); break;
		//% "Glow current too low"
		case 15 + 0x00: errorText = qsTrId("fp-genset-error_glow_current_too_low"); break;
		//% "Glow current too high"
		case 15 + 0x40: errorText = qsTrId("fp-genset-error_glow_current_too_high"); break;
		//% "Fuel holding magnet current too low"
		case 16 + 0x00: errorText = qsTrId("fp-genset-error_fuel_holding_magnet_current_too_low"); break;
		//% "Fuel holding magnet current too high"
		case 16 + 0x40: errorText = qsTrId("fp-genset-error_fuel_holding_magnet_current_too_high"); break;
		//% "Stop solenoid hold coil current too low"
		case 17 + 0x00: errorText = qsTrId("fp-genset-error_stop_solenoid_hold_coil_current_too_low"); break;
		//% "Stop solenoid hold coil current too high"
		case 17 + 0x40: errorText = qsTrId("fp-genset-error_stop_solenoid_hold_coil_current_too_high"); break;
		//% "Stop solenoid pull coil current too low "
		case 18 + 0x00: errorText = qsTrId("fp-genset-error_stop_solenoid_pull_coil_current_too_low_"); break;
		//% "Stop solenoid pull coil current too high"
		case 18 + 0x40: errorText = qsTrId("fp-genset-error_stop_solenoid_pull_coil_current_too_high"); break;
		//% "Optional DC out current too low"
		case 19 + 0x00: errorText = qsTrId("fp-genset-error_optional_dc_out_current_too_low"); break;
		//% "Optional DC out current too high"
		case 19 + 0x40: errorText = qsTrId("fp-genset-error_optional_dc_out_current_too_high"); break;
		//% "5V output voltage too low"
		case 20 + 0x00: errorText = qsTrId("fp-genset-error_5v_output_voltage_too_low"); break;
		//% "5V output current too high"
		case 20 + 0x40: errorText = qsTrId("fp-genset-error_5v_output_current_too_high"); break;
		//% "Boost output current too low"
		case 21 + 0x00: errorText = qsTrId("fp-genset-error_boost_output_current_too_low"); break;
		//% "Boost output current too high"
		case 21 + 0x40: errorText = qsTrId("fp-genset-error_boost_output_current_too_high"); break;
		//% "Panel supply current too high"
		case 22 + 0x40: errorText = qsTrId("fp-genset-error_panel_supply_current_too_high"); break;
		//% "Starter battery voltage too low"
		case 25 + 0x00: errorText = qsTrId("fp-genset-error_starter_battery_voltage_too_low"); break;
		//% "Starter battery voltage too high"
		case 25 + 0x40: errorText = qsTrId("fp-genset-error_starter_battery_voltage_too_high"); break;
		//% "Startup aborted (rotation too low"
		case 26 + 0x00: errorText = qsTrId("fp-genset-error_startup_aborted_(rotation_too_low"); break;
		//% "Startup aborted (rotation too high"
		case 26 + 0x40: errorText = qsTrId("fp-genset-error_startup_aborted_(rotation_too_high"); break;
		//% "Rotation too low"
		case 28 + 0x00: errorText = qsTrId("fp-genset-error_rotation_too_low"); break;
		//% "Rotation too high"
		case 28 + 0x40: errorText = qsTrId("fp-genset-error_rotation_too_high"); break;
		//% "Power contactor current too low"
		case 29 + 0x00: errorText = qsTrId("fp-genset-error_power_contactor_current_too_low"); break;
		//% "Power contactor current too high"
		case 29 + 0x40: errorText = qsTrId("fp-genset-error_power_contactor_current_too_high"); break;
		//% "AC voltage L2 too low"
		case 30 + 0x00: errorText = qsTrId("fp-genset-error_ac_voltage_l2_too_low"); break;
		//% "AC voltage L2 too high"
		case 30 + 0x40: errorText = qsTrId("fp-genset-error_ac_voltage_l2_too_high"); break;
		//% "AC frequency L2 too low"
		case 31 + 0x00: errorText = qsTrId("fp-genset-error_ac_frequency_l2_too_low"); break;
		//% "AC frequency L2 too high"
		case 31 + 0x40: errorText = qsTrId("fp-genset-error_ac_frequency_l2_too_high"); break;
		//% "AC current L2 too low"
		case 32 + 0x00: errorText = qsTrId("fp-genset-error_ac_current_l2_too_low"); break;
		//% "AC current L2 too high"
		case 32 + 0x40: errorText = qsTrId("fp-genset-error_ac_current_l2_too_high"); break;
		//% "AC power L2 too low"
		case 33 + 0x00: errorText = qsTrId("fp-genset-error_ac_power_l2_too_low"); break;
		//% "AC power L2 too high"
		case 33 + 0x40: errorText = qsTrId("fp-genset-error_ac_power_l2_too_high"); break;
		//% "AC voltage L3 too low"
		case 34 + 0x00: errorText = qsTrId("fp-genset-error_ac_voltage_l3_too_low"); break;
		//% "AC voltage L3 too high"
		case 34 + 0x40: errorText = qsTrId("fp-genset-error_ac_voltage_l3_too_high"); break;
		//% "AC frequency L3 too low"
		case 35 + 0x00: errorText = qsTrId("fp-genset-error_ac_frequency_l3_too_low"); break;
		//% "AC frequency L3 too high"
		case 35 + 0x40: errorText = qsTrId("fp-genset-error_ac_frequency_l3_too_high"); break;
		//% "AC current L3 too low"
		case 36 + 0x00: errorText = qsTrId("fp-genset-error_ac_current_l3_too_low"); break;
		//% "AC current L3 too high"
		case 36 + 0x40: errorText = qsTrId("fp-genset-error_ac_current_l3_too_high"); break;
		//% "AC power L3 too low"
		case 37 + 0x00: errorText = qsTrId("fp-genset-error_ac_power_l3_too_low"); break;
		//% "AC power L3 too high"
		case 37 + 0x40: errorText = qsTrId("fp-genset-error_ac_power_l3_too_high"); break;
		//% "Fuel temperature too low"
		case 62 + 0x00: errorText = qsTrId("fp-genset-error_fuel_temperature_too_low"); break;
		//% "Fuel temperature too high"
		case 62 + 0x40: errorText = qsTrId("fp-genset-error_fuel_temperature_too_high"); break;
		//% "Fuel level too low"
		case 63 + 0x00: errorText = qsTrId("fp-genset-error_fuel_level_too_low"); break;
		//% "Fuel level too high"
		case 63 + 0x40: errorText = qsTrId("fp-genset-error_fuel_level_too_high"); break;

		/* FP errors (>= 128) with one code */
		//% "Lost control unit"
		case 130: errorText = qsTrId("fp-genset-error_lost_control_unit"); break;
		//% "Lost panel"
		case 131: errorText = qsTrId("fp-genset-error_lost_panel"); break;
		//% "Service needed"
		case 132: errorText = qsTrId("fp-genset-error_service_needed"); break;
		//% "Lost 3-phase module"
		case 133: errorText = qsTrId("fp-genset-error_lost_3-phase_module"); break;
		//% "Lost AGT module"
		case 134: errorText = qsTrId("fp-genset-error_lost_agt_module"); break;
		//% "Synchronization failure"
		case 135: errorText = qsTrId("fp-genset-error_synchronization_failure"); break;
		//% "Intake airfilter"
		case 137: errorText = qsTrId("fp-genset-error_intake_airfilter"); break;
		//% "Lost sync. module"
		case 139: errorText = qsTrId("fp-genset-error_lost_sync._module"); break;
		//% "Load-balance failed"
		case 140: errorText = qsTrId("fp-genset-error_load-balance_failed"); break;
		//% "Sync-mode deactivated"
		case 141: errorText = qsTrId("fp-genset-error_sync-mode_deactivated"); break;
		//% "Engine controller"
		case 142: errorText = qsTrId("fp-genset-error_engine_controller"); break;
		//% "Rotating field wrong"
		case 148: errorText = qsTrId("fp-genset-error_rotating_field_wrong"); break;
		//% "Fuel level sensor lost"
		case 149: errorText = qsTrId("fp-genset-error_fuel_level_sensor_lost"); break;

		/* FP error codes for iControl only */
		//% "Init failed"
		case 150: errorText = qsTrId("fp-genset-error_init_failed"); break;
		//% "Watchdog"
		case 151: errorText = qsTrId("fp-genset-error_watchdog"); break;
		//% "Out: winding"
		case 152: errorText = qsTrId("fp-genset-error_out_winding"); break;
		//% "Out: exhaust"
		case 153: errorText = qsTrId("fp-genset-error_out_exhaust"); break;
		//% "Out: Cyl. head"
		case 154: errorText = qsTrId("fp-genset-error_out_cyl_head"); break;
		//% "Inverter over temperature"
		case 155: errorText = qsTrId("fp-genset-error_inverter_over_temperature"); break;
		//% "Inverter overload"
		case 156: errorText = qsTrId("fp-genset-error_inverter_overload"); break;
		//% "Inverter communication lost"
		case 157: errorText = qsTrId("fp-genset-error_inverter_communication_lost"); break;
		//% "Inverter sync failed"
		case 158: errorText = qsTrId("fp-genset-error_inverter_sync_failed"); break;
		//% "CAN communication lost"
		case 159: errorText = qsTrId("fp-genset-error_can_communication_lost"); break;
		//% "L1 overload"
		case 160: errorText = qsTrId("fp-genset-error_l1_overload"); break;
		//% "L2 overload"
		case 161: errorText = qsTrId("fp-genset-error_l2_overload"); break;
		//% "L3 overload"
		case 162: errorText = qsTrId("fp-genset-error_l3_overload"); break;
		//% "DC overload"
		case 163: errorText = qsTrId("fp-genset-error_dc_overload"); break;
		//% "DC overvoltage"
		case 164: errorText = qsTrId("fp-genset-error_dc_overvoltage"); break;
		//% "Emergency stop"
		case 165: errorText = qsTrId("fp-genset-error_emergency_stop"); break;
		//% "No connection"
		case 166: errorText = qsTrId("fp-genset-error_no_connection"); break;

		/* DSE error codes 0x1000 to 0x10FF: DSE old alarm system */
		case 0x1000: errorText = "Emergency stop"; break;
		case 0x1001: errorText = "Low oil pressure"; break;
		case 0x1002: errorText = "High coolant temperature"; break;
		case 0x1003: errorText = "High oil temperature"; break;
		case 0x1004: errorText = "Under speed"; break;
		case 0x1005: errorText = "Over speed"; break;
		case 0x1006: errorText = "Fail to start"; break;
		case 0x1007: errorText = "Fail to come to rest"; break;
		case 0x1008: errorText = "Loss of speed sensing"; break;
		case 0x1009: errorText = "Generator low voltage"; break;
		case 0x100a: errorText = "Generator high voltage"; break;
		case 0x100b: errorText = "Generator low frequency"; break;
		case 0x100c: errorText = "Generator high frequency"; break;
		case 0x100d: errorText = "Generator high current"; break;
		case 0x100e: errorText = "Generator earth fault"; break;
		case 0x100f: errorText = "Generator reverse power"; break;
		case 0x1010: errorText = "Air flap"; break;
		case 0x1011: errorText = "Oil pressure sender fault"; break;
		case 0x1012: errorText = "Coolant temperature sender fault"; break;
		case 0x1013: errorText = "Oil temperature sender fault"; break;
		case 0x1014: errorText = "Fuel level sender fault"; break;
		case 0x1015: errorText = "Magnetic pickup fault"; break;
		case 0x1016: errorText = "Loss of AC speed signal"; break;
		case 0x1017: errorText = "Charge alternator failure"; break;
		case 0x1018: errorText = "Low battery voltage"; break;
		case 0x1019: errorText = "High battery voltage"; break;
		case 0x101a: errorText = "Low fuel level"; break;
		case 0x101b: errorText = "High fuel level"; break;
		case 0x101c: errorText = "Generator failed to close"; break;
		case 0x101d: errorText = "Mains failed to close"; break;
		case 0x101e: errorText = "Generator failed to open"; break;
		case 0x101f: errorText = "Mains failed to open"; break;
		case 0x1020: errorText = "Mains low voltage"; break;
		case 0x1021: errorText = "Mains high voltage"; break;
		case 0x1022: errorText = "Bus failed to close"; break;
		case 0x1023: errorText = "Bus failed to open"; break;
		case 0x1024: errorText = "Mains low frequency"; break;
		case 0x1025: errorText = "Mains high frequency"; break;
		case 0x1026: errorText = "Mains failed"; break;
		case 0x1027: errorText = "Mains phase rotation wrong"; break;
		case 0x1028: errorText = "Generator phase rotation wrong"; break;
		case 0x1029: errorText = "Maintenance due"; break;
		case 0x102a: errorText = "Clock not set"; break;
		case 0x102b: errorText = "Local LCD configuration lost"; break;
		case 0x102c: errorText = "Local telemetry configuration lost"; break;
		case 0x102d: errorText = "Control unit not calibrated"; break;
		case 0x102e: errorText = "Modem power fault"; break;
		case 0x102f: errorText = "Generator short circuit"; break;
		case 0x1030: errorText = "Failure to synchronise"; break;
		case 0x1031: errorText = "Bus live"; break;
		case 0x1032: errorText = "Scheduled run"; break;
		case 0x1033: errorText = "Bus phase rotation wrong"; break;
		case 0x1034: errorText = "Priority selection error"; break;
		case 0x1035: errorText = "Multiset communications (MSC) data error"; break;
		case 0x1036: errorText = "Multiset communications (MSC) ID error"; break;
		case 0x1037: errorText = "Multiset communications (MSC) failure"; break;
		case 0x1038: errorText = "Multiset communications (MSC) too few sets"; break;
		case 0x1039: errorText = "Multiset communications (MSC) alarms inhibited"; break;
		case 0x103a: errorText = "Multiset communications (MSC) old version units"; break;
		case 0x103b: errorText = "Mains reverse power"; break;
		case 0x103c: errorText = "Minimum sets not reached"; break;
		case 0x103d: errorText = "Insufficient capacity available"; break;
		case 0x103e: errorText = "Expansion input unit not calibrated"; break;
		case 0x103f: errorText = "Expansion input unit failure"; break;
		case 0x1040: errorText = "Auxiliary sender 1 low"; break;
		case 0x1041: errorText = "Auxiliary sender 1 high"; break;
		case 0x1042: errorText = "Auxiliary sender 1 fault"; break;
		case 0x1043: errorText = "Auxiliary sender 2 low"; break;
		case 0x1044: errorText = "Auxiliary sender 2 high"; break;
		case 0x1045: errorText = "Auxiliary sender 2 fault"; break;
		case 0x1046: errorText = "Auxiliary sender 3 low"; break;
		case 0x1047: errorText = "Auxiliary sender 3 high"; break;
		case 0x1048: errorText = "Auxiliary sender 3 fault"; break;
		case 0x1049: errorText = "Auxiliary sender 4 low"; break;
		case 0x104a: errorText = "Auxiliary sender 4 high"; break;
		case 0x104b: errorText = "Auxiliary sender 4 fault"; break;
		case 0x104c: errorText = "Engine control unit (ECU) link lost"; break;
		case 0x104d: errorText = "Engine control unit (ECU) failure"; break;
		case 0x104e: errorText = "Engine control unit (ECU) error"; break;
		case 0x104f: errorText = "Low coolant temperature"; break;
		case 0x1050: errorText = "Out of sync"; break;
		case 0x1051: errorText = "Low Oil Pressure Switch"; break;
		case 0x1052: errorText = "Alternative Auxiliary Mains Fail"; break;
		case 0x1053: errorText = "Loss of excitation"; break;
		case 0x1054: errorText = "Mains kW Limit"; break;
		case 0x1055: errorText = "Negative phase sequence"; break;
		case 0x1056: errorText = "Mains ROCOF"; break;
		case 0x1057: errorText = "Mains vector shift"; break;
		case 0x1058: errorText = "Mains G59 low frequency"; break;
		case 0x1059: errorText = "Mains G59 high frequency"; break;
		case 0x105a: errorText = "Mains G59 low voltage"; break;
		case 0x105b: errorText = "Mains G59 high voltage"; break;
		case 0x105c: errorText = "Mains G59 trip"; break;
		case 0x105d: errorText = "Generator kW Overload"; break;
		case 0x105e: errorText = "Engine Inlet Temperature high"; break;
		case 0x105f: errorText = "Bus 1 live"; break;
		case 0x1060: errorText = "Bus 1 phase rotation wrong"; break;
		case 0x1061: errorText = "Bus 2 live"; break;
		case 0x1062: errorText = "Bus 2 phase rotation wrong"; break;

		/* DSE error codes 0x1100 to 0x11FF: DSE 61xx MKII */
		case 0x1100: errorText = "Emergency stop"; break;
		case 0x1101: errorText = "Low oil pressure"; break;
		case 0x1102: errorText = "High coolant temperature"; break;
		case 0x1103: errorText = "Low coolant temperature"; break;
		case 0x1104: errorText = "Under speed"; break;
		case 0x1105: errorText = "Over speed"; break;
		case 0x1106: errorText = "Generator Under frequency"; break;
		case 0x1107: errorText = "Generator Over frequency"; break;
		case 0x1108: errorText = "Generator low voltage"; break;
		case 0x1109: errorText = "Generator high voltage"; break;
		case 0x110a: errorText = "Battery low voltage"; break;
		case 0x110b: errorText = "Battery high voltage"; break;
		case 0x110c: errorText = "Charge alternator failure"; break;
		case 0x110d: errorText = "Fail to start"; break;
		case 0x110e: errorText = "Fail to stop"; break;
		case 0x110f: errorText = "Generator fail to close"; break;
		case 0x1110: errorText = "Mains fail to close"; break;
		case 0x1111: errorText = "Oil pressure sender fault"; break;
		case 0x1112: errorText = "Loss of magnetic pick up"; break;
		case 0x1113: errorText = "Magnetic pick up open circuit"; break;
		case 0x1114: errorText = "Generator high current"; break;
		case 0x1115: errorText = "Calibration lost"; break;
		case 0x1116: errorText = "Low fuel level"; break;
		case 0x1117: errorText = "CAN ECU Warning"; break;
		case 0x1118: errorText = "CAN ECU Shutdown"; break;
		case 0x1119: errorText = "CAN ECU Data fail"; break;
		case 0x111a: errorText = "Low oil level switch"; break;
		case 0x111b: errorText = "High temperature switch"; break;
		case 0x111c: errorText = "Low fuel level switch"; break;
		case 0x111d: errorText = "Expansion unit watchdog alarm"; break;
		case 0x111e: errorText = "kW overload alarm"; break;
		case 0x1123: errorText = "Maintenance alarm"; break;
		case 0x1124: errorText = "Loading frequency alarm"; break;
		case 0x1125: errorText = "Loading voltage alarm"; break;
		case 0x112e: errorText = "ECU protect"; break;
		case 0x112f: errorText = "ECU Malfunction"; break;
		case 0x1130: errorText = "ECU Information"; break;
		case 0x1131: errorText = "ECU Shutdown"; break;
		case 0x1132: errorText = "ECU Warning"; break;
		case 0x1133: errorText = "ECU HEST"; break;
		case 0x1135: errorText = "ECU Water In Fuel"; break;
		case 0x1139: errorText = "High fuel level"; break;
		case 0x113a: errorText = "DEF Level Low"; break;
		case 0x113b: errorText = "SCR Inducement"; break;

		/* DSE error codes 0x1200 to 0x12FF: DSE 72xx/73xx/61xx/74xx MKII family */
		case 0x1200: errorText = "Emergency stop"; break;
		case 0x1201: errorText = "Low oil pressure"; break;
		case 0x1202: errorText = "High coolant temperature"; break;
		case 0x1203: errorText = "Low coolant temperature"; break;
		case 0x1204: errorText = "Under speed"; break;
		case 0x1205: errorText = "Over speed"; break;
		case 0x1206: errorText = "Generator Under frequency"; break;
		case 0x1207: errorText = "Generator Over frequency"; break;
		case 0x1208: errorText = "Generator low voltage"; break;
		case 0x1209: errorText = "Generator high voltage"; break;
		case 0x120a: errorText = "Battery low voltage"; break;
		case 0x120b: errorText = "Battery high voltage"; break;
		case 0x120c: errorText = "Charge alternator failure"; break;
		case 0x120d: errorText = "Fail to start"; break;
		case 0x120e: errorText = "Fail to stop"; break;
		case 0x120f: errorText = "Generator fail to close"; break;
		case 0x1210: errorText = "Mains fail to close"; break;
		case 0x1211: errorText = "Oil pressure sender fault"; break;
		case 0x1212: errorText = "Loss of magnetic pick up"; break;
		case 0x1213: errorText = "Magnetic pick up open circuit"; break;
		case 0x1214: errorText = "Generator high current"; break;
		case 0x1215: errorText = "Calibration lost"; break;
		case 0x1216: errorText = "Low fuel level"; break;
		case 0x1217: errorText = "CAN ECU Warning"; break;
		case 0x1218: errorText = "CAN ECU Shutdown"; break;
		case 0x1219: errorText = "CAN ECU Data fail"; break;
		case 0x121a: errorText = "Low oil level switch"; break;
		case 0x121b: errorText = "High temperature switch"; break;
		case 0x121c: errorText = "Low fuel level switch"; break;
		case 0x121d: errorText = "Expansion unit watchdog alarm"; break;
		case 0x121e: errorText = "kW overload alarm"; break;
		case 0x121f: errorText = "Negative phase sequence current alarm"; break;
		case 0x1220: errorText = "Earth fault trip alarm"; break;
		case 0x1221: errorText = "Generator phase rotation alarm"; break;
		case 0x1222: errorText = "Auto Voltage Sense Fail"; break;
		case 0x1223: errorText = "Maintenance alarm"; break;
		case 0x1224: errorText = "Loading frequency alarm"; break;
		case 0x1225: errorText = "Loading voltage alarm"; break;
		case 0x1226: errorText = "Fuel usage running"; break;
		case 0x1227: errorText = "Fuel usage stopped"; break;
		case 0x1228: errorText = "Protections disabled"; break;
		case 0x1229: errorText = "Protections blocked"; break;
		case 0x122a: errorText = "Generator Short Circuit"; break;
		case 0x122b: errorText = "Mains High Current"; break;
		case 0x122c: errorText = "Mains Earth Fault"; break;
		case 0x122d: errorText = "Mains Short Circuit"; break;
		case 0x122e: errorText = "ECU protect"; break;
		case 0x122f: errorText = "ECU Malfunction"; break;
		case 0x1230: errorText = "ECU Information"; break;
		case 0x1231: errorText = "ECU Shutdown"; break;
		case 0x1232: errorText = "ECU Warning"; break;
		case 0x1233: errorText = "ECU Electrical Trip"; break;
		case 0x1234: errorText = "ECU After treatment"; break;
		case 0x1235: errorText = "ECU Water In Fuel"; break;
		case 0x1236: errorText = "Generator Reverse Power"; break;
		case 0x1237: errorText = "Generator Positive VAr"; break;
		case 0x1238: errorText = "Generator Negative VAr"; break;
		case 0x1239: errorText = "LCD Heater Low Voltage"; break;
		case 0x123a: errorText = "LCD Heater High Voltage"; break;
		case 0x123b: errorText = "DEF Level Low"; break;
		case 0x123c: errorText = "SCR Inducement"; break;
		case 0x123d: errorText = "MSC Old version"; break;
		case 0x123e: errorText = "MSC ID alarm"; break;
		case 0x123f: errorText = "MSC failure"; break;
		case 0x1240: errorText = "MSC priority Error"; break;
		case 0x1241: errorText = "Fuel Sender open circuit"; break;
		case 0x1242: errorText = "Over speed runaway"; break;
		case 0x1243: errorText = "Over frequency run away"; break;
		case 0x1244: errorText = "Coolant sensor open circuit"; break;
		case 0x1245: errorText = "Remote display link lost"; break;
		case 0x1246: errorText = "Fuel tank bund level"; break;
		case 0x1247: errorText = "Charge air temperature"; break;
		case 0x1248: errorText = "Fuel level high"; break;
		case 0x1249: errorText = "Gen breaker failed to open (v5.0+)"; break;
		case 0x124a: errorText = "Mains breaker failed to open (v5.0+) – 7x20 only"; break;
		case 0x124b: errorText = "Fail to synchronise (v5.0+) – 7x20 only"; break;
		case 0x124c: errorText = "AVR Data Fail (v5.0+)"; break;
		case 0x124d: errorText = "AVR DM1 Red Stop Lamp (v5.0+)"; break;
		case 0x124e: errorText = "Escape Mode (v5.0+)"; break;
		case 0x124f: errorText = "Coolant high temp electrical trip (v5.0+)"; break;

		/* DSE error codes 0x1300 to 0x13FF: DSE 8xxx family */
		case 0x1300: errorText = "Emergency stop"; break;
		case 0x1301: errorText = "Low oil pressure"; break;
		case 0x1302: errorText = "High coolant temperature"; break;
		case 0x1303: errorText = "Low coolant temperature"; break;
		case 0x1304: errorText = "Under speed"; break;
		case 0x1305: errorText = "Over speed"; break;
		case 0x1306: errorText = "Generator Under frequency"; break;
		case 0x1307: errorText = "Generator Over frequency"; break;
		case 0x1308: errorText = "Generator low voltage"; break;
		case 0x1309: errorText = "Generator high voltage"; break;
		case 0x130a: errorText = "Battery low voltage"; break;
		case 0x130b: errorText = "Battery high voltage"; break;
		case 0x130c: errorText = "Charge alternator failure"; break;
		case 0x130d: errorText = "Fail to start"; break;
		case 0x130e: errorText = "Fail to stop"; break;
		case 0x130f: errorText = "Generator fail to close"; break;
		case 0x1310: errorText = "Mains fail to close"; break;
		case 0x1311: errorText = "Oil pressure sender fault"; break;
		case 0x1312: errorText = "Loss of magnetic pick up"; break;
		case 0x1313: errorText = "Magnetic pick up open circuit"; break;
		case 0x1314: errorText = "Generator high current"; break;
		case 0x1315: errorText = "Calibration lost"; break;
		case 0x1316: errorText = "Low fuel level"; break;
		case 0x1317: errorText = "CAN ECU Warning"; break;
		case 0x1318: errorText = "CAN ECU Shutdown"; break;
		case 0x1319: errorText = "CAN ECU Data fail"; break;
		case 0x131a: errorText = "Low oil level switch"; break;
		case 0x131b: errorText = "High temperature switch"; break;
		case 0x131c: errorText = "Low fuel level switch"; break;
		case 0x131d: errorText = "Expansion unit watchdog alarm"; break;
		case 0x131e: errorText = "kW overload alarm"; break;
		case 0x131f: errorText = "Negative phase sequence current alarm"; break;
		case 0x1320: errorText = "Earth fault trip alarm"; break;
		case 0x1321: errorText = "Generator phase rotation alarm"; break;
		case 0x1322: errorText = "Auto Voltage Sense Fail"; break;
		case 0x1323: errorText = "Maintenance alarm"; break;
		case 0x1324: errorText = "Loading frequency alarm"; break;
		case 0x1325: errorText = "Loading voltage alarm"; break;
		case 0x1326: errorText = "Fuel usage running"; break;
		case 0x1327: errorText = "Fuel usage stopped"; break;
		case 0x1328: errorText = "Protections disabled"; break;
		case 0x1329: errorText = "Protections blocked"; break;
		case 0x132a: errorText = "Generator breaker failed to open"; break;
		case 0x132b: errorText = "Mains breaker failed to open"; break;
		case 0x132c: errorText = "Bus breaker failed to close"; break;
		case 0x132d: errorText = "Bus breaker failed to open"; break;
		case 0x132e: errorText = "Generator reverse power alarm"; break;
		case 0x132f: errorText = "Short circuit alarm"; break;
		case 0x1330: errorText = "Air flap closed alarm"; break;
		case 0x1331: errorText = "Failure to sync"; break;
		case 0x1332: errorText = "Bus live"; break;
		case 0x1333: errorText = "Bus not live"; break;
		case 0x1334: errorText = "Bus phase rotation"; break;
		case 0x1335: errorText = "Priority selection error"; break;
		case 0x1336: errorText = "MSC data error"; break;
		case 0x1337: errorText = "MSC ID error"; break;
		case 0x1338: errorText = "Bus low voltage"; break;
		case 0x1339: errorText = "Bus high voltage"; break;
		case 0x133a: errorText = "Bus low frequency"; break;
		case 0x133b: errorText = "Bus high frequency"; break;
		case 0x133c: errorText = "MSC failure"; break;
		case 0x133d: errorText = "MSC too few sets"; break;
		case 0x133e: errorText = "MSC alarms inhibited"; break;
		case 0x133f: errorText = "MSC old version units on the bus"; break;
		case 0x1340: errorText = "Mains reverse power alarm/mains export alarm"; break;
		case 0x1341: errorText = "Minimum sets not reached"; break;
		case 0x1342: errorText = "Insufficient capacity"; break;
		case 0x1343: errorText = "Out of sync"; break;
		case 0x1344: errorText = "Alternative aux mains fail"; break;
		case 0x1345: errorText = "Loss of excitation"; break;
		case 0x1346: errorText = "Mains ROCOF"; break;
		case 0x1347: errorText = "Mains vector shift"; break;
		case 0x1348: errorText = "Mains decoupling low frequency stage 1"; break;
		case 0x1349: errorText = "Mains decoupling high frequency stage 1"; break;
		case 0x134a: errorText = "Mains decoupling low voltage stage 1"; break;
		case 0x134b: errorText = "Mains decoupling high voltage stage 1"; break;
		case 0x134c: errorText = "Mains decoupling combined alarm"; break;
		case 0x134d: errorText = "Inlet Temperature"; break;
		case 0x134e: errorText = "Mains phase rotation alarm identifier"; break;
		case 0x134f: errorText = "AVR Max Trim Limit alarm"; break;
		case 0x1350: errorText = "High coolant temperature electrical trip alarm"; break;
		case 0x1351: errorText = "Temperature sender open circuit alarm"; break;
		case 0x1352: errorText = "Out of sync Bus"; break;
		case 0x1353: errorText = "Out of sync Mains"; break;
		case 0x1354: errorText = "Bus 1 Live"; break;
		case 0x1355: errorText = "Bus 1 Phase Rotation"; break;
		case 0x1356: errorText = "Bus 2 Live"; break;
		case 0x1357: errorText = "Bus 2 Phase Rotation"; break;
		case 0x1359: errorText = "ECU Protect"; break;
		case 0x135a: errorText = "ECU Malfunction"; break;
		case 0x135b: errorText = "Indication"; break;
		case 0x135e: errorText = "HEST Active"; break;
		case 0x135f: errorText = "DPTC Filter"; break;
		case 0x1360: errorText = "Water In Fuel"; break;
		case 0x1361: errorText = "ECU Heater"; break;
		case 0x1362: errorText = "ECU Cooler"; break;
		case 0x136c: errorText = "High fuel level"; break;
		case 0x136e: errorText = "Module Communication Fail (8661)"; break;
		case 0x136f: errorText = "Bus Module Warning (8661)"; break;
		case 0x1370: errorText = "Bus Module Trip (8661)"; break;
		case 0x1371: errorText = "Mains Module Warning (8661)"; break;
		case 0x1372: errorText = "Mains Module Trip (8661)"; break;
		case 0x1373: errorText = "Load Live (8661)"; break;
		case 0x1374: errorText = "Load Not Live (8661)"; break;
		case 0x1375: errorText = "Load Phase Rotation (8661)"; break;
		case 0x1376: errorText = "DEF Level Low"; break;
		case 0x1377: errorText = "SCR Inducement"; break;
		case 0x1378: errorText = "Heater Sensor Failure Alarm"; break;
		case 0x1379: errorText = "Mains Over Zero Sequence Volts Alarm"; break;
		case 0x137a: errorText = "Mains Under Positive Sequence Volts Alarm"; break;
		case 0x137b: errorText = "Mains Over Negative Sequence Volts Alarm"; break;
		case 0x137c: errorText = "Mains Asymmetry High Alarm"; break;
		case 0x137d: errorText = "Bus Over Zero Sequence Volts Alarm"; break;
		case 0x137e: errorText = "Bus Under Positive Sequence Volts Alarm"; break;
		case 0x137f: errorText = "Bus Over Negative Sequence Volts Alarm"; break;
		case 0x1380: errorText = "Bus Asymmetry High Alarm"; break;
		case 0x1381: errorText = "E-Trip Stop Inhibited"; break;
		case 0x1382: errorText = "Fuel Tank Bund Level High"; break;
		case 0x1383: errorText = "MSC Link 1 Data Error"; break;
		case 0x1384: errorText = "MSC Link 2 Data Error"; break;
		case 0x1385: errorText = "Bus 2 Low Voltage"; break;
		case 0x1386: errorText = "Bus 2 High Voltage"; break;
		case 0x1387: errorText = "Bus 2 Low Frequency"; break;
		case 0x1388: errorText = "Bus 2 High Frequency"; break;
		case 0x1389: errorText = "MSC Link 1 Failure"; break;
		case 0x138a: errorText = "MSC Link 2 Failure"; break;
		case 0x138b: errorText = "MSC Link 1 Too Few Sets"; break;
		case 0x138c: errorText = "MSC Link 2 Too Few Sets"; break;
		case 0x138d: errorText = "MSC Link 1 and 2 Failure"; break;
		case 0x138e: errorText = "Electrical Trip from 8660"; break;
		case 0x138f: errorText = "AVR CAN DM1 Red Stop Lamp Fault"; break;
		case 0x1390: errorText = "Gen Over Zero Sequence Volts Alarm"; break;
		case 0x1391: errorText = "Gen Under Positive Sequence Volts Alarm"; break;
		case 0x1392: errorText = "Gen Over Negative Sequence Volts Alarm"; break;
		case 0x1393: errorText = "Gen Asymmetry High Alarm"; break;
		case 0x1394: errorText = "Mains decoupling low frequency stage 2"; break;
		case 0x1395: errorText = "Mains decoupling high frequency stage 2"; break;
		case 0x1396: errorText = "Mains decoupling low voltage stage 2"; break;
		case 0x1397: errorText = "Mains decoupling high voltage stage 2"; break;
		case 0x1398: errorText = "Fault Ride Through event"; break;
		case 0x1399: errorText = "AVR Data Fail"; break;
		case 0x139a: errorText = "AVR Red Lamp"; break;

		/* DSE error codes 0x1400 to 0x14FF: DSE 7450 */
		case 0x1400: errorText = "Emergency stop"; break;
		case 0x1401: errorText = "Low oil pressure"; break;
		case 0x1402: errorText = "High coolant temperature"; break;
		case 0x1403: errorText = "Low coolant temperature"; break;
		case 0x1404: errorText = "Under speed"; break;
		case 0x1405: errorText = "Over speed"; break;
		case 0x1406: errorText = "Generator Under frequency"; break;
		case 0x1407: errorText = "Generator Over frequency"; break;
		case 0x1408: errorText = "Generator low voltage"; break;
		case 0x1409: errorText = "Generator high voltage"; break;
		case 0x140a: errorText = "Battery low voltage"; break;
		case 0x140b: errorText = "Battery high voltage"; break;
		case 0x140c: errorText = "Charge alternator failure"; break;
		case 0x140d: errorText = "Fail to start"; break;
		case 0x140e: errorText = "Fail to stop"; break;
		case 0x140f: errorText = "Generator fail to close"; break;
		case 0x1410: errorText = "Mains fail to close"; break;
		case 0x1411: errorText = "Oil pressure sender fault"; break;
		case 0x1412: errorText = "Loss of magnetic pick up"; break;
		case 0x1413: errorText = "Magnetic pick up open circuit"; break;
		case 0x1414: errorText = "Generator high current"; break;
		case 0x1415: errorText = "Calibration lost"; break;
		case 0x1416: errorText = "Low fuel level"; break;
		case 0x1417: errorText = "CAN ECU Warning"; break;
		case 0x1418: errorText = "CAN ECU Shutdown"; break;
		case 0x1419: errorText = "CAN ECU Data fail"; break;
		case 0x141a: errorText = "Low oil level switch"; break;
		case 0x141b: errorText = "High temperature switch"; break;
		case 0x141c: errorText = "Low fuel level switch"; break;
		case 0x141d: errorText = "Expansion unit watchdog alarm"; break;
		case 0x141e: errorText = "kW overload alarm"; break;
		case 0x141f: errorText = "Negative phase sequence current alarm"; break;
		case 0x1420: errorText = "Earth fault trip alarm"; break;
		case 0x1421: errorText = "Generator phase rotation alarm"; break;
		case 0x1422: errorText = "Auto Voltage Sense Fail"; break;
		case 0x1423: errorText = "Maintenance alarm"; break;
		case 0x1424: errorText = "Loading frequency alarm"; break;
		case 0x1425: errorText = "Loading voltage alarm"; break;
		case 0x1426: errorText = "Fuel usage running"; break;
		case 0x1427: errorText = "Fuel usage stopped"; break;
		case 0x1428: errorText = "Protections disabled"; break;
		case 0x1429: errorText = "Protections blocked"; break;
		case 0x142a: errorText = "Generator breaker failed to open"; break;
		case 0x142b: errorText = "Mains breaker failed to open"; break;
		case 0x142c: errorText = "Bus breaker failed to close"; break;
		case 0x142d: errorText = "Bus breaker failed to open"; break;
		case 0x142e: errorText = "Generator reverse power alarm"; break;
		case 0x142f: errorText = "Short circuit alarm"; break;
		case 0x1430: errorText = "Air flap closed alarm"; break;
		case 0x1431: errorText = "Failure to sync"; break;
		case 0x1432: errorText = "Bus live"; break;
		case 0x1433: errorText = "Bus not live"; break;
		case 0x1434: errorText = "Bus phase rotation"; break;
		case 0x1435: errorText = "Priority selection error"; break;
		case 0x1436: errorText = "MSC data error"; break;
		case 0x1437: errorText = "MSC ID error"; break;
		case 0x1438: errorText = "Bus low voltage"; break;
		case 0x1439: errorText = "Bus high voltage"; break;
		case 0x143a: errorText = "Bus low frequency"; break;
		case 0x143b: errorText = "Bus high frequency"; break;
		case 0x143c: errorText = "MSC failure"; break;
		case 0x143d: errorText = "MSC too few sets"; break;
		case 0x143e: errorText = "MSC alarms inhibited"; break;
		case 0x143f: errorText = "MSC old version units on the bus"; break;
		case 0x1440: errorText = "Mains reverse power alarm/mains export alarm"; break;
		case 0x1441: errorText = "Minimum sets not reached"; break;
		case 0x1442: errorText = "Insufficient capacity"; break;
		case 0x1443: errorText = "Out of sync"; break;
		case 0x1444: errorText = "Alternative aux mains fail"; break;
		case 0x1445: errorText = "Loss of excitation"; break;
		case 0x1446: errorText = "Mains ROCOF"; break;
		case 0x1447: errorText = "Mains vector shift"; break;
		case 0x1448: errorText = "Mains decoupling low frequency"; break;
		case 0x1449: errorText = "Mains decoupling high frequency"; break;
		case 0x144a: errorText = "Mains decoupling low voltage"; break;
		case 0x144b: errorText = "Mains decoupling high voltage"; break;
		case 0x144c: errorText = "Mains decoupling combined alarm"; break;
		case 0x144d: errorText = "Charge Air Temperature"; break;
		case 0x144e: errorText = "Mains phase rotation alarm identifier"; break;
		case 0x144f: errorText = "AVR Max Trim Limit alarm"; break;
		case 0x1450: errorText = "High coolant temperature electrical trip alarm"; break;
		case 0x1451: errorText = "Temperature sender open circuit alarm"; break;
		case 0x1459: errorText = "ECU Protect"; break;
		case 0x145a: errorText = "ECU Malfunction"; break;
		case 0x145b: errorText = "Indication"; break;
		case 0x145c: errorText = "ECU Red"; break;
		case 0x145d: errorText = "ECU Amber"; break;
		case 0x145e: errorText = "Electrical Trip"; break;
		case 0x145f: errorText = "Aftertreatment Exhaust"; break;
		case 0x1460: errorText = "Water In Fuel"; break;
		case 0x1461: errorText = "ECU Heater"; break;
		case 0x1462: errorText = "ECU Cooler"; break;
		case 0x1463: errorText = "DC Total Watts Overload"; break;
		case 0x1464: errorText = "High Plant Battery Temperature"; break;
		case 0x1465: errorText = "Low Plant Battery Temperature"; break;
		case 0x1466: errorText = "Low Plant Battery Voltage"; break;
		case 0x1467: errorText = "High Plant Battery Voltage"; break;
		case 0x1468: errorText = "Plant Battery Depth Of Discharge"; break;
		case 0x1469: errorText = "DC Battery Over Current"; break;
		case 0x146a: errorText = "DC Load Over Current"; break;
		case 0x146b: errorText = "High Total DC Current"; break;

		/* DSE error codes 0x1500 to 0x15FF: DSE 71xx/66xx/60xx/L40x/4xxx/45xx MKII family */
		case 0x1500: errorText = "Emergency stop"; break;
		case 0x1501: errorText = "Low oil pressure"; break;
		case 0x1502: errorText = "High coolant temperature"; break;
		case 0x1503: errorText = "Low coolant temperature"; break;
		case 0x1504: errorText = "Under speed"; break;
		case 0x1505: errorText = "Over speed"; break;
		case 0x1506: errorText = "Generator Under frequency"; break;
		case 0x1507: errorText = "Generator Over frequency"; break;
		case 0x1508: errorText = "Generator low voltage"; break;
		case 0x1509: errorText = "Generator high voltage"; break;
		case 0x150a: errorText = "Battery low voltage"; break;
		case 0x150b: errorText = "Battery high voltage"; break;
		case 0x150c: errorText = "Charge alternator failure"; break;
		case 0x150d: errorText = "Fail to start"; break;
		case 0x150e: errorText = "Fail to stop"; break;
		case 0x150f: errorText = "Generator fail to close"; break;
		case 0x1510: errorText = "Mains fail to close"; break;
		case 0x1511: errorText = "Oil pressure sender fault"; break;
		case 0x1512: errorText = "Loss of Mag Pickup signal"; break;
		case 0x1513: errorText = "Magnetic pick up open circuit"; break;
		case 0x1514: errorText = "Generator high current"; break;
		case 0x1515: errorText = "Calibration lost"; break;
		case 0x1517: errorText = "CAN ECU Warning"; break;
		case 0x1518: errorText = "CAN ECU Shutdown"; break;
		case 0x1519: errorText = "CAN ECU Data fail"; break;
		case 0x151a: errorText = "Low oil level switch"; break;
		case 0x151b: errorText = "High temperature switch"; break;
		case 0x151c: errorText = "Low fuel level switch"; break;
		case 0x151d: errorText = "Expansion unit watchdog alarm"; break;
		case 0x151e: errorText = "kW overload alarm"; break;
		case 0x151f: errorText = "Negative phase sequence alarm"; break;
		case 0x1520: errorText = "Earth fault trip"; break;
		case 0x1521: errorText = "Generator phase rotation alarm"; break;
		case 0x1522: errorText = "Auto Voltage Sense fail"; break;
		case 0x1524: errorText = "Temperature sensor open circuit"; break;
		case 0x1525: errorText = "Low fuel level"; break;
		case 0x1526: errorText = "High fuel level"; break;
		case 0x1527: errorText = "Water in Fuel"; break;
		case 0x1528: errorText = "DEF Level Low"; break;
		case 0x1529: errorText = "SCR Inducement"; break;
		case 0x152a: errorText = "Hest Active"; break;
		case 0x152b: errorText = "DPTC Filter"; break;
		default: break;
		}

		return errorText ? "#%1 %2".arg(dataItem.value).arg(errorText) : ""
	}
}

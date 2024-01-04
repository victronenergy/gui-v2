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
		case 5 + 0x00:
			//% "Emergency stop"
			errorText = qsTrId("fp-genset-error_emergency_stop")
			break;
		case 6 + 0x00:
			//% "Servo current too low"
			errorText = qsTrId("fp-genset-error_servo_current_too_low")
			break;
		case 6 + 0x40:
			//% "Servo current too high"
			errorText = qsTrId("fp-genset-error_servo_current_too_high")
			break;
		case 7 + 0x00:
			//% "Oil pressure too low"
			errorText = qsTrId("fp-genset-error_oil_pressure_too_low")
			break;
		case 7 + 0x40:
			//% "Oil pressure too high"
			errorText = qsTrId("fp-genset-error_oil_pressure_too_high")
			break;
		case 8 + 0x00:
			//% "Engine temperature too low"
			errorText = qsTrId("fp-genset-error_engine_temperature_too_low")
			break;
		case 8 + 0x40:
			//% "Engine temperature too high"
			errorText = qsTrId("fp-genset-error_engine_temperature_too_high")
			break;
		case 9 + 0x00:
			//% "Winding temperature too low"
			errorText = qsTrId("fp-genset-error_winding_temperature_too_low")
			break;
		case 9 + 0x40:
			//% "Winding temperature too high"
			errorText = qsTrId("fp-genset-error_winding_temperature_too_high")
			break;
		case 10 + 0x00:
			//% "Exhaust temperature too low"
			errorText = qsTrId("fp-genset-error_exhaust_temperature_too_low")
			break;
		case 10 + 0x40:
			//% "Exhaust temperature too high"
			errorText = qsTrId("fp-genset-error_exhaust_temperature_too_high")
			break;
		case 13 + 0x00:
			//% "Starter current too low"
			errorText = qsTrId("fp-genset-error_starter_current_too_low")
			break;
		case 13 + 0x40:
			//% "Starter current too high"
			errorText = qsTrId("fp-genset-error_starter_current_too_high")
			break;
		case 14 + 0x00:
			//% "Glow current too low"
			errorText = qsTrId("fp-genset-error_glow_current_too_low")
			break;
		case 14 + 0x40:
			//% "Glow current too high"
			errorText = qsTrId("fp-genset-error_glow_current_too_high")
			break;
		case 15 + 0x00:
			//% "Glow current too low"
			errorText = qsTrId("fp-genset-error_glow_current_too_low")
			break;
		case 15 + 0x40:
			//% "Glow current too high"
			errorText = qsTrId("fp-genset-error_glow_current_too_high")
			break;
		case 16 + 0x00:
			//% "Fuel holding magnet current too low"
			errorText = qsTrId("fp-genset-error_fuel_holding_magnet_current_too_low")
			break;
		case 16 + 0x40:
			//% "Fuel holding magnet current too high"
			errorText = qsTrId("fp-genset-error_fuel_holding_magnet_current_too_high")
			break;
		case 17 + 0x00:
			//% "Stop solenoid hold coil current too low"
			errorText = qsTrId("fp-genset-error_stop_solenoid_hold_coil_current_too_low")
			break;
		case 17 + 0x40:
			//% "Stop solenoid hold coil current too high"
			errorText = qsTrId("fp-genset-error_stop_solenoid_hold_coil_current_too_high")
			break;
		case 18 + 0x00:
			//% "Stop solenoid pull coil current too low "
			errorText = qsTrId("fp-genset-error_stop_solenoid_pull_coil_current_too_low_")
			break;
		case 18 + 0x40:
			//% "Stop solenoid pull coil current too high"
			errorText = qsTrId("fp-genset-error_stop_solenoid_pull_coil_current_too_high")
			break;
		case 19 + 0x00:
			//% "Optional DC out current too low"
			errorText = qsTrId("fp-genset-error_optional_dc_out_current_too_low")
			break;
		case 19 + 0x40:
			//% "Optional DC out current too high"
			errorText = qsTrId("fp-genset-error_optional_dc_out_current_too_high")
			break;
		case 20 + 0x00:
			//% "5V output voltage too low"
			errorText = qsTrId("fp-genset-error_5v_output_voltage_too_low")
			break;
		case 20 + 0x40:
			//% "5V output current too high"
			errorText = qsTrId("fp-genset-error_5v_output_current_too_high")
			break;
		case 21 + 0x00:
			//% "Boost output current too low"
			errorText = qsTrId("fp-genset-error_boost_output_current_too_low")
			break;
		case 21 + 0x40:
			//% "Boost output current too high"
			errorText = qsTrId("fp-genset-error_boost_output_current_too_high")
			break;
		case 22 + 0x40:
			//% "Panel supply current too high"
			errorText = qsTrId("fp-genset-error_panel_supply_current_too_high")
			break;
		case 25 + 0x00:
			//% "Starter battery voltage too low"
			errorText = qsTrId("fp-genset-error_starter_battery_voltage_too_low")
			break;
		case 25 + 0x40:
			//% "Starter battery voltage too high"
			errorText = qsTrId("fp-genset-error_starter_battery_voltage_too_high")
			break;
		case 26 + 0x00:
			//% "Startup aborted (rotation too low)"
			errorText = qsTrId("fp-genset-error_startup_aborted_rotation_too_low")
			break;
		case 26 + 0x40:
			//% "Startup aborted (rotation too high)"
			errorText = qsTrId("fp-genset-error_startup_aborted_rotation_too_high")
			break;
		case 28 + 0x00:
			//% "Rotation too low"
			errorText = qsTrId("fp-genset-error_rotation_too_low")
			break;
		case 28 + 0x40:
			//% "Rotation too high"
			errorText = qsTrId("fp-genset-error_rotation_too_high")
			break;
		case 29 + 0x00:
			//% "Power contactor current too low"
			errorText = qsTrId("fp-genset-error_power_contactor_current_too_low")
			break;
		case 29 + 0x40:
			//% "Power contactor current too high"
			errorText = qsTrId("fp-genset-error_power_contactor_current_too_high")
			break;
		case 30 + 0x00:
			//% "AC voltage L2 too low"
			errorText = qsTrId("fp-genset-error_ac_voltage_l2_too_low")
			break;
		case 30 + 0x40:
			//% "AC voltage L2 too high"
			errorText = qsTrId("fp-genset-error_ac_voltage_l2_too_high")
			break;
		case 31 + 0x00:
			//% "AC frequency L2 too low"
			errorText = qsTrId("fp-genset-error_ac_frequency_l2_too_low")
			break;
		case 31 + 0x40:
			//% "AC frequency L2 too high"
			errorText = qsTrId("fp-genset-error_ac_frequency_l2_too_high")
			break;
		case 32 + 0x00:
			//% "AC current L2 too low"
			errorText = qsTrId("fp-genset-error_ac_current_l2_too_low")
			break;
		case 32 + 0x40:
			//% "AC current L2 too high"
			errorText = qsTrId("fp-genset-error_ac_current_l2_too_high")
			break;
		case 33 + 0x00:
			//% "AC power L2 too low"
			errorText = qsTrId("fp-genset-error_ac_power_l2_too_low")
			break;
		case 33 + 0x40:
			//% "AC power L2 too high"
			errorText = qsTrId("fp-genset-error_ac_power_l2_too_high")
			break;
		case 34 + 0x00:
			//% "AC voltage L3 too low"
			errorText = qsTrId("fp-genset-error_ac_voltage_l3_too_low")
			break;
		case 34 + 0x40:
			//% "AC voltage L3 too high"
			errorText = qsTrId("fp-genset-error_ac_voltage_l3_too_high")
			break;
		case 35 + 0x00:
			//% "AC frequency L3 too low"
			errorText = qsTrId("fp-genset-error_ac_frequency_l3_too_low")
			break;
		case 35 + 0x40:
			//% "AC frequency L3 too high"
			errorText = qsTrId("fp-genset-error_ac_frequency_l3_too_high")
			break;
		case 36 + 0x00:
			//% "AC current L3 too low"
			errorText = qsTrId("fp-genset-error_ac_current_l3_too_low")
			break;
		case 36 + 0x40:
			//% "AC current L3 too high"
			errorText = qsTrId("fp-genset-error_ac_current_l3_too_high")
			break;
		case 37 + 0x00:
			//% "AC power L3 too low"
			errorText = qsTrId("fp-genset-error_ac_power_l3_too_low")
			break;
		case 37 + 0x40:
			//% "AC power L3 too high"
			errorText = qsTrId("fp-genset-error_ac_power_l3_too_high")
			break;
		case 62 + 0x00:
			//% "Fuel temperature too low"
			errorText = qsTrId("fp-genset-error_fuel_temperature_too_low")
			break;
		case 62 + 0x40:
			//% "Fuel temperature too high"
			errorText = qsTrId("fp-genset-error_fuel_temperature_too_high")
			break;
		case 63 + 0x00:
			//% "Fuel level too low"
			errorText = qsTrId("fp-genset-error_fuel_level_too_low")
			break;
		case 63 + 0x40:
			//% "Fuel level too high"
			errorText = qsTrId("fp-genset-error_fuel_level_too_high")
			break;
		case 130:
			//% "Lost control unit"
			errorText = qsTrId("fp-genset-error_lost_control_unit")
			break;
		case 131:
			//% "Lost panel"
			errorText = qsTrId("fp-genset-error_lost_panel")
			break;
		case 132:
			//% "Service needed"
			errorText = qsTrId("fp-genset-error_service_needed")
			break;
		case 133:
			//% "Lost 3-phase module"
			errorText = qsTrId("fp-genset-error_lost_3-phase_module")
			break;
		case 134:
			//% "Lost AGT module"
			errorText = qsTrId("fp-genset-error_lost_agt_module")
			break;
		case 135:
			//% "Synchronization failure"
			errorText = qsTrId("fp-genset-error_synchronization_failure")
			break;
		case 137:
			//% "Intake airfilter"
			errorText = qsTrId("fp-genset-error_intake_airfilter")
			break;
		case 139:
			//% "Lost sync. module"
			errorText = qsTrId("fp-genset-error_lost_sync._module")
			break;
		case 140:
			//% "Load-balance failed"
			errorText = qsTrId("fp-genset-error_load-balance_failed")
			break;
		case 141:
			//% "Sync-mode deactivated"
			errorText = qsTrId("fp-genset-error_sync-mode_deactivated")
			break;
		case 142:
			//% "Engine controller"
			errorText = qsTrId("fp-genset-error_engine_controller")
			break;
		case 148:
			//% "Rotating field wrong"
			errorText = qsTrId("fp-genset-error_rotating_field_wrong")
			break;
		case 149:
			//% "Fuel level sensor lost"
			errorText = qsTrId("fp-genset-error_fuel_level_sensor_lost")
			break;
		case 150:
			//% "Init failed"
			errorText = qsTrId("fp-genset-error_init_failed")
			break;
		case 151:
			//% "Watchdog"
			errorText = qsTrId("fp-genset-error_watchdog")
			break;
		case 152:
			//% "Out: winding"
			errorText = qsTrId("fp-genset-error_out:_winding")
			break;
		case 153:
			//% "Out: exhaust"
			errorText = qsTrId("fp-genset-error_out:_exhaust")
			break;
		case 154:
			//% "Out: Cyl. head"
			errorText = qsTrId("fp-genset-error_out:_cyl._head")
			break;
		case 155:
			//% "Inverter over temperature"
			errorText = qsTrId("fp-genset-error_inverter_over_temperature")
			break;
		case 156:
			//% "Inverter overload"
			errorText = qsTrId("fp-genset-error_inverter_overload")
			break;
		case 157:
			//% "Inverter communication lost"
			errorText = qsTrId("fp-genset-error_inverter_communication_lost")
			break;
		case 158:
			//% "Inverter sync failed"
			errorText = qsTrId("fp-genset-error_inverter_sync_failed")
			break;
		case 159:
			//% "CAN communication lost"
			errorText = qsTrId("fp-genset-error_can_communication_lost")
			break;
		case 160:
			//% "L1 overload"
			errorText = qsTrId("fp-genset-error_l1_overload")
			break;
		case 161:
			//% "L2 overload"
			errorText = qsTrId("fp-genset-error_l2_overload")
			break;
		case 162:
			//% "L3 overload"
			errorText = qsTrId("fp-genset-error_l3_overload")
			break;
		case 163:
			//% "DC overload"
			errorText = qsTrId("fp-genset-error_dc_overload")
			break;
		case 164:
			//% "DC overvoltage"
			errorText = qsTrId("fp-genset-error_dc_overvoltage")
			break;
		case 165:
			//% "Emergency stop"
			errorText = qsTrId("fp-genset-error_emergency_stop")
			break;
		case 0x1000:
			//% "Emergency stop"
			errorText = qsTrId("fp-genset-error_emergency_stop")
			break;
		case 0x1001:
			//% "Low oil pressure"
			errorText = qsTrId("fp-genset-error_low_oil_pressure")
			break;
		case 0x1002:
			//% "High coolant temperature"
			errorText = qsTrId("fp-genset-error_high_coolant_temperature")
			break;
		case 0x1003:
			//% "High oil temperature"
			errorText = qsTrId("fp-genset-error_high_oil_temperature")
			break;
		case 0x1004:
			//% "Under speed"
			errorText = qsTrId("fp-genset-error_under_speed")
			break;
		case 0x1005:
			//% "Over speed"
			errorText = qsTrId("fp-genset-error_over_speed")
			break;
		case 0x1006:
			//% "Fail to start"
			errorText = qsTrId("fp-genset-error_fail_to_start")
			break;
		case 0x1007:
			//% "Fail to come to rest"
			errorText = qsTrId("fp-genset-error_fail_to_come_to_rest")
			break;
		case 0x1008:
			//% "Loss of speed sensing"
			errorText = qsTrId("fp-genset-error_loss_of_speed_sensing")
			break;
		case 0x1009:
			//% "Generator low voltage"
			errorText = qsTrId("fp-genset-error_generator_low_voltage")
			break;
		case 0x100a:
			//% "Generator high voltage"
			errorText = qsTrId("fp-genset-error_generator_high_voltage")
			break;
		case 0x100b:
			//% "Generator low frequency"
			errorText = qsTrId("fp-genset-error_generator_low_frequency")
			break;
		case 0x100c:
			//% "Generator high frequency"
			errorText = qsTrId("fp-genset-error_generator_high_frequency")
			break;
		case 0x100d:
			//% "Generator high current"
			errorText = qsTrId("fp-genset-error_generator_high_current")
			break;
		case 0x100e:
			//% "Generator earth fault"
			errorText = qsTrId("fp-genset-error_generator_earth_fault")
			break;
		case 0x100f:
			//% "Generator reverse power"
			errorText = qsTrId("fp-genset-error_generator_reverse_power")
			break;
		case 0x1010:
			//% "Air flap"
			errorText = qsTrId("fp-genset-error_air_flap")
			break;
		case 0x1011:
			//% "Oil pressure sender fault"
			errorText = qsTrId("fp-genset-error_oil_pressure_sender_fault")
			break;
		case 0x1012:
			//% "Coolant temperature sender fault"
			errorText = qsTrId("fp-genset-error_coolant_temperature_sender_fault")
			break;
		case 0x1013:
			//% "Oil temperature sender fault"
			errorText = qsTrId("fp-genset-error_oil_temperature_sender_fault")
			break;
		case 0x1014:
			//% "Fuel level sender fault"
			errorText = qsTrId("fp-genset-error_fuel_level_sender_fault")
			break;
		case 0x1015:
			//% "Magnetic pickup fault"
			errorText = qsTrId("fp-genset-error_magnetic_pickup_fault")
			break;
		case 0x1016:
			//% "Loss of AC speed signal"
			errorText = qsTrId("fp-genset-error_loss_of_ac_speed_signal")
			break;
		case 0x1017:
			//% "Charge alternator failure"
			errorText = qsTrId("fp-genset-error_charge_alternator_failure")
			break;
		case 0x1018:
			//% "Low battery voltage"
			errorText = qsTrId("fp-genset-error_low_battery_voltage")
			break;
		case 0x1019:
			//% "High battery voltage"
			errorText = qsTrId("fp-genset-error_high_battery_voltage")
			break;
		case 0x101a:
			//% "Low fuel level"
			errorText = qsTrId("fp-genset-error_low_fuel_level")
			break;
		case 0x101b:
			//% "High fuel level"
			errorText = qsTrId("fp-genset-error_high_fuel_level")
			break;
		case 0x101c:
			//% "Generator failed to close"
			errorText = qsTrId("fp-genset-error_generator_failed_to_close")
			break;
		case 0x101d:
			//% "Mains failed to close"
			errorText = qsTrId("fp-genset-error_mains_failed_to_close")
			break;
		case 0x101e:
			//% "Generator failed to open"
			errorText = qsTrId("fp-genset-error_generator_failed_to_open")
			break;
		case 0x101f:
			//% "Mains failed to open"
			errorText = qsTrId("fp-genset-error_mains_failed_to_open")
			break;
		case 0x1020:
			//% "Mains low voltage"
			errorText = qsTrId("fp-genset-error_mains_low_voltage")
			break;
		case 0x1021:
			//% "Mains high voltage"
			errorText = qsTrId("fp-genset-error_mains_high_voltage")
			break;
		case 0x1022:
			//% "Bus failed to close"
			errorText = qsTrId("fp-genset-error_bus_failed_to_close")
			break;
		case 0x1023:
			//% "Bus failed to open"
			errorText = qsTrId("fp-genset-error_bus_failed_to_open")
			break;
		case 0x1024:
			//% "Mains low frequency"
			errorText = qsTrId("fp-genset-error_mains_low_frequency")
			break;
		case 0x1025:
			//% "Mains high frequency"
			errorText = qsTrId("fp-genset-error_mains_high_frequency")
			break;
		case 0x1026:
			//% "Mains failed"
			errorText = qsTrId("fp-genset-error_mains_failed")
			break;
		case 0x1027:
			//% "Mains phase rotation wrong"
			errorText = qsTrId("fp-genset-error_mains_phase_rotation_wrong")
			break;
		case 0x1028:
			//% "Generator phase rotation wrong"
			errorText = qsTrId("fp-genset-error_generator_phase_rotation_wrong")
			break;
		case 0x1029:
			//% "Maintenance due"
			errorText = qsTrId("fp-genset-error_maintenance_due")
			break;
		case 0x102a:
			//% "Clock not set"
			errorText = qsTrId("fp-genset-error_clock_not_set")
			break;
		case 0x102b:
			//% "Local LCD configuration lost"
			errorText = qsTrId("fp-genset-error_local_lcd_configuration_lost")
			break;
		case 0x102c:
			//% "Local telemetry configuration lost"
			errorText = qsTrId("fp-genset-error_local_telemetry_configuration_lost")
			break;
		case 0x102d:
			//% "Control unit not calibrated"
			errorText = qsTrId("fp-genset-error_control_unit_not_calibrated")
			break;
		case 0x102e:
			//% "Modem power fault"
			errorText = qsTrId("fp-genset-error_modem_power_fault")
			break;
		case 0x102f:
			//% "Generator short circuit"
			errorText = qsTrId("fp-genset-error_generator_short_circuit")
			break;
		case 0x1030:
			//% "Failure to synchronise"
			errorText = qsTrId("fp-genset-error_failure_to_synchronise")
			break;
		case 0x1031:
			//% "Bus live"
			errorText = qsTrId("fp-genset-error_bus_live")
			break;
		case 0x1032:
			//% "Scheduled run"
			errorText = qsTrId("fp-genset-error_scheduled_run")
			break;
		case 0x1033:
			//% "Bus phase rotation wrong"
			errorText = qsTrId("fp-genset-error_bus_phase_rotation_wrong")
			break;
		case 0x1034:
			//% "Priority selection error"
			errorText = qsTrId("fp-genset-error_priority_selection_error")
			break;
		case 0x1035:
			//% "Multiset communications (MSC) data error"
			errorText = qsTrId("fp-genset-error_multiset_communications_msc_data_error")
			break;
		case 0x1036:
			//% "Multiset communications (MSC) ID error"
			errorText = qsTrId("fp-genset-error_multiset_communications_msc_id_error")
			break;
		case 0x1037:
			//% "Multiset communications (MSC) failure"
			errorText = qsTrId("fp-genset-error_multiset_communications_msc_failure")
			break;
		case 0x1038:
			//% "Multiset communications (MSC) too few sets"
			errorText = qsTrId("fp-genset-error_multiset_communications_msc_too_few_sets")
			break;
		case 0x1039:
			//% "Multiset communications (MSC) alarms inhibited"
			errorText = qsTrId("fp-genset-error_multiset_communications_msc_alarms_inhibited")
			break;
		case 0x103a:
			//% "Multiset communications (MSC) old version units"
			errorText = qsTrId("fp-genset-error_multiset_communications_msc_old_version_units")
			break;
		case 0x103b:
			//% "Mains reverse power"
			errorText = qsTrId("fp-genset-error_mains_reverse_power")
			break;
		case 0x103c:
			//% "Minimum sets not reached"
			errorText = qsTrId("fp-genset-error_minimum_sets_not_reached")
			break;
		case 0x103d:
			//% "Insufficient capacity available"
			errorText = qsTrId("fp-genset-error_insufficient_capacity_available")
			break;
		case 0x103e:
			//% "Expansion input unit not calibrated"
			errorText = qsTrId("fp-genset-error_expansion_input_unit_not_calibrated")
			break;
		case 0x103f:
			//% "Expansion input unit failure"
			errorText = qsTrId("fp-genset-error_expansion_input_unit_failure")
			break;
		case 0x1040:
			//% "Auxiliary sender 1 low"
			errorText = qsTrId("fp-genset-error_auxiliary_sender_1_low")
			break;
		case 0x1041:
			//% "Auxiliary sender 1 high"
			errorText = qsTrId("fp-genset-error_auxiliary_sender_1_high")
			break;
		case 0x1042:
			//% "Auxiliary sender 1 fault"
			errorText = qsTrId("fp-genset-error_auxiliary_sender_1_fault")
			break;
		case 0x1043:
			//% "Auxiliary sender 2 low"
			errorText = qsTrId("fp-genset-error_auxiliary_sender_2_low")
			break;
		case 0x1044:
			//% "Auxiliary sender 2 high"
			errorText = qsTrId("fp-genset-error_auxiliary_sender_2_high")
			break;
		case 0x1045:
			//% "Auxiliary sender 2 fault"
			errorText = qsTrId("fp-genset-error_auxiliary_sender_2_fault")
			break;
		case 0x1046:
			//% "Auxiliary sender 3 low"
			errorText = qsTrId("fp-genset-error_auxiliary_sender_3_low")
			break;
		case 0x1047:
			//% "Auxiliary sender 3 high"
			errorText = qsTrId("fp-genset-error_auxiliary_sender_3_high")
			break;
		case 0x1048:
			//% "Auxiliary sender 3 fault"
			errorText = qsTrId("fp-genset-error_auxiliary_sender_3_fault")
			break;
		case 0x1049:
			//% "Auxiliary sender 4 low"
			errorText = qsTrId("fp-genset-error_auxiliary_sender_4_low")
			break;
		case 0x104a:
			//% "Auxiliary sender 4 high"
			errorText = qsTrId("fp-genset-error_auxiliary_sender_4_high")
			break;
		case 0x104b:
			//% "Auxiliary sender 4 fault"
			errorText = qsTrId("fp-genset-error_auxiliary_sender_4_fault")
			break;
		case 0x104c:
			//% "Engine control unit (ECU) link lost"
			errorText = qsTrId("fp-genset-error_engine_control_unit_ecu_link_lost")
			break;
		case 0x104d:
			//% "Engine control unit (ECU) failure"
			errorText = qsTrId("fp-genset-error_engine_control_unit_ecu_failure")
			break;
		case 0x104e:
			//% "Engine control unit (ECU) error"
			errorText = qsTrId("fp-genset-error_engine_control_unit_ecu_error")
			break;
		case 0x104f:
			//% "Low coolant temperature"
			errorText = qsTrId("fp-genset-error_low_coolant_temperature")
			break;
		case 0x1050:
			//% "Out of sync"
			errorText = qsTrId("fp-genset-error_out_of_sync")
			break;
		case 0x1051:
			//% "Low Oil Pressure Switch"
			errorText = qsTrId("fp-genset-error_low_oil_pressure_switch")
			break;
		case 0x1052:
			//% "Alternative Auxiliary Mains Fail"
			errorText = qsTrId("fp-genset-error_alternative_auxiliary_mains_fail")
			break;
		case 0x1053:
			//% "Loss of excitation"
			errorText = qsTrId("fp-genset-error_loss_of_excitation")
			break;
		case 0x1054:
			//% "Mains kW Limit"
			errorText = qsTrId("fp-genset-error_mains_kw_limit")
			break;
		case 0x1055:
			//% "Negative phase sequence"
			errorText = qsTrId("fp-genset-error_negative_phase_sequence")
			break;
		case 0x1056:
			//% "Mains ROCOF"
			errorText = qsTrId("fp-genset-error_mains_rocof")
			break;
		case 0x1057:
			//% "Mains vector shift"
			errorText = qsTrId("fp-genset-error_mains_vector_shift")
			break;
		case 0x1058:
			//% "Mains G59 low frequency"
			errorText = qsTrId("fp-genset-error_mains_g59_low_frequency")
			break;
		case 0x1059:
			//% "Mains G59 high frequency"
			errorText = qsTrId("fp-genset-error_mains_g59_high_frequency")
			break;
		case 0x105a:
			//% "Mains G59 low voltage"
			errorText = qsTrId("fp-genset-error_mains_g59_low_voltage")
			break;
		case 0x105b:
			//% "Mains G59 high voltage"
			errorText = qsTrId("fp-genset-error_mains_g59_high_voltage")
			break;
		case 0x105c:
			//% "Mains G59 trip"
			errorText = qsTrId("fp-genset-error_mains_g59_trip")
			break;
		case 0x105d:
			//% "Generator kW Overload"
			errorText = qsTrId("fp-genset-error_generator_kw_overload")
			break;
		case 0x105e:
			//% "Engine Inlet Temperature high"
			errorText = qsTrId("fp-genset-error_engine_inlet_temperature_high")
			break;
		case 0x105f:
			//% "Bus 1 live"
			errorText = qsTrId("fp-genset-error_bus_1_live")
			break;
		case 0x1060:
			//% "Bus 1 phase rotation wrong"
			errorText = qsTrId("fp-genset-error_bus_1_phase_rotation_wrong")
			break;
		case 0x1061:
			//% "Bus 2 live"
			errorText = qsTrId("fp-genset-error_bus_2_live")
			break;
		case 0x1062:
			//% "Bus 2 phase rotation wrong"
			errorText = qsTrId("fp-genset-error_bus_2_phase_rotation_wrong")
			break;
		case 0x1100:
			//% "Emergency stop"
			errorText = qsTrId("fp-genset-error_emergency_stop")
			break;
		case 0x1101:
			//% "Low oil pressure"
			errorText = qsTrId("fp-genset-error_low_oil_pressure")
			break;
		case 0x1102:
			//% "High coolant temperature"
			errorText = qsTrId("fp-genset-error_high_coolant_temperature")
			break;
		case 0x1103:
			//% "Low coolant temperature"
			errorText = qsTrId("fp-genset-error_low_coolant_temperature")
			break;
		case 0x1104:
			//% "Under speed"
			errorText = qsTrId("fp-genset-error_under_speed")
			break;
		case 0x1105:
			//% "Over speed"
			errorText = qsTrId("fp-genset-error_over_speed")
			break;
		case 0x1106:
			//% "Generator Under frequency"
			errorText = qsTrId("fp-genset-error_generator_under_frequency")
			break;
		case 0x1107:
			//% "Generator Over frequency"
			errorText = qsTrId("fp-genset-error_generator_over_frequency")
			break;
		case 0x1108:
			//% "Generator low voltage"
			errorText = qsTrId("fp-genset-error_generator_low_voltage")
			break;
		case 0x1109:
			//% "Generator high voltage"
			errorText = qsTrId("fp-genset-error_generator_high_voltage")
			break;
		case 0x110a:
			//% "Battery low voltage"
			errorText = qsTrId("fp-genset-error_battery_low_voltage")
			break;
		case 0x110b:
			//% "Battery high voltage"
			errorText = qsTrId("fp-genset-error_battery_high_voltage")
			break;
		case 0x110c:
			//% "Charge alternator failure"
			errorText = qsTrId("fp-genset-error_charge_alternator_failure")
			break;
		case 0x110d:
			//% "Fail to start"
			errorText = qsTrId("fp-genset-error_fail_to_start")
			break;
		case 0x110e:
			//% "Fail to stop"
			errorText = qsTrId("fp-genset-error_fail_to_stop")
			break;
		case 0x110f:
			//% "Generator fail to close"
			errorText = qsTrId("fp-genset-error_generator_fail_to_close")
			break;
		case 0x1110:
			//% "Mains fail to close"
			errorText = qsTrId("fp-genset-error_mains_fail_to_close")
			break;
		case 0x1111:
			//% "Oil pressure sender fault"
			errorText = qsTrId("fp-genset-error_oil_pressure_sender_fault")
			break;
		case 0x1112:
			//% "Loss of magnetic pick up"
			errorText = qsTrId("fp-genset-error_loss_of_magnetic_pick_up")
			break;
		case 0x1113:
			//% "Magnetic pick up open circuit"
			errorText = qsTrId("fp-genset-error_magnetic_pick_up_open_circuit")
			break;
		case 0x1114:
			//% "Generator high current"
			errorText = qsTrId("fp-genset-error_generator_high_current")
			break;
		case 0x1115:
			//% "Calibration lost"
			errorText = qsTrId("fp-genset-error_calibration_lost")
			break;
		case 0x1116:
			//% "Low fuel level"
			errorText = qsTrId("fp-genset-error_low_fuel_level")
			break;
		case 0x1117:
			//% "CAN ECU Warning"
			errorText = qsTrId("fp-genset-error_can_ecu_warning")
			break;
		case 0x1118:
			//% "CAN ECU Shutdown"
			errorText = qsTrId("fp-genset-error_can_ecu_shutdown")
			break;
		case 0x1119:
			//% "CAN ECU Data fail"
			errorText = qsTrId("fp-genset-error_can_ecu_data_fail")
			break;
		case 0x111a:
			//% "Low oil level switch"
			errorText = qsTrId("fp-genset-error_low_oil_level_switch")
			break;
		case 0x111b:
			//% "High temperature switch"
			errorText = qsTrId("fp-genset-error_high_temperature_switch")
			break;
		case 0x111c:
			//% "Low fuel level switch"
			errorText = qsTrId("fp-genset-error_low_fuel_level_switch")
			break;
		case 0x111d:
			//% "Expansion unit watchdog alarm"
			errorText = qsTrId("fp-genset-error_expansion_unit_watchdog_alarm")
			break;
		case 0x111e:
			//% "kW overload alarm"
			errorText = qsTrId("fp-genset-error_kw_overload_alarm")
			break;
		case 0x1123:
			//% "Maintenance alarm"
			errorText = qsTrId("fp-genset-error_maintenance_alarm")
			break;
		case 0x1124:
			//% "Loading frequency alarm"
			errorText = qsTrId("fp-genset-error_loading_frequency_alarm")
			break;
		case 0x1125:
			//% "Loading voltage alarm"
			errorText = qsTrId("fp-genset-error_loading_voltage_alarm")
			break;
		case 0x112e:
			//% "ECU protect"
			errorText = qsTrId("fp-genset-error_ecu_protect")
			break;
		case 0x112f:
			//% "ECU Malfunction"
			errorText = qsTrId("fp-genset-error_ecu_malfunction")
			break;
		case 0x1130:
			//% "ECU Information"
			errorText = qsTrId("fp-genset-error_ecu_information")
			break;
		case 0x1131:
			//% "ECU Shutdown"
			errorText = qsTrId("fp-genset-error_ecu_shutdown")
			break;
		case 0x1132:
			//% "ECU Warning"
			errorText = qsTrId("fp-genset-error_ecu_warning")
			break;
		case 0x1133:
			//% "ECU HEST"
			errorText = qsTrId("fp-genset-error_ecu_hest")
			break;
		case 0x1135:
			//% "ECU Water In Fuel"
			errorText = qsTrId("fp-genset-error_ecu_water_in_fuel")
			break;
		case 0x1139:
			//% "High fuel level"
			errorText = qsTrId("fp-genset-error_high_fuel_level")
			break;
		case 0x113a:
			//% "DEF Level Low"
			errorText = qsTrId("fp-genset-error_def_level_low")
			break;
		case 0x113b:
			//% "SCR Inducement"
			errorText = qsTrId("fp-genset-error_scr_inducement")
			break;
		case 0x1200:
			//% "Emergency stop"
			errorText = qsTrId("fp-genset-error_emergency_stop")
			break;
		case 0x1201:
			//% "Low oil pressure"
			errorText = qsTrId("fp-genset-error_low_oil_pressure")
			break;
		case 0x1202:
			//% "High coolant temperature"
			errorText = qsTrId("fp-genset-error_high_coolant_temperature")
			break;
		case 0x1203:
			//% "Low coolant temperature"
			errorText = qsTrId("fp-genset-error_low_coolant_temperature")
			break;
		case 0x1204:
			//% "Under speed"
			errorText = qsTrId("fp-genset-error_under_speed")
			break;
		case 0x1205:
			//% "Over speed"
			errorText = qsTrId("fp-genset-error_over_speed")
			break;
		case 0x1206:
			//% "Generator Under frequency"
			errorText = qsTrId("fp-genset-error_generator_under_frequency")
			break;
		case 0x1207:
			//% "Generator Over frequency"
			errorText = qsTrId("fp-genset-error_generator_over_frequency")
			break;
		case 0x1208:
			//% "Generator low voltage"
			errorText = qsTrId("fp-genset-error_generator_low_voltage")
			break;
		case 0x1209:
			//% "Generator high voltage"
			errorText = qsTrId("fp-genset-error_generator_high_voltage")
			break;
		case 0x120a:
			//% "Battery low voltage"
			errorText = qsTrId("fp-genset-error_battery_low_voltage")
			break;
		case 0x120b:
			//% "Battery high voltage"
			errorText = qsTrId("fp-genset-error_battery_high_voltage")
			break;
		case 0x120c:
			//% "Charge alternator failure"
			errorText = qsTrId("fp-genset-error_charge_alternator_failure")
			break;
		case 0x120d:
			//% "Fail to start"
			errorText = qsTrId("fp-genset-error_fail_to_start")
			break;
		case 0x120e:
			//% "Fail to stop"
			errorText = qsTrId("fp-genset-error_fail_to_stop")
			break;
		case 0x120f:
			//% "Generator fail to close"
			errorText = qsTrId("fp-genset-error_generator_fail_to_close")
			break;
		case 0x1210:
			//% "Mains fail to close"
			errorText = qsTrId("fp-genset-error_mains_fail_to_close")
			break;
		case 0x1211:
			//% "Oil pressure sender fault"
			errorText = qsTrId("fp-genset-error_oil_pressure_sender_fault")
			break;
		case 0x1212:
			//% "Loss of magnetic pick up"
			errorText = qsTrId("fp-genset-error_loss_of_magnetic_pick_up")
			break;
		case 0x1213:
			//% "Magnetic pick up open circuit"
			errorText = qsTrId("fp-genset-error_magnetic_pick_up_open_circuit")
			break;
		case 0x1214:
			//% "Generator high current"
			errorText = qsTrId("fp-genset-error_generator_high_current")
			break;
		case 0x1215:
			//% "Calibration lost"
			errorText = qsTrId("fp-genset-error_calibration_lost")
			break;
		case 0x1216:
			//% "Low fuel level"
			errorText = qsTrId("fp-genset-error_low_fuel_level")
			break;
		case 0x1217:
			//% "CAN ECU Warning"
			errorText = qsTrId("fp-genset-error_can_ecu_warning")
			break;
		case 0x1218:
			//% "CAN ECU Shutdown"
			errorText = qsTrId("fp-genset-error_can_ecu_shutdown")
			break;
		case 0x1219:
			//% "CAN ECU Data fail"
			errorText = qsTrId("fp-genset-error_can_ecu_data_fail")
			break;
		case 0x121a:
			//% "Low oil level switch"
			errorText = qsTrId("fp-genset-error_low_oil_level_switch")
			break;
		case 0x121b:
			//% "High temperature switch"
			errorText = qsTrId("fp-genset-error_high_temperature_switch")
			break;
		case 0x121c:
			//% "Low fuel level switch"
			errorText = qsTrId("fp-genset-error_low_fuel_level_switch")
			break;
		case 0x121d:
			//% "Expansion unit watchdog alarm"
			errorText = qsTrId("fp-genset-error_expansion_unit_watchdog_alarm")
			break;
		case 0x121e:
			//% "kW overload alarm"
			errorText = qsTrId("fp-genset-error_kw_overload_alarm")
			break;
		case 0x121f:
			//% "Negative phase sequence current alarm"
			errorText = qsTrId("fp-genset-error_negative_phase_sequence_current_alarm")
			break;
		case 0x1220:
			//% "Earth fault trip alarm"
			errorText = qsTrId("fp-genset-error_earth_fault_trip_alarm")
			break;
		case 0x1221:
			//% "Generator phase rotation alarm"
			errorText = qsTrId("fp-genset-error_generator_phase_rotation_alarm")
			break;
		case 0x1222:
			//% "Auto Voltage Sense Fail"
			errorText = qsTrId("fp-genset-error_auto_voltage_sense_fail")
			break;
		case 0x1223:
			//% "Maintenance alarm"
			errorText = qsTrId("fp-genset-error_maintenance_alarm")
			break;
		case 0x1224:
			//% "Loading frequency alarm"
			errorText = qsTrId("fp-genset-error_loading_frequency_alarm")
			break;
		case 0x1225:
			//% "Loading voltage alarm"
			errorText = qsTrId("fp-genset-error_loading_voltage_alarm")
			break;
		case 0x1226:
			//% "Fuel usage running"
			errorText = qsTrId("fp-genset-error_fuel_usage_running")
			break;
		case 0x1227:
			//% "Fuel usage stopped"
			errorText = qsTrId("fp-genset-error_fuel_usage_stopped")
			break;
		case 0x1228:
			//% "Protections disabled"
			errorText = qsTrId("fp-genset-error_protections_disabled")
			break;
		case 0x1229:
			//% "Protections blocked"
			errorText = qsTrId("fp-genset-error_protections_blocked")
			break;
		case 0x122a:
			//% "Generator short circuit"
			errorText = qsTrId("fp-genset-error_generator_short_circuit")
			break;
		case 0x122b:
			//% "Mains High Current"
			errorText = qsTrId("fp-genset-error_mains_high_current")
			break;
		case 0x122c:
			//% "Mains Earth Fault"
			errorText = qsTrId("fp-genset-error_mains_earth_fault")
			break;
		case 0x122d:
			//% "Mains Short Circuit"
			errorText = qsTrId("fp-genset-error_mains_short_circuit")
			break;
		case 0x122e:
			//% "ECU protect"
			errorText = qsTrId("fp-genset-error_ecu_protect")
			break;
		case 0x122f:
			//% "ECU Malfunction"
			errorText = qsTrId("fp-genset-error_ecu_malfunction")
			break;
		case 0x1230:
			//% "ECU Information"
			errorText = qsTrId("fp-genset-error_ecu_information")
			break;
		case 0x1231:
			//% "ECU Shutdown"
			errorText = qsTrId("fp-genset-error_ecu_shutdown")
			break;
		case 0x1232:
			//% "ECU Warning"
			errorText = qsTrId("fp-genset-error_ecu_warning")
			break;
		case 0x1233:
			//% "ECU Electrical Trip"
			errorText = qsTrId("fp-genset-error_ecu_electrical_trip")
			break;
		case 0x1234:
			//% "ECU After treatment"
			errorText = qsTrId("fp-genset-error_ecu_after_treatment")
			break;
		case 0x1235:
			//% "ECU Water In Fuel"
			errorText = qsTrId("fp-genset-error_ecu_water_in_fuel")
			break;
		case 0x1236:
			//% "Generator reverse power"
			errorText = qsTrId("fp-genset-error_generator_reverse_power")
			break;
		case 0x1237:
			//% "Generator Positive VAr"
			errorText = qsTrId("fp-genset-error_generator_positive_var")
			break;
		case 0x1238:
			//% "Generator Negative VAr"
			errorText = qsTrId("fp-genset-error_generator_negative_var")
			break;
		case 0x1239:
			//% "LCD Heater Low Voltage"
			errorText = qsTrId("fp-genset-error_lcd_heater_low_voltage")
			break;
		case 0x123a:
			//% "LCD Heater High Voltage"
			errorText = qsTrId("fp-genset-error_lcd_heater_high_voltage")
			break;
		case 0x123b:
			//% "DEF Level Low"
			errorText = qsTrId("fp-genset-error_def_level_low")
			break;
		case 0x123c:
			//% "SCR Inducement"
			errorText = qsTrId("fp-genset-error_scr_inducement")
			break;
		case 0x123d:
			//% "MSC Old version"
			errorText = qsTrId("fp-genset-error_msc_old_version")
			break;
		case 0x123e:
			//% "MSC ID alarm"
			errorText = qsTrId("fp-genset-error_msc_id_alarm")
			break;
		case 0x123f:
			//% "MSC failure"
			errorText = qsTrId("fp-genset-error_msc_failure")
			break;
		case 0x1240:
			//% "MSC priority Error"
			errorText = qsTrId("fp-genset-error_msc_priority_error")
			break;
		case 0x1241:
			//% "Fuel Sender open circuit"
			errorText = qsTrId("fp-genset-error_fuel_sender_open_circuit")
			break;
		case 0x1242:
			//% "Over speed runaway"
			errorText = qsTrId("fp-genset-error_over_speed_runaway")
			break;
		case 0x1243:
			//% "Over frequency run away"
			errorText = qsTrId("fp-genset-error_over_frequency_run_away")
			break;
		case 0x1244:
			//% "Coolant sensor open circuit"
			errorText = qsTrId("fp-genset-error_coolant_sensor_open_circuit")
			break;
		case 0x1245:
			//% "Remote display link lost"
			errorText = qsTrId("fp-genset-error_remote_display_link_lost")
			break;
		case 0x1246:
			//% "Fuel tank bund level"
			errorText = qsTrId("fp-genset-error_fuel_tank_bund_level")
			break;
		case 0x1247:
			//% "Charge air temperature"
			errorText = qsTrId("fp-genset-error_charge_air_temperature")
			break;
		case 0x1248:
			//% "Fuel level high"
			errorText = qsTrId("fp-genset-error_fuel_level_high")
			break;
		case 0x1249:
			//% "Gen breaker failed to open (v5.0+)"
			errorText = qsTrId("fp-genset-error_gen_breaker_failed_to_open_v5.0+")
			break;
		case 0x124a:
			//% "Mains breaker failed to open (v5.0+) – 7x20 only"
			errorText = qsTrId("fp-genset-error_mains_breaker_failed_to_open_v5.0+_–_7x20_only")
			break;
		case 0x124b:
			//% "Fail to synchronise (v5.0+) – 7x20 only"
			errorText = qsTrId("fp-genset-error_fail_to_synchronise_v5.0+_–_7x20_only")
			break;
		case 0x124c:
			//% "AVR Data Fail (v5.0+)"
			errorText = qsTrId("fp-genset-error_avr_data_fail_v5.0+")
			break;
		case 0x124d:
			//% "AVR DM1 Red Stop Lamp (v5.0+)"
			errorText = qsTrId("fp-genset-error_avr_dm1_red_stop_lamp_v5.0+")
			break;
		case 0x124e:
			//% "Escape Mode (v5.0+)"
			errorText = qsTrId("fp-genset-error_escape_mode_v5.0+")
			break;
		case 0x124f:
			//% "Coolant high temp electrical trip (v5.0+)"
			errorText = qsTrId("fp-genset-error_coolant_high_temp_electrical_trip_v5.0+")
			break;
		case 0x1300:
			//% "Emergency stop"
			errorText = qsTrId("fp-genset-error_emergency_stop")
			break;
		case 0x1301:
			//% "Low oil pressure"
			errorText = qsTrId("fp-genset-error_low_oil_pressure")
			break;
		case 0x1302:
			//% "High coolant temperature"
			errorText = qsTrId("fp-genset-error_high_coolant_temperature")
			break;
		case 0x1303:
			//% "Low coolant temperature"
			errorText = qsTrId("fp-genset-error_low_coolant_temperature")
			break;
		case 0x1304:
			//% "Under speed"
			errorText = qsTrId("fp-genset-error_under_speed")
			break;
		case 0x1305:
			//% "Over speed"
			errorText = qsTrId("fp-genset-error_over_speed")
			break;
		case 0x1306:
			//% "Generator Under frequency"
			errorText = qsTrId("fp-genset-error_generator_under_frequency")
			break;
		case 0x1307:
			//% "Generator Over frequency"
			errorText = qsTrId("fp-genset-error_generator_over_frequency")
			break;
		case 0x1308:
			//% "Generator low voltage"
			errorText = qsTrId("fp-genset-error_generator_low_voltage")
			break;
		case 0x1309:
			//% "Generator high voltage"
			errorText = qsTrId("fp-genset-error_generator_high_voltage")
			break;
		case 0x130a:
			//% "Battery low voltage"
			errorText = qsTrId("fp-genset-error_battery_low_voltage")
			break;
		case 0x130b:
			//% "Battery high voltage"
			errorText = qsTrId("fp-genset-error_battery_high_voltage")
			break;
		case 0x130c:
			//% "Charge alternator failure"
			errorText = qsTrId("fp-genset-error_charge_alternator_failure")
			break;
		case 0x130d:
			//% "Fail to start"
			errorText = qsTrId("fp-genset-error_fail_to_start")
			break;
		case 0x130e:
			//% "Fail to stop"
			errorText = qsTrId("fp-genset-error_fail_to_stop")
			break;
		case 0x130f:
			//% "Generator fail to close"
			errorText = qsTrId("fp-genset-error_generator_fail_to_close")
			break;
		case 0x1310:
			//% "Mains fail to close"
			errorText = qsTrId("fp-genset-error_mains_fail_to_close")
			break;
		case 0x1311:
			//% "Oil pressure sender fault"
			errorText = qsTrId("fp-genset-error_oil_pressure_sender_fault")
			break;
		case 0x1312:
			//% "Loss of magnetic pick up"
			errorText = qsTrId("fp-genset-error_loss_of_magnetic_pick_up")
			break;
		case 0x1313:
			//% "Magnetic pick up open circuit"
			errorText = qsTrId("fp-genset-error_magnetic_pick_up_open_circuit")
			break;
		case 0x1314:
			//% "Generator high current"
			errorText = qsTrId("fp-genset-error_generator_high_current")
			break;
		case 0x1315:
			//% "Calibration lost"
			errorText = qsTrId("fp-genset-error_calibration_lost")
			break;
		case 0x1316:
			//% "Low fuel level"
			errorText = qsTrId("fp-genset-error_low_fuel_level")
			break;
		case 0x1317:
			//% "CAN ECU Warning"
			errorText = qsTrId("fp-genset-error_can_ecu_warning")
			break;
		case 0x1318:
			//% "CAN ECU Shutdown"
			errorText = qsTrId("fp-genset-error_can_ecu_shutdown")
			break;
		case 0x1319:
			//% "CAN ECU Data fail"
			errorText = qsTrId("fp-genset-error_can_ecu_data_fail")
			break;
		case 0x131a:
			//% "Low oil level switch"
			errorText = qsTrId("fp-genset-error_low_oil_level_switch")
			break;
		case 0x131b:
			//% "High temperature switch"
			errorText = qsTrId("fp-genset-error_high_temperature_switch")
			break;
		case 0x131c:
			//% "Low fuel level switch"
			errorText = qsTrId("fp-genset-error_low_fuel_level_switch")
			break;
		case 0x131d:
			//% "Expansion unit watchdog alarm"
			errorText = qsTrId("fp-genset-error_expansion_unit_watchdog_alarm")
			break;
		case 0x131e:
			//% "kW overload alarm"
			errorText = qsTrId("fp-genset-error_kw_overload_alarm")
			break;
		case 0x131f:
			//% "Negative phase sequence current alarm"
			errorText = qsTrId("fp-genset-error_negative_phase_sequence_current_alarm")
			break;
		case 0x1320:
			//% "Earth fault trip alarm"
			errorText = qsTrId("fp-genset-error_earth_fault_trip_alarm")
			break;
		case 0x1321:
			//% "Generator phase rotation alarm"
			errorText = qsTrId("fp-genset-error_generator_phase_rotation_alarm")
			break;
		case 0x1322:
			//% "Auto Voltage Sense Fail"
			errorText = qsTrId("fp-genset-error_auto_voltage_sense_fail")
			break;
		case 0x1323:
			//% "Maintenance alarm"
			errorText = qsTrId("fp-genset-error_maintenance_alarm")
			break;
		case 0x1324:
			//% "Loading frequency alarm"
			errorText = qsTrId("fp-genset-error_loading_frequency_alarm")
			break;
		case 0x1325:
			//% "Loading voltage alarm"
			errorText = qsTrId("fp-genset-error_loading_voltage_alarm")
			break;
		case 0x1326:
			//% "Fuel usage running"
			errorText = qsTrId("fp-genset-error_fuel_usage_running")
			break;
		case 0x1327:
			//% "Fuel usage stopped"
			errorText = qsTrId("fp-genset-error_fuel_usage_stopped")
			break;
		case 0x1328:
			//% "Protections disabled"
			errorText = qsTrId("fp-genset-error_protections_disabled")
			break;
		case 0x1329:
			//% "Protections blocked"
			errorText = qsTrId("fp-genset-error_protections_blocked")
			break;
		case 0x132a:
			//% "Generator breaker failed to open"
			errorText = qsTrId("fp-genset-error_generator_breaker_failed_to_open")
			break;
		case 0x132b:
			//% "Mains breaker failed to open"
			errorText = qsTrId("fp-genset-error_mains_breaker_failed_to_open")
			break;
		case 0x132c:
			//% "Bus breaker failed to close"
			errorText = qsTrId("fp-genset-error_bus_breaker_failed_to_close")
			break;
		case 0x132d:
			//% "Bus breaker failed to open"
			errorText = qsTrId("fp-genset-error_bus_breaker_failed_to_open")
			break;
		case 0x132e:
			//% "Generator reverse power alarm"
			errorText = qsTrId("fp-genset-error_generator_reverse_power_alarm")
			break;
		case 0x132f:
			//% "Short circuit alarm"
			errorText = qsTrId("fp-genset-error_short_circuit_alarm")
			break;
		case 0x1330:
			//% "Air flap closed alarm"
			errorText = qsTrId("fp-genset-error_air_flap_closed_alarm")
			break;
		case 0x1331:
			//% "Failure to sync"
			errorText = qsTrId("fp-genset-error_failure_to_sync")
			break;
		case 0x1332:
			//% "Bus live"
			errorText = qsTrId("fp-genset-error_bus_live")
			break;
		case 0x1333:
			//% "Bus not live"
			errorText = qsTrId("fp-genset-error_bus_not_live")
			break;
		case 0x1334:
			//% "Bus phase rotation"
			errorText = qsTrId("fp-genset-error_bus_phase_rotation")
			break;
		case 0x1335:
			//% "Priority selection error"
			errorText = qsTrId("fp-genset-error_priority_selection_error")
			break;
		case 0x1336:
			//% "MSC data error"
			errorText = qsTrId("fp-genset-error_msc_data_error")
			break;
		case 0x1337:
			//% "MSC ID error"
			errorText = qsTrId("fp-genset-error_msc_id_error")
			break;
		case 0x1338:
			//% "Bus low voltage"
			errorText = qsTrId("fp-genset-error_bus_low_voltage")
			break;
		case 0x1339:
			//% "Bus high voltage"
			errorText = qsTrId("fp-genset-error_bus_high_voltage")
			break;
		case 0x133a:
			//% "Bus low frequency"
			errorText = qsTrId("fp-genset-error_bus_low_frequency")
			break;
		case 0x133b:
			//% "Bus high frequency"
			errorText = qsTrId("fp-genset-error_bus_high_frequency")
			break;
		case 0x133c:
			//% "MSC failure"
			errorText = qsTrId("fp-genset-error_msc_failure")
			break;
		case 0x133d:
			//% "MSC too few sets"
			errorText = qsTrId("fp-genset-error_msc_too_few_sets")
			break;
		case 0x133e:
			//% "MSC alarms inhibited"
			errorText = qsTrId("fp-genset-error_msc_alarms_inhibited")
			break;
		case 0x133f:
			//% "MSC old version units on the bus"
			errorText = qsTrId("fp-genset-error_msc_old_version_units_on_the_bus")
			break;
		case 0x1340:
			//% "Mains reverse power alarm/mains export alarm"
			errorText = qsTrId("fp-genset-error_mains_reverse_power_alarm/mains_export_alarm")
			break;
		case 0x1341:
			//% "Minimum sets not reached"
			errorText = qsTrId("fp-genset-error_minimum_sets_not_reached")
			break;
		case 0x1342:
			//% "Insufficient capacity"
			errorText = qsTrId("fp-genset-error_insufficient_capacity")
			break;
		case 0x1343:
			//% "Out of sync"
			errorText = qsTrId("fp-genset-error_out_of_sync")
			break;
		case 0x1344:
			//% "Alternative aux mains fail"
			errorText = qsTrId("fp-genset-error_alternative_aux_mains_fail")
			break;
		case 0x1345:
			//% "Loss of excitation"
			errorText = qsTrId("fp-genset-error_loss_of_excitation")
			break;
		case 0x1346:
			//% "Mains ROCOF"
			errorText = qsTrId("fp-genset-error_mains_rocof")
			break;
		case 0x1347:
			//% "Mains vector shift"
			errorText = qsTrId("fp-genset-error_mains_vector_shift")
			break;
		case 0x1348:
			//% "Mains decoupling low frequency stage 1"
			errorText = qsTrId("fp-genset-error_mains_decoupling_low_frequency_stage_1")
			break;
		case 0x1349:
			//% "Mains decoupling high frequency stage 1"
			errorText = qsTrId("fp-genset-error_mains_decoupling_high_frequency_stage_1")
			break;
		case 0x134a:
			//% "Mains decoupling low voltage stage 1"
			errorText = qsTrId("fp-genset-error_mains_decoupling_low_voltage_stage_1")
			break;
		case 0x134b:
			//% "Mains decoupling high voltage stage 1"
			errorText = qsTrId("fp-genset-error_mains_decoupling_high_voltage_stage_1")
			break;
		case 0x134c:
			//% "Mains decoupling combined alarm"
			errorText = qsTrId("fp-genset-error_mains_decoupling_combined_alarm")
			break;
		case 0x134d:
			//% "Inlet Temperature"
			errorText = qsTrId("fp-genset-error_inlet_temperature")
			break;
		case 0x134e:
			//% "Mains phase rotation alarm identifier"
			errorText = qsTrId("fp-genset-error_mains_phase_rotation_alarm_identifier")
			break;
		case 0x134f:
			//% "AVR Max Trim Limit alarm"
			errorText = qsTrId("fp-genset-error_avr_max_trim_limit_alarm")
			break;
		case 0x1350:
			//% "High coolant temperature electrical trip alarm"
			errorText = qsTrId("fp-genset-error_high_coolant_temperature_electrical_trip_alarm")
			break;
		case 0x1351:
			//% "Temperature sender open circuit alarm"
			errorText = qsTrId("fp-genset-error_temperature_sender_open_circuit_alarm")
			break;
		case 0x1352:
			//% "Out of sync Bus"
			errorText = qsTrId("fp-genset-error_out_of_sync_bus")
			break;
		case 0x1353:
			//% "Out of sync Mains"
			errorText = qsTrId("fp-genset-error_out_of_sync_mains")
			break;
		case 0x1354:
			//% "Bus 1 live"
			errorText = qsTrId("fp-genset-error_bus_1_live")
			break;
		case 0x1355:
			//% "Bus 1 Phase Rotation"
			errorText = qsTrId("fp-genset-error_bus_1_phase_rotation")
			break;
		case 0x1356:
			//% "Bus 2 live"
			errorText = qsTrId("fp-genset-error_bus_2_live")
			break;
		case 0x1357:
			//% "Bus 2 Phase Rotation"
			errorText = qsTrId("fp-genset-error_bus_2_phase_rotation")
			break;
		case 0x1359:
			//% "ECU protect"
			errorText = qsTrId("fp-genset-error_ecu_protect")
			break;
		case 0x135a:
			//% "ECU Malfunction"
			errorText = qsTrId("fp-genset-error_ecu_malfunction")
			break;
		case 0x135b:
			//% "Indication"
			errorText = qsTrId("fp-genset-error_indication")
			break;
		case 0x135e:
			//% "HEST Active"
			errorText = qsTrId("fp-genset-error_hest_active")
			break;
		case 0x135f:
			//% "DPTC Filter"
			errorText = qsTrId("fp-genset-error_dptc_filter")
			break;
		case 0x1360:
			//% "Water In Fuel"
			errorText = qsTrId("fp-genset-error_water_in_fuel")
			break;
		case 0x1361:
			//% "ECU Heater"
			errorText = qsTrId("fp-genset-error_ecu_heater")
			break;
		case 0x1362:
			//% "ECU Cooler"
			errorText = qsTrId("fp-genset-error_ecu_cooler")
			break;
		case 0x136c:
			//% "High fuel level"
			errorText = qsTrId("fp-genset-error_high_fuel_level")
			break;
		case 0x136e:
			//% "Module Communication Fail (8661)"
			errorText = qsTrId("fp-genset-error_module_communication_fail_8661")
			break;
		case 0x136f:
			//% "Bus Module Warning (8661)"
			errorText = qsTrId("fp-genset-error_bus_module_warning_8661")
			break;
		case 0x1370:
			//% "Bus Module Trip (8661)"
			errorText = qsTrId("fp-genset-error_bus_module_trip_8661")
			break;
		case 0x1371:
			//% "Mains Module Warning (8661)"
			errorText = qsTrId("fp-genset-error_mains_module_warning_8661")
			break;
		case 0x1372:
			//% "Mains Module Trip (8661)"
			errorText = qsTrId("fp-genset-error_mains_module_trip_8661")
			break;
		case 0x1373:
			//% "Load Live (8661)"
			errorText = qsTrId("fp-genset-error_load_live_8661")
			break;
		case 0x1374:
			//% "Load Not Live (8661)"
			errorText = qsTrId("fp-genset-error_load_not_live_8661")
			break;
		case 0x1375:
			//% "Load Phase Rotation (8661)"
			errorText = qsTrId("fp-genset-error_load_phase_rotation_8661")
			break;
		case 0x1376:
			//% "DEF Level Low"
			errorText = qsTrId("fp-genset-error_def_level_low")
			break;
		case 0x1377:
			//% "SCR Inducement"
			errorText = qsTrId("fp-genset-error_scr_inducement")
			break;
		case 0x1378:
			//% "Heater Sensor Failure Alarm"
			errorText = qsTrId("fp-genset-error_heater_sensor_failure_alarm")
			break;
		case 0x1379:
			//% "Mains Over Zero Sequence Volts Alarm"
			errorText = qsTrId("fp-genset-error_mains_over_zero_sequence_volts_alarm")
			break;
		case 0x137a:
			//% "Mains Under Positive Sequence Volts Alarm"
			errorText = qsTrId("fp-genset-error_mains_under_positive_sequence_volts_alarm")
			break;
		case 0x137b:
			//% "Mains Over Negative Sequence Volts Alarm"
			errorText = qsTrId("fp-genset-error_mains_over_negative_sequence_volts_alarm")
			break;
		case 0x137c:
			//% "Mains Asymmetry High Alarm"
			errorText = qsTrId("fp-genset-error_mains_asymmetry_high_alarm")
			break;
		case 0x137d:
			//% "Bus Over Zero Sequence Volts Alarm"
			errorText = qsTrId("fp-genset-error_bus_over_zero_sequence_volts_alarm")
			break;
		case 0x137e:
			//% "Bus Under Positive Sequence Volts Alarm"
			errorText = qsTrId("fp-genset-error_bus_under_positive_sequence_volts_alarm")
			break;
		case 0x137f:
			//% "Bus Over Negative Sequence Volts Alarm"
			errorText = qsTrId("fp-genset-error_bus_over_negative_sequence_volts_alarm")
			break;
		case 0x1380:
			//% "Bus Asymmetry High Alarm"
			errorText = qsTrId("fp-genset-error_bus_asymmetry_high_alarm")
			break;
		case 0x1381:
			//% "E-Trip Stop Inhibited"
			errorText = qsTrId("fp-genset-error_e-trip_stop_inhibited")
			break;
		case 0x1382:
			//% "Fuel Tank Bund Level High"
			errorText = qsTrId("fp-genset-error_fuel_tank_bund_level_high")
			break;
		case 0x1383:
			//% "MSC Link 1 Data Error"
			errorText = qsTrId("fp-genset-error_msc_link_1_data_error")
			break;
		case 0x1384:
			//% "MSC Link 2 Data Error"
			errorText = qsTrId("fp-genset-error_msc_link_2_data_error")
			break;
		case 0x1385:
			//% "Bus 2 Low Voltage"
			errorText = qsTrId("fp-genset-error_bus_2_low_voltage")
			break;
		case 0x1386:
			//% "Bus 2 High Voltage"
			errorText = qsTrId("fp-genset-error_bus_2_high_voltage")
			break;
		case 0x1387:
			//% "Bus 2 Low Frequency"
			errorText = qsTrId("fp-genset-error_bus_2_low_frequency")
			break;
		case 0x1388:
			//% "Bus 2 High Frequency"
			errorText = qsTrId("fp-genset-error_bus_2_high_frequency")
			break;
		case 0x1389:
			//% "MSC Link 1 Failure"
			errorText = qsTrId("fp-genset-error_msc_link_1_failure")
			break;
		case 0x138a:
			//% "MSC Link 2 Failure"
			errorText = qsTrId("fp-genset-error_msc_link_2_failure")
			break;
		case 0x138b:
			//% "MSC Link 1 Too Few Sets"
			errorText = qsTrId("fp-genset-error_msc_link_1_too_few_sets")
			break;
		case 0x138c:
			//% "MSC Link 2 Too Few Sets"
			errorText = qsTrId("fp-genset-error_msc_link_2_too_few_sets")
			break;
		case 0x138d:
			//% "MSC Link 1 and 2 Failure"
			errorText = qsTrId("fp-genset-error_msc_link_1_and_2_failure")
			break;
		case 0x138e:
			//% "Electrical Trip from 8660"
			errorText = qsTrId("fp-genset-error_electrical_trip_from_8660")
			break;
		case 0x138f:
			//% "AVR CAN DM1 Red Stop Lamp Fault"
			errorText = qsTrId("fp-genset-error_avr_can_dm1_red_stop_lamp_fault")
			break;
		case 0x1390:
			//% "Gen Over Zero Sequence Volts Alarm"
			errorText = qsTrId("fp-genset-error_gen_over_zero_sequence_volts_alarm")
			break;
		case 0x1391:
			//% "Gen Under Positive Sequence Volts Alarm"
			errorText = qsTrId("fp-genset-error_gen_under_positive_sequence_volts_alarm")
			break;
		case 0x1392:
			//% "Gen Over Negative Sequence Volts Alarm"
			errorText = qsTrId("fp-genset-error_gen_over_negative_sequence_volts_alarm")
			break;
		case 0x1393:
			//% "Gen Asymmetry High Alarm"
			errorText = qsTrId("fp-genset-error_gen_asymmetry_high_alarm")
			break;
		case 0x1394:
			//% "Mains decoupling low frequency stage 2"
			errorText = qsTrId("fp-genset-error_mains_decoupling_low_frequency_stage_2")
			break;
		case 0x1395:
			//% "Mains decoupling high frequency stage 2"
			errorText = qsTrId("fp-genset-error_mains_decoupling_high_frequency_stage_2")
			break;
		case 0x1396:
			//% "Mains decoupling low voltage stage 2"
			errorText = qsTrId("fp-genset-error_mains_decoupling_low_voltage_stage_2")
			break;
		case 0x1397:
			//% "Mains decoupling high voltage stage 2"
			errorText = qsTrId("fp-genset-error_mains_decoupling_high_voltage_stage_2")
			break;
		case 0x1398:
			//% "Fault Ride Through event"
			errorText = qsTrId("fp-genset-error_fault_ride_through_event")
			break;
		case 0x1399:
			//% "AVR Data Fail"
			errorText = qsTrId("fp-genset-error_avr_data_fail")
			break;
		case 0x139a:
			//% "AVR Red Lamp"
			errorText = qsTrId("fp-genset-error_avr_red_lamp")
			break;
		case 0x1400:
			//% "Emergency stop"
			errorText = qsTrId("fp-genset-error_emergency_stop")
			break;
		case 0x1401:
			//% "Low oil pressure"
			errorText = qsTrId("fp-genset-error_low_oil_pressure")
			break;
		case 0x1402:
			//% "High coolant temperature"
			errorText = qsTrId("fp-genset-error_high_coolant_temperature")
			break;
		case 0x1403:
			//% "Low coolant temperature"
			errorText = qsTrId("fp-genset-error_low_coolant_temperature")
			break;
		case 0x1404:
			//% "Under speed"
			errorText = qsTrId("fp-genset-error_under_speed")
			break;
		case 0x1405:
			//% "Over speed"
			errorText = qsTrId("fp-genset-error_over_speed")
			break;
		case 0x1406:
			//% "Generator Under frequency"
			errorText = qsTrId("fp-genset-error_generator_under_frequency")
			break;
		case 0x1407:
			//% "Generator Over frequency"
			errorText = qsTrId("fp-genset-error_generator_over_frequency")
			break;
		case 0x1408:
			//% "Generator low voltage"
			errorText = qsTrId("fp-genset-error_generator_low_voltage")
			break;
		case 0x1409:
			//% "Generator high voltage"
			errorText = qsTrId("fp-genset-error_generator_high_voltage")
			break;
		case 0x140a:
			//% "Battery low voltage"
			errorText = qsTrId("fp-genset-error_battery_low_voltage")
			break;
		case 0x140b:
			//% "Battery high voltage"
			errorText = qsTrId("fp-genset-error_battery_high_voltage")
			break;
		case 0x140c:
			//% "Charge alternator failure"
			errorText = qsTrId("fp-genset-error_charge_alternator_failure")
			break;
		case 0x140d:
			//% "Fail to start"
			errorText = qsTrId("fp-genset-error_fail_to_start")
			break;
		case 0x140e:
			//% "Fail to stop"
			errorText = qsTrId("fp-genset-error_fail_to_stop")
			break;
		case 0x140f:
			//% "Generator fail to close"
			errorText = qsTrId("fp-genset-error_generator_fail_to_close")
			break;
		case 0x1410:
			//% "Mains fail to close"
			errorText = qsTrId("fp-genset-error_mains_fail_to_close")
			break;
		case 0x1411:
			//% "Oil pressure sender fault"
			errorText = qsTrId("fp-genset-error_oil_pressure_sender_fault")
			break;
		case 0x1412:
			//% "Loss of magnetic pick up"
			errorText = qsTrId("fp-genset-error_loss_of_magnetic_pick_up")
			break;
		case 0x1413:
			//% "Magnetic pick up open circuit"
			errorText = qsTrId("fp-genset-error_magnetic_pick_up_open_circuit")
			break;
		case 0x1414:
			//% "Generator high current"
			errorText = qsTrId("fp-genset-error_generator_high_current")
			break;
		case 0x1415:
			//% "Calibration lost"
			errorText = qsTrId("fp-genset-error_calibration_lost")
			break;
		case 0x1416:
			//% "Low fuel level"
			errorText = qsTrId("fp-genset-error_low_fuel_level")
			break;
		case 0x1417:
			//% "CAN ECU Warning"
			errorText = qsTrId("fp-genset-error_can_ecu_warning")
			break;
		case 0x1418:
			//% "CAN ECU Shutdown"
			errorText = qsTrId("fp-genset-error_can_ecu_shutdown")
			break;
		case 0x1419:
			//% "CAN ECU Data fail"
			errorText = qsTrId("fp-genset-error_can_ecu_data_fail")
			break;
		case 0x141a:
			//% "Low oil level switch"
			errorText = qsTrId("fp-genset-error_low_oil_level_switch")
			break;
		case 0x141b:
			//% "High temperature switch"
			errorText = qsTrId("fp-genset-error_high_temperature_switch")
			break;
		case 0x141c:
			//% "Low fuel level switch"
			errorText = qsTrId("fp-genset-error_low_fuel_level_switch")
			break;
		case 0x141d:
			//% "Expansion unit watchdog alarm"
			errorText = qsTrId("fp-genset-error_expansion_unit_watchdog_alarm")
			break;
		case 0x141e:
			//% "kW overload alarm"
			errorText = qsTrId("fp-genset-error_kw_overload_alarm")
			break;
		case 0x141f:
			//% "Negative phase sequence current alarm"
			errorText = qsTrId("fp-genset-error_negative_phase_sequence_current_alarm")
			break;
		case 0x1420:
			//% "Earth fault trip alarm"
			errorText = qsTrId("fp-genset-error_earth_fault_trip_alarm")
			break;
		case 0x1421:
			//% "Generator phase rotation alarm"
			errorText = qsTrId("fp-genset-error_generator_phase_rotation_alarm")
			break;
		case 0x1422:
			//% "Auto Voltage Sense Fail"
			errorText = qsTrId("fp-genset-error_auto_voltage_sense_fail")
			break;
		case 0x1423:
			//% "Maintenance alarm"
			errorText = qsTrId("fp-genset-error_maintenance_alarm")
			break;
		case 0x1424:
			//% "Loading frequency alarm"
			errorText = qsTrId("fp-genset-error_loading_frequency_alarm")
			break;
		case 0x1425:
			//% "Loading voltage alarm"
			errorText = qsTrId("fp-genset-error_loading_voltage_alarm")
			break;
		case 0x1426:
			//% "Fuel usage running"
			errorText = qsTrId("fp-genset-error_fuel_usage_running")
			break;
		case 0x1427:
			//% "Fuel usage stopped"
			errorText = qsTrId("fp-genset-error_fuel_usage_stopped")
			break;
		case 0x1428:
			//% "Protections disabled"
			errorText = qsTrId("fp-genset-error_protections_disabled")
			break;
		case 0x1429:
			//% "Protections blocked"
			errorText = qsTrId("fp-genset-error_protections_blocked")
			break;
		case 0x142a:
			//% "Generator breaker failed to open"
			errorText = qsTrId("fp-genset-error_generator_breaker_failed_to_open")
			break;
		case 0x142b:
			//% "Mains breaker failed to open"
			errorText = qsTrId("fp-genset-error_mains_breaker_failed_to_open")
			break;
		case 0x142c:
			//% "Bus breaker failed to close"
			errorText = qsTrId("fp-genset-error_bus_breaker_failed_to_close")
			break;
		case 0x142d:
			//% "Bus breaker failed to open"
			errorText = qsTrId("fp-genset-error_bus_breaker_failed_to_open")
			break;
		case 0x142e:
			//% "Generator reverse power alarm"
			errorText = qsTrId("fp-genset-error_generator_reverse_power_alarm")
			break;
		case 0x142f:
			//% "Short circuit alarm"
			errorText = qsTrId("fp-genset-error_short_circuit_alarm")
			break;
		case 0x1430:
			//% "Air flap closed alarm"
			errorText = qsTrId("fp-genset-error_air_flap_closed_alarm")
			break;
		case 0x1431:
			//% "Failure to sync"
			errorText = qsTrId("fp-genset-error_failure_to_sync")
			break;
		case 0x1432:
			//% "Bus live"
			errorText = qsTrId("fp-genset-error_bus_live")
			break;
		case 0x1433:
			//% "Bus not live"
			errorText = qsTrId("fp-genset-error_bus_not_live")
			break;
		case 0x1434:
			//% "Bus phase rotation"
			errorText = qsTrId("fp-genset-error_bus_phase_rotation")
			break;
		case 0x1435:
			//% "Priority selection error"
			errorText = qsTrId("fp-genset-error_priority_selection_error")
			break;
		case 0x1436:
			//% "MSC data error"
			errorText = qsTrId("fp-genset-error_msc_data_error")
			break;
		case 0x1437:
			//% "MSC ID error"
			errorText = qsTrId("fp-genset-error_msc_id_error")
			break;
		case 0x1438:
			//% "Bus low voltage"
			errorText = qsTrId("fp-genset-error_bus_low_voltage")
			break;
		case 0x1439:
			//% "Bus high voltage"
			errorText = qsTrId("fp-genset-error_bus_high_voltage")
			break;
		case 0x143a:
			//% "Bus low frequency"
			errorText = qsTrId("fp-genset-error_bus_low_frequency")
			break;
		case 0x143b:
			//% "Bus high frequency"
			errorText = qsTrId("fp-genset-error_bus_high_frequency")
			break;
		case 0x143c:
			//% "MSC failure"
			errorText = qsTrId("fp-genset-error_msc_failure")
			break;
		case 0x143d:
			//% "MSC too few sets"
			errorText = qsTrId("fp-genset-error_msc_too_few_sets")
			break;
		case 0x143e:
			//% "MSC alarms inhibited"
			errorText = qsTrId("fp-genset-error_msc_alarms_inhibited")
			break;
		case 0x143f:
			//% "MSC old version units on the bus"
			errorText = qsTrId("fp-genset-error_msc_old_version_units_on_the_bus")
			break;
		case 0x1440:
			//% "Mains reverse power alarm/mains export alarm"
			errorText = qsTrId("fp-genset-error_mains_reverse_power_alarm/mains_export_alarm")
			break;
		case 0x1441:
			//% "Minimum sets not reached"
			errorText = qsTrId("fp-genset-error_minimum_sets_not_reached")
			break;
		case 0x1442:
			//% "Insufficient capacity"
			errorText = qsTrId("fp-genset-error_insufficient_capacity")
			break;
		case 0x1443:
			//% "Out of sync"
			errorText = qsTrId("fp-genset-error_out_of_sync")
			break;
		case 0x1444:
			//% "Alternative aux mains fail"
			errorText = qsTrId("fp-genset-error_alternative_aux_mains_fail")
			break;
		case 0x1445:
			//% "Loss of excitation"
			errorText = qsTrId("fp-genset-error_loss_of_excitation")
			break;
		case 0x1446:
			//% "Mains ROCOF"
			errorText = qsTrId("fp-genset-error_mains_rocof")
			break;
		case 0x1447:
			//% "Mains vector shift"
			errorText = qsTrId("fp-genset-error_mains_vector_shift")
			break;
		case 0x1448:
			//% "Mains decoupling low frequency"
			errorText = qsTrId("fp-genset-error_mains_decoupling_low_frequency")
			break;
		case 0x1449:
			//% "Mains decoupling high frequency"
			errorText = qsTrId("fp-genset-error_mains_decoupling_high_frequency")
			break;
		case 0x144a:
			//% "Mains decoupling low voltage"
			errorText = qsTrId("fp-genset-error_mains_decoupling_low_voltage")
			break;
		case 0x144b:
			//% "Mains decoupling high voltage"
			errorText = qsTrId("fp-genset-error_mains_decoupling_high_voltage")
			break;
		case 0x144c:
			//% "Mains decoupling combined alarm"
			errorText = qsTrId("fp-genset-error_mains_decoupling_combined_alarm")
			break;
		case 0x144d:
			//% "Charge air temperature"
			errorText = qsTrId("fp-genset-error_charge_air_temperature")
			break;
		case 0x144e:
			//% "Mains phase rotation alarm identifier"
			errorText = qsTrId("fp-genset-error_mains_phase_rotation_alarm_identifier")
			break;
		case 0x144f:
			//% "AVR Max Trim Limit alarm"
			errorText = qsTrId("fp-genset-error_avr_max_trim_limit_alarm")
			break;
		case 0x1450:
			//% "High coolant temperature electrical trip alarm"
			errorText = qsTrId("fp-genset-error_high_coolant_temperature_electrical_trip_alarm")
			break;
		case 0x1451:
			//% "Temperature sender open circuit alarm"
			errorText = qsTrId("fp-genset-error_temperature_sender_open_circuit_alarm")
			break;
		case 0x1459:
			//% "ECU protect"
			errorText = qsTrId("fp-genset-error_ecu_protect")
			break;
		case 0x145a:
			//% "ECU Malfunction"
			errorText = qsTrId("fp-genset-error_ecu_malfunction")
			break;
		case 0x145b:
			//% "Indication"
			errorText = qsTrId("fp-genset-error_indication")
			break;
		case 0x145c:
			//% "ECU Red"
			errorText = qsTrId("fp-genset-error_ecu_red")
			break;
		case 0x145d:
			//% "ECU Amber"
			errorText = qsTrId("fp-genset-error_ecu_amber")
			break;
		case 0x145e:
			//% "Electrical Trip"
			errorText = qsTrId("fp-genset-error_electrical_trip")
			break;
		case 0x145f:
			//% "Aftertreatment Exhaust"
			errorText = qsTrId("fp-genset-error_aftertreatment_exhaust")
			break;
		case 0x1460:
			//% "Water In Fuel"
			errorText = qsTrId("fp-genset-error_water_in_fuel")
			break;
		case 0x1461:
			//% "ECU Heater"
			errorText = qsTrId("fp-genset-error_ecu_heater")
			break;
		case 0x1462:
			//% "ECU Cooler"
			errorText = qsTrId("fp-genset-error_ecu_cooler")
			break;
		case 0x1463:
			//% "DC Total Watts Overload"
			errorText = qsTrId("fp-genset-error_dc_total_watts_overload")
			break;
		case 0x1464:
			//% "High Plant Battery Temperature"
			errorText = qsTrId("fp-genset-error_high_plant_battery_temperature")
			break;
		case 0x1465:
			//% "Low Plant Battery Temperature"
			errorText = qsTrId("fp-genset-error_low_plant_battery_temperature")
			break;
		case 0x1466:
			//% "Low Plant Battery Voltage"
			errorText = qsTrId("fp-genset-error_low_plant_battery_voltage")
			break;
		case 0x1467:
			//% "High Plant Battery Voltage"
			errorText = qsTrId("fp-genset-error_high_plant_battery_voltage")
			break;
		case 0x1468:
			//% "Plant Battery Depth Of Discharge"
			errorText = qsTrId("fp-genset-error_plant_battery_depth_of_discharge")
			break;
		case 0x1469:
			//% "DC Battery Over Current"
			errorText = qsTrId("fp-genset-error_dc_battery_over_current")
			break;
		case 0x146a:
			//% "DC Load Over Current"
			errorText = qsTrId("fp-genset-error_dc_load_over_current")
			break;
		case 0x146b:
			//% "High Total DC Current"
			errorText = qsTrId("fp-genset-error_high_total_dc_current")
			break;
		case 0x1500:
			//% "Emergency stop"
			errorText = qsTrId("fp-genset-error_emergency_stop")
			break;
		case 0x1501:
			//% "Low oil pressure"
			errorText = qsTrId("fp-genset-error_low_oil_pressure")
			break;
		case 0x1502:
			//% "High coolant temperature"
			errorText = qsTrId("fp-genset-error_high_coolant_temperature")
			break;
		case 0x1503:
			//% "Low coolant temperature"
			errorText = qsTrId("fp-genset-error_low_coolant_temperature")
			break;
		case 0x1504:
			//% "Under speed"
			errorText = qsTrId("fp-genset-error_under_speed")
			break;
		case 0x1505:
			//% "Over speed"
			errorText = qsTrId("fp-genset-error_over_speed")
			break;
		case 0x1506:
			//% "Generator Under frequency"
			errorText = qsTrId("fp-genset-error_generator_under_frequency")
			break;
		case 0x1507:
			//% "Generator Over frequency"
			errorText = qsTrId("fp-genset-error_generator_over_frequency")
			break;
		case 0x1508:
			//% "Generator low voltage"
			errorText = qsTrId("fp-genset-error_generator_low_voltage")
			break;
		case 0x1509:
			//% "Generator high voltage"
			errorText = qsTrId("fp-genset-error_generator_high_voltage")
			break;
		case 0x150a:
			//% "Battery low voltage"
			errorText = qsTrId("fp-genset-error_battery_low_voltage")
			break;
		case 0x150b:
			//% "Battery high voltage"
			errorText = qsTrId("fp-genset-error_battery_high_voltage")
			break;
		case 0x150c:
			//% "Charge alternator failure"
			errorText = qsTrId("fp-genset-error_charge_alternator_failure")
			break;
		case 0x150d:
			//% "Fail to start"
			errorText = qsTrId("fp-genset-error_fail_to_start")
			break;
		case 0x150e:
			//% "Fail to stop"
			errorText = qsTrId("fp-genset-error_fail_to_stop")
			break;
		case 0x150f:
			//% "Generator fail to close"
			errorText = qsTrId("fp-genset-error_generator_fail_to_close")
			break;
		case 0x1510:
			//% "Mains fail to close"
			errorText = qsTrId("fp-genset-error_mains_fail_to_close")
			break;
		case 0x1511:
			//% "Oil pressure sender fault"
			errorText = qsTrId("fp-genset-error_oil_pressure_sender_fault")
			break;
		case 0x1512:
			//% "Loss of Mag Pickup signal"
			errorText = qsTrId("fp-genset-error_loss_of_mag_pickup_signal")
			break;
		case 0x1513:
			//% "Magnetic pick up open circuit"
			errorText = qsTrId("fp-genset-error_magnetic_pick_up_open_circuit")
			break;
		case 0x1514:
			//% "Generator high current"
			errorText = qsTrId("fp-genset-error_generator_high_current")
			break;
		case 0x1515:
			//% "Calibration lost"
			errorText = qsTrId("fp-genset-error_calibration_lost")
			break;
		case 0x1517:
			//% "CAN ECU Warning"
			errorText = qsTrId("fp-genset-error_can_ecu_warning")
			break;
		case 0x1518:
			//% "CAN ECU Shutdown"
			errorText = qsTrId("fp-genset-error_can_ecu_shutdown")
			break;
		case 0x1519:
			//% "CAN ECU Data fail"
			errorText = qsTrId("fp-genset-error_can_ecu_data_fail")
			break;
		case 0x151a:
			//% "Low oil level switch"
			errorText = qsTrId("fp-genset-error_low_oil_level_switch")
			break;
		case 0x151b:
			//% "High temperature switch"
			errorText = qsTrId("fp-genset-error_high_temperature_switch")
			break;
		case 0x151c:
			//% "Low fuel level switch"
			errorText = qsTrId("fp-genset-error_low_fuel_level_switch")
			break;
		case 0x151d:
			//% "Expansion unit watchdog alarm"
			errorText = qsTrId("fp-genset-error_expansion_unit_watchdog_alarm")
			break;
		case 0x151e:
			//% "kW overload alarm"
			errorText = qsTrId("fp-genset-error_kw_overload_alarm")
			break;
		case 0x151f:
			//% "Negative phase sequence alarm"
			errorText = qsTrId("fp-genset-error_negative_phase_sequence_alarm")
			break;
		case 0x1520:
			//% "Earth fault trip"
			errorText = qsTrId("fp-genset-error_earth_fault_trip")
			break;
		case 0x1521:
			//% "Generator phase rotation alarm"
			errorText = qsTrId("fp-genset-error_generator_phase_rotation_alarm")
			break;
		case 0x1522:
			//% "Auto Voltage Sense Fail"
			errorText = qsTrId("fp-genset-error_auto_voltage_sense_fail")
			break;
		case 0x1524:
			//% "Temperature sensor open circuit"
			errorText = qsTrId("fp-genset-error_temperature_sensor_open_circuit")
			break;
		case 0x1525:
			//% "Low fuel level"
			errorText = qsTrId("fp-genset-error_low_fuel_level")
			break;
		case 0x1526:
			//% "High fuel level"
			errorText = qsTrId("fp-genset-error_high_fuel_level")
			break;
		case 0x1527:
			//% "Water In Fuel"
			errorText = qsTrId("fp-genset-error_water_in_fuel")
			break;
		case 0x1528:
			//% "DEF Level Low"
			errorText = qsTrId("fp-genset-error_def_level_low")
			break;
		case 0x1529:
			//% "SCR Inducement"
			errorText = qsTrId("fp-genset-error_scr_inducement")
			break;
		case 0x152a:
			//% "HEST Active"
			errorText = qsTrId("fp-genset-error_hest_active")
			break;
		case 0x152b:
			//% "DPTC Filter"
			errorText = qsTrId("fp-genset-error_dptc_filter")
			break;
		}
		return errorText ? "#%1 %2".arg(dataItem.value).arg(errorText) : ""
	}
}

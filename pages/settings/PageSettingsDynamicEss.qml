/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	GradientListView {
		model: VisibleItemModel {
			ListRadioButtonGroup {
				id: dEssMode
				text: CommonWords.mode
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/DynamicEss/Mode"
				optionModel: [
					{ display: CommonWords.off, value: 0 },
					{ display: CommonWords.auto, value: 1 }
				]
			}

			ListRadioButtonGroup {
				//% "Operating mode"
				text: qsTrId("settings_dess_operating_mode")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/DynamicEss/OperatingMode"
				optionModel: [
					//% "Trade mode"
					{ display: qsTrId("settings_dess_trade_mode"), value: 0 },
					//% "Green mode"
					{ display: qsTrId("settings_dess_green_mode"), value: 1 }
				]
			}

                        ListQuantityField {
                                //% "Battery capacity"
				text: qsTrId("settings_dess_battery_capacity")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/DynamicEss/BatteryCapacity"
                                unit: VenusOS.Units_Energy_KiloWattHour
                                decimals: 1
                        }

                        ListQuantityField {
                                //% "Grid export limit"
				text: qsTrId("settings_dess_grid_export_limit")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/DynamicEss/GridExportLimit"
                                unit: VenusOS.Units_Energy_KiloWattHour
                                decimals: 1
                        }

                        ListQuantityField {
                                //% "Grid import limit"
				text: qsTrId("settings_dess_grid_import_limit")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/DynamicEss/GridImportLimit"
                                unit: VenusOS.Units_Energy_KiloWattHour
                                decimals: 1
                        }

                        ListQuantityField {
                                //% "Battery charge limit"
				text: qsTrId("settings_dess_battery_charge_limit")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/DynamicEss/BatteryChargeLimit"
                                unit: VenusOS.Units_Energy_KiloWattHour
                                decimals: 1
                        }

                        ListQuantityField {
                                //% "Battery discharge limit"
				text: qsTrId("settings_dess_battery_discharge_limit")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/DynamicEss/BatteryDischargeLimit"
                                unit: VenusOS.Units_Energy_KiloWattHour
                                decimals: 1
                        }

                        /* ListLink {
				//% "More configuration (provider and such) can be done via VRM"
                                text: qsTrId("settigs_dess_link_to_vrm")
                                url: "https://www.victronenergy.com"
                                      ""https://betavrm.victronenergy.com/installation/102195/settings/dynamic-ess
                        } */

			ListText {
				text: CommonWords.status
				dataItem.uid: Global.system.serviceUid + "/DynamicEss/Active"
				secondaryText: {
					switch (dataItem.value) {
					case 0: return CommonWords.inactive_status
					case 1: return CommonWords.auto
					//% "Buying"
					case 2: return qsTrId("settings_ess_buying")
					//% "Selling"
					case 3: return qsTrId("settings_ess_selling")
					default: return ""
					}
				}
			}

			ListText {
				//% "Restrictions
				text: qsTrId("system_dess_restrictions")
				dataItem.uid: Global.system.serviceUid + "/DynamicEss/Restrictions"
				preferredVisible: dEssMode.dataItem.value === 1
				secondaryText: {
					switch (dataItem.value) {
					case 0: return CommonWords.none
					//% "Battery to grid"
					case 1: return qsTrId("settings_dess_restrictions_battery2grid")
					//% "Grid to battery"
					case 2: return qsTrId("settings_dess_restrictions_grid2battery")
					dafault: return CommonWords.none
					}
				}
			}

			ListText {
				//% "Reactive strategy"
				text: qsTrId("system_dess_reactive_strategy")
				dataItem.uid: Global.system.serviceUid + "/DynamicEss/ReactiveStrategy"
				preferredVisible: dEssMode.dataItem.value === 1
				secondaryText: {
					switch (dataItem.value) {
					case 0: return CommonWords.none
					//% "Scheduled self consumption"
					case 1: return qsTrId("settings_dess_rs_scheduled_selfconsume")
					//% "Scheduled charge (allow grid)"
					case 2: return qsTrId("settings_dess_rs_scheduled_charge_allow_grid")
					//% "Scheduled charge (enhanced)"
					case 3: return qsTrId("settings_dess_rs_scheduled_charge_enhanced")
					//% "Self consumption, accept charge"
					case 4: return qsTrId("settings_dess_rs_selfconsume_accept_charge")
					//% "Idle, scheduled feedin"
					case 5: return qsTrId("settings_dess_rs_idle_scheduled_feedin")
					//% "Scheduled discharge"
					case 6: return qsTrId("settings_dess_rs_scheduled_discharge")
					//% "Self consumption, accept discharge"
					case 7: return qsTrId("settings_dess_rs_selfconsume_accept_discharge")
					//% "Idle, maintain surplus"
					case 8: return qsTrId("settings_dess_rs_idle_maintain_surplus")
					//% "Idle, maintain targetsoc"
					case 9: return qsTrId("settings_dess_rs_idle_maintain_targetsoc")
					//% "Scheduled charge, smooth transition"
					case 10: return qsTrId("settings_dess_rs_scheduled_charge_smooth_transition")
					//% "Scheduled charge, feedin"
					case 11: return qsTrId("settings_dess_rs_scheduled_charge_feedin")
					//% "Scheduled charge, no grid""
					case 12: return qsTrId("settings_dess_rs_scheduled_charge_no_grid")
					//% "Scheduled minimum discharge"
					case 13: return qsTrId("settings_dess_rs_scheduled_minimum_discharge")
					//% "Selfconsume, no grid""
					case 14: return qsTrId("settings_dess_rs_selfconsume_no_grid")
					//% "Idle, no opportunity"
					case 15: return qsTrId("settings_dess_rs_idle_no_opportunity")
					//% "Unscheduled charge, catchup target soc"
					case 16: return qsTrId("settings_dess_rs_unscheduled_charge_catchup_targetsoc")
					dafault: return CommonWords.unknown
					}
				}
			}

			ListQuantity {
				//% "Minimum SOC"
				text: qsTrId("settings_ess_minimum_soc")
				preferredVisible: dEssMode.dataItem.value === 1
				dataItem.uid: Global.system.serviceUid + "/DynamicEss/MinimumSoc"
				unit: VenusOS.Units_Percentage
			}

			ListQuantity {
				//% "Target SOC"
				text: qsTrId("settings_ess_target_soc")
				preferredVisible: dEssMode.dataItem.value === 1
				dataItem.uid: Global.system.serviceUid + "/DynamicEss/TargetSoc"
				unit: VenusOS.Units_Percentage
			}
		}
	}
}

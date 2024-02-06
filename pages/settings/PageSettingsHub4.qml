/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	readonly property bool _valid: systemType.value === "ESS" || systemType.value === "Hub-4"

	//% "Self-consumption"
	readonly property string _selfConsumptionText: qsTrId("settings_ess_battery_life_self_consumption")

	Component {
		id: noEssHeader

		ListLabel {
			//% "No ESS Assistant found"
			text: qsTrId("settings_ess_no_ess_assistant")
		}
	}

	ObjectModel {
		id: essSettings

		ListRadioButtonGroup {
			text: CommonWords.mode
			optionModel: Global.ess.stateModel
			currentIndex: {
				for (let i = 0; i < optionModel.length; ++i) {
					if (optionModel[i].value === Global.ess.state) {
						return i
					}
				}
				return -1
			}
			updateOnClick: false

			onOptionClicked: function(index) {
				Global.ess.setStateRequested(optionModel[index].value)
			}
		}

		ListRadioButtonGroup {
			id: withoutGridMeter

			//% "Grid metering"
			text: qsTrId("settings_ess_grid_metering")
			dataItem.uid: Global.systemSettings.serviceUid + "/Settings/CGwacs/RunWithoutGridMeter"
			visible: defaultVisible && essMode.value !== VenusOS.Ess_Hub4ModeState_Disabled
			optionModel: [
				//% "External meter"
				{ display: qsTrId("settings_ess_external_meter"), value: 0 },
				//% "Inverter/Charger"
				{ display: qsTrId("settings_ess_inverter_charger"), value: 1 },
			]
		}

		ListSwitch {
			//% "Inverter AC output in use"
			text: qsTrId("settings_ess_inverter_ac_output_in_use")
			dataItem.uid: Global.systemSettings.serviceUid + "/Settings/SystemSetup/HasAcOutSystem"
			visible: defaultVisible && withoutGridMeter.currentIndex === 0
		}

		ListRadioButtonGroup {
			//% "Multiphase regulation"
			text: qsTrId("settings_ess_multiphase_regulation")
			dataItem.uid: essMode.uid
			visible: defaultVisible
				 && essMode.value !== VenusOS.Ess_Hub4ModeState_Disabled
				 && batteryLifeState.dataItem.value !== VenusOS.Ess_BatteryLifeState_KeepCharged
			defaultSecondaryText: ""
			optionModel: [
				//% "Total of all phases"
				{ display: qsTrId("settings_ess_phase_compensation"), value: VenusOS.Ess_Hub4ModeState_PhaseCompensation },
				//% "Individual phase"
				{ display: qsTrId("settings_ess_individual_phase"), value: VenusOS.Ess_Hub4ModeState_PhaseSplit },
			]
			onOptionClicked: function(index) {
				const newValue = optionModel[index].value
				if (newValue === VenusOS.Ess_Hub4ModeState_PhaseSplit) {
					//% "Each phase is regulated to individually achieve the grid setpoint (system efficiency is decreased).\n\nCAUTION: Use only if required by the utility provider."
					Global.showToastNotification(VenusOS.Notification_Info, qsTrId("settings_ess_multiphase_split_notif"))
				} else if (newValue === VenusOS.Ess_Hub4ModeState_PhaseCompensation ) {
					//% "The total of all phases is intelligently regulated to achieve the grid setpoint (system efficiency is optimised).\n\nUse unless prohibited by the utility provider."
					Global.showToastNotification(VenusOS.Notification_Info, qsTrId("settings_ess_multiphase_total_notif"))
				}
			}
		}

		ListButton {
			id: minSocLimit

			//% "Minimum SOC (unless grid fails)"
			text: qsTrId("settings_ess_min_soc")
			button.text: Global.ess.minimumStateOfCharge + "%"
			visible: defaultVisible
				&& essMode.value !== VenusOS.Ess_Hub4ModeState_Disabled
				&& batteryLifeState.dataItem.value !== VenusOS.Ess_BatteryLifeState_KeepCharged
			onClicked: Global.dialogLayer.open(minSocDialogComponent)

			Component {
				id: minSocDialogComponent

				ESSMinimumSOCDialog { }
			}
		}

		ListTextItem {
			//% "Active SOC limit"
			text: qsTrId("settings_ess_active_soc_limit")
			visible: defaultVisible
				&& essMode.value !== VenusOS.Ess_Hub4ModeState_Disabled
				&& Global.ess.isBatteryLifeActive(batteryLifeState.dataItem.value)
			secondaryText: Math.max(Global.ess.minimumStateOfCharge || 0, socLimit.value || 0) + "%"
		}

		ListRadioButtonGroup {
			//% "Peak shaving"
			text: qsTrId("settings_ess_peak_shaving")
			currentIndex: {
				if (batteryLifeState.dataItem.value === VenusOS.Ess_BatteryLifeState_KeepCharged) {
					return 1
				}
				return peakshaveItem.value === 1 ? 1 : 0
			}
			updateOnClick: false
			visible: defaultVisible && essMode.value !== VenusOS.Ess_Hub4ModeState_Disabled
			enabled: batteryLifeState.dataItem.value !== VenusOS.Ess_BatteryLifeState_KeepCharged
			optionModel: [
				//% "Above minimum SOC only"
				{ display: qsTrId("settings_ess_above_minimum_soc_only"), value: 0 },
				//% "Always"
				{ display: qsTrId("settings_ess_always"), value: 1 }
			]
			onOptionClicked: function(index) {
				peakshaveItem.setValue(index)
				if (index === 1) {
					//% "Use this option for peak shaving.\n\nThe peak shaving threshold is set using the AC input current limit setting.\n\nSee documentation for further information."
					Global.showToastNotification(VenusOS.Notification_Info, qsTrId("settings_ess_use_this_option_for_peak_shaving"))
				} else {
					//% "Use this option in systems that do not perform peak shaving."
					Global.showToastNotification(VenusOS.Notification_Info, qsTrId("settings_ess_do_not_perform_peak_shaving"))
				}
			}

			VeQuickItem {
				id: peakshaveItem

				uid: Global.systemSettings.serviceUid + "/Settings/CGwacs/AlwaysPeakShave"
			}
		}

		ListRadioButtonGroup {
			id: batteryLifeState

			//% "BatteryLife state"
			text: qsTrId("settings_ess_batteryLife_state")
			dataItem.uid: Global.systemSettings.serviceUid + "/Settings/CGwacs/BatteryLife/State"
			visible: defaultVisible
				&& essMode.value !== VenusOS.Ess_Hub4ModeState_Disabled
				&& Global.ess.isBatteryLifeActive(batteryLifeState.dataItem.value)
			enabled: false
			optionModel: [
				// Values below taken from MaintenanceState enum in dbus-cgwacs
				{ display: root._selfConsumptionText, value: 2 },
				{ display: root._selfConsumptionText, value: 3 },
				{ display: root._selfConsumptionText, value: 4 },
				//% "Discharge disabled"
				{ display: qsTrId("settings_ess_battery_life_discharge_disabled"), value: 5 },
				//% "Slow charge"
				{ display: qsTrId("settings_ess_battery_life_slow_charge"), value: 6 },
				//% "Sustain"
				{ display: qsTrId("settings_ess_battery_life_sustain"), value: 7 },
				//% "Recharge"
				{ display: qsTrId("settings_ess_battery_life_recharge"), value: 8 },
			]
		}

		ListSwitch {
			id: maxChargePowerSwitch

			//% "Limit charge power"
			text: qsTrId("settings_ess_limit_charge_power")
			checked: maxChargePower.value >= 0
			visible: defaultVisible
				&& essMode.value !== VenusOS.Ess_Hub4ModeState_Disabled
				&& !maxChargeCurrentControl.isValid

			onCheckedChanged: {
				if (checked && maxChargePower.value < 0) {
					maxChargePower.dataItem.setValue(1000)
				} else if (!checked && maxChargePower.value >= 0) {
					maxChargePower.dataItem.setValue(-1)
				}
			}
		}

		ListSpinBox {
			id: maxChargePower

			//% "Maximum charge power"
			text: qsTrId("settings_ess_max_charge_power")
			visible: defaultVisible && maxChargePowerSwitch.visible && maxChargePowerSwitch.checked
			dataItem.uid: Global.systemSettings.serviceUid + "/Settings/CGwacs/MaxChargePower"
			suffix: Units.defaultUnitString(VenusOS.Units_Watt)
			to: 200000
			stepSize: 50
		}

		ListSwitch {
			id: maxInverterPowerSwitch

			//% "Limit inverter power"
			text: qsTrId("settings_ess_limit_inverter_power")
			checked: maxDischargePower.value >= 0
			visible: defaultVisible
				&& essMode.value !== VenusOS.Ess_Hub4ModeState_Disabled
				&& batteryLifeState.dataItem.value !== VenusOS.Ess_BatteryLifeState_KeepCharged

			onCheckedChanged: {
				if (checked && maxDischargePower.value < 0) {
					maxDischargePower.dataItem.setValue(1000)
				} else if (!checked && maxDischargePower.value >= 0) {
					maxDischargePower.dataItem.setValue(-1)
				}
			}
		}

		ListSpinBox {
			id: maxDischargePower

			//% "Maximum inverter power"
			text: qsTrId("settings_ess_max_inverter_power")
			visible: defaultVisible && maxInverterPowerSwitch.visible && maxInverterPowerSwitch.checked
			dataItem.uid: Global.systemSettings.serviceUid + "/Settings/CGwacs/MaxDischargePower"
			suffix: Units.defaultUnitString(VenusOS.Units_Watt)
			to: 300000
			stepSize: 50
		}

		ListSpinBox {
			//% "Grid setpoint"
			text: qsTrId("settings_ess_grid_setpoint")
			visible: defaultVisible
				&& essMode.value !== VenusOS.Ess_Hub4ModeState_Disabled
				&& batteryLifeState.dataItem.value !== VenusOS.Ess_BatteryLifeState_KeepCharged
			dataItem.uid: Global.systemSettings.serviceUid + "/Settings/CGwacs/AcPowerSetPoint"
			suffix: Units.defaultUnitString(VenusOS.Units_Watt)
			stepSize: 10
		}

		ListNavigationItem {
			//% "Grid feed-in"
			text: qsTrId("settings_ess_grid_feed_in")
			visible: defaultVisible && essMode.value !== VenusOS.Ess_Hub4ModeState_Disabled

			onClicked: {
				Global.pageManager.pushPage("/pages/settings/PageSettingsHub4Feedin.qml",
					{ title: text, hub4Mode: Qt.binding(function() { return essMode.value }) })
			}
		}

		ListNavigationItem {
			//% "Scheduled charging"
			text: qsTrId("settings_ess_scheduled_charging")
			visible: defaultVisible
				&& essMode.value !== VenusOS.Ess_Hub4ModeState_Disabled
				&& batteryLifeState.dataItem.value !== VenusOS.Ess_BatteryLifeState_KeepCharged

			onClicked: {
				Global.pageManager.pushPage(scheduledChargeComponent, { title: text })
			}

			Component {
				id: scheduledChargeComponent

				Page {
					GradientListView {
						model: 5
						delegate: CGwacsBatteryScheduleNavigationItem {
							scheduleNumber: modelData
						}
					}
				}
			}
		}

		ListNavigationItem {
			text: CommonWords.debug
			visible: defaultVisible
				&& essMode.value !== VenusOS.Ess_Hub4ModeState_Disabled
				&& Global.systemSettings.canAccess(VenusOS.User_AccessType_Service)

			onClicked: {
				Global.pageManager.pushPage("/pages/settings/PageHub4Debug.qml")
			}
		}
	}

	GradientListView {
		header: root._valid ? null : noEssHeader
		model: root._valid ? essSettings : null
	}

	VeQuickItem {
		id: systemType
		uid: Global.system.serviceUid + "/SystemType"
	}

	VeQuickItem {
		id: essMode
		uid: Global.systemSettings.serviceUid + "/Settings/CGwacs/Hub4Mode"
	}

	VeQuickItem {
		id: socLimit
		uid: Global.systemSettings.serviceUid + "/Settings/CGwacs/BatteryLife/SocLimit"
	}

	VeQuickItem {
		id: maxChargeCurrentControl
		uid: Global.system.serviceUid + "/Control/MaxChargeCurrent"
	}
}

/*
** Copyright (C) 2022 Victron Energy B.V.
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

		SettingsLabel {
			//% "No ESS Assistant found"
			text: qsTrId("settings_ess_no_ess_assistant")
		}
	}

	ObjectModel {
		id: essSettings

		SettingsListRadioButtonGroup {
			//% "Mode"
			text: qsTrId("settings_ess_mode")
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

		SettingsListRadioButtonGroup {
			id: withoutGridMeter

			//% "Grid metering"
			text: qsTrId("settings_ess_grid_metering")
			source: "com.victronenergy.settings/Settings/CGwacs/RunWithoutGridMeter"
			visible: defaultVisible && essMode.value !== VenusOS.Ess_Hub4ModeState_Disabled
			optionModel: [
				//% "External meter"
				{ display: qsTrId("settings_ess_external_meter"), value: 0 },
				//% "Inverter/Charger"
				{ display: qsTrId("settings_ess_inverter_charger"), value: 1 },
			]
		}

		SettingsListSwitch {
			//% "Inverter AC output in use"
			text: qsTrId("settings_ess_inverter_ac_output_in_use")
			source: "com.victronenergy.settings/Settings/SystemSetup/HasAcOutSystem"
			visible: defaultVisible && withoutGridMeter.currentIndex === 0
		}

		SettingsListRadioButtonGroup {
			//% "Multiphase regulation"
			text: qsTrId("settings_ess_multiphase_regulation")
			source: essMode.source
			visible: defaultVisible
				 && essMode.value !== VenusOS.Ess_Hub4ModeState_Disabled
				 && batteryLifeState.dataPoint.value !== VenusOS.Ess_BatteryLifeState_KeepCharged
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
					Global.dialogManager.showToastNotification(VenusOS.Notification_Info, qsTrId("settings_ess_multiphase_split_notif"))
				} else if (newValue === VenusOS.Ess_Hub4ModeState_PhaseCompensation ) {
					//% "The total of all phases is intelligently regulated to achieve the grid setpoint (system efficiency is optimised).\n\nUse unless prohibited by the utility provider."
					Global.dialogManager.showToastNotification(VenusOS.Notification_Info, qsTrId("settings_ess_multiphase_total_notif"))
				}
			}
		}

		SettingsListButton {
			id: minSocLimit

			property var _minSocDialog

			//% "Minimum SOC (unless grid fails)"
			text: qsTrId("settings_ess_min_soc")
			button.text: Global.ess.minimumStateOfCharge + "%"
			visible: defaultVisible
				&& essMode.value !== VenusOS.Ess_Hub4ModeState_Disabled
				&& batteryLifeState.dataPoint.value !== VenusOS.Ess_BatteryLifeState_KeepCharged
			onClicked: {
				if (!_minSocDialog) {
					_minSocDialog = minSocDialogComponent.createObject(Global.dialogLayer)
				}
				_minSocDialog.open()
			}

			Component {
				id: minSocDialogComponent

				ESSMinimumSOCDialog { }
			}
		}

		SettingsListTextItem {
			//% "Active SOC limit"
			text: qsTrId("settings_ess_active_soc_limit")
			visible: defaultVisible
				&& essMode.value !== VenusOS.Ess_Hub4ModeState_Disabled
				&& Global.ess.isBatteryLifeActive(batteryLifeState.dataPoint.value)
			secondaryText: Math.max(Global.ess.minimumStateOfCharge.value || 0, socLimit.value || 0) + "%"
		}

		SettingsListRadioButtonGroup {
			id: batteryLifeState

			//% "BatteryLife state"
			text: qsTrId("settings_ess_batteryLife_state")
			source: "com.victronenergy.settings/Settings/CGwacs/BatteryLife/State"
			visible: defaultVisible
				&& essMode.value !== VenusOS.Ess_Hub4ModeState_Disabled
				&& Global.ess.isBatteryLifeActive(dataPoint.value)
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

		SettingsListSwitch {
			id: maxChargePowerSwitch

			//% "Limit charge power"
			text: qsTrId("settings_ess_limit_charge_power")
			checked: maxChargePower.value >= 0
			visible: defaultVisible
				&& essMode.value !== VenusOS.Ess_Hub4ModeState_Disabled
				&& !maxChargeCurrentControl.valid

			onCheckedChanged: {
				if (checked && maxChargePower.value < 0) {
					maxChargePower.dataPoint.setValue(1000)
				} else if (!checked && maxChargePower.value >= 0) {
					maxChargePower.dataPoint.setValue(-1)
				}
			}
		}

		SettingsListSpinBox {
			id: maxChargePower

			//% "Maximum charge power"
			text: qsTrId("settings_ess_max_charge_power")
			visible: defaultVisible && maxChargePowerSwitch.visible && maxChargePowerSwitch.checked
			source: "com.victronenergy.settings/Settings/CGwacs/MaxChargePower"
			suffix: "W"
			to: 200000
			stepSize: 50
		}

		SettingsListSwitch {
			id: maxInverterPowerSwitch

			//% "Limit inverter power"
			text: qsTrId("settings_ess_limit_inverter_power")
			checked: maxDischargePower.value >= 0
			visible: defaultVisible
				&& essMode.value !== VenusOS.Ess_Hub4ModeState_Disabled
				&& batteryLifeState.dataPoint.value !== VenusOS.Ess_BatteryLifeState_KeepCharged

			onCheckedChanged: {
				if (checked && maxDischargePower.value < 0) {
					maxDischargePower.dataPoint.setValue(1000)
				} else if (!checked && maxDischargePower.value >= 0) {
					maxDischargePower.dataPoint.setValue(-1)
				}
			}
		}

		SettingsListSpinBox {
			id: maxDischargePower

			//% "Maximum inverter power"
			text: qsTrId("settings_ess_max_inverter_power")
			visible: defaultVisible && maxInverterPowerSwitch.visible && maxInverterPowerSwitch.checked
			source: "com.victronenergy.settings/Settings/CGwacs/MaxDischargePower"
			suffix: "W"
			to: 300000
			stepSize: 50
		}

		SettingsListSpinBox {
			//% "Grid setpoint"
			text: qsTrId("settings_ess_grid_setpoint")
			visible: defaultVisible
				&& essMode.value !== VenusOS.Ess_Hub4ModeState_Disabled
				&& batteryLifeState.dataPoint.value !== VenusOS.Ess_BatteryLifeState_KeepCharged
			source: "com.victronenergy.settings/Settings/CGwacs/AcPowerSetPoint"
			suffix: "W"
			stepSize: 10
		}

		SettingsListNavigationItem {
			//% "Grid feed-in"
			text: qsTrId("settings_ess_grid_feed_in")
			visible: defaultVisible && essMode.value !== VenusOS.Ess_Hub4ModeState_Disabled

			onClicked: {
				Global.pageManager.pushPage("/pages/settings/PageSettingsHub4Feedin.qml",
					{ title: text, hub4Mode: Qt.binding(function() { return essMode.value }) })
			}
		}

		SettingsListNavigationItem {
			//% "Scheduled charging"
			text: qsTrId("settings_ess_scheduled_charging")
			visible: defaultVisible
				&& essMode.value !== VenusOS.Ess_Hub4ModeState_Disabled
				&& batteryLifeState.dataPoint.value !== VenusOS.Ess_BatteryLifeState_KeepCharged

			onClicked: {
				Global.pageManager.pushPage(scheduledChargeComponent, { title: text })
			}

			Component {
				id: scheduledChargeComponent

				Page {
					SettingsListView {
						model: 5
						delegate: SettingsListCGwacsBatterySchedule {
							scheduleNumber: modelData
						}
					}
				}
			}
		}

		SettingsListNavigationItem {
			//% "Debug"
			text: qsTrId("settings_ess_debug")
			visible: defaultVisible
				&& essMode.value !== VenusOS.Ess_Hub4ModeState_Disabled
				&& Global.systemSettings.canAccess(VenusOS.User_AccessType_Service)

			onClicked: {
				Global.pageManager.pushPage("/pages/settings/PageHub4Debug.qml")
			}
		}
	}

	SettingsListView {
		header: root._valid ? null : noEssHeader
		model: root._valid ? essSettings : null
	}

	DataPoint {
		id: systemType
		source: "com.victronenergy.system/SystemType"
	}

	DataPoint {
		id: essMode
		source: "com.victronenergy.settings/Settings/CGwacs/Hub4Mode"
	}

	DataPoint {
		id: socLimit
		source: "com.victronenergy.settings/Settings/CGwacs/BatteryLife/SocLimit"
	}

	DataPoint {
		id: maxChargeCurrentControl
		source: "com.victronenergy.system/Control/MaxChargeCurrent"
	}
}

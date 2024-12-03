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

		PrimaryListLabel {
			//% "No ESS Assistant found"
			text: qsTrId("settings_ess_no_ess_assistant")
		}
	}

	Component {
		id: hasAcSystem

		PrimaryListLabel {
			//% "For Multi-RS and HS19 devices, ESS settings are available on the RS System product page."
			text: qsTrId("settings_ess_rs_information")
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
			onOptionClicked: function(index) {
				Global.ess.setStateRequested(optionModel[index].value)
			}
		}

		ListRadioButtonGroup {
			id: withoutGridMeter

			//% "Grid metering"
			text: qsTrId("settings_ess_grid_metering")
			dataItem.uid: Global.systemSettings.serviceUid + "/Settings/CGwacs/RunWithoutGridMeter"
			allowed: defaultAllowed && essMode.value !== VenusOS.Ess_Hub4ModeState_Disabled
			optionModel: [
				//% "External meter"
				{ display: qsTrId("settings_ess_external_meter"), value: 0 },
				//% "Inverter/Charger"
				{ display: qsTrId("settings_ess_inverter_charger"), value: 1 },
			]
		}

		ListRadioButtonGroup {
			//% "Self-consumption from battery"
			text: qsTrId("settings_ess_self_consumption_battery")
			dataItem.uid: Global.systemSettings.serviceUid + "/Settings/CGwacs/BatteryUse"
			allowed: defaultAllowed && withoutGridMeter.currentIndex === 0 && hasAcOutSystemItem.value === 1
			optionModel: [
				//% "All system loads"
				{ display: qsTrId("settings_ess_all_system_loads"), value: 0 },
				//% "Only critical loads"
				{ display: qsTrId("settings_ess_only_critical_loads"), value: 1 },
			]
		}

		ListRadioButtonGroup {
			//% "Multiphase regulation"
			text: qsTrId("settings_ess_multiphase_regulation")
			dataItem.uid: essMode.uid
			allowed: defaultAllowed
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
			allowed: defaultAllowed
				&& essMode.value !== VenusOS.Ess_Hub4ModeState_Disabled
				&& batteryLifeState.dataItem.value !== VenusOS.Ess_BatteryLifeState_KeepCharged
			onClicked: Global.dialogLayer.open(minSocDialogComponent)

			Component {
				id: minSocDialogComponent

				ESSMinimumSOCDialog {
					minimumStateOfCharge: Global.ess.minimumStateOfCharge
					onAccepted: Global.ess.setMinimumStateOfChargeRequested(minimumStateOfCharge)
				}
			}
		}

		ListQuantity {
			//% "Active SOC limit"
			text: qsTrId("settings_ess_active_soc_limit")
			allowed: defaultAllowed
				&& essMode.value !== VenusOS.Ess_Hub4ModeState_Disabled
				&& Global.ess.isBatteryLifeActive(batteryLifeState.dataItem.value)
			value: Math.max(Global.ess.minimumStateOfCharge || 0, socLimit.value || 0)
			unit: VenusOS.Units_Percentage
		}

		ListRadioButtonGroup {
			id: batteryLifeState

			//% "Battery life state"
			text: qsTrId("settings_ess_batteryLife_state")
			dataItem.uid: Global.systemSettings.serviceUid + "/Settings/CGwacs/BatteryLife/State"
			allowed: defaultAllowed
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
			checked: maxChargePower.dataItem.value >= 0
			allowed: defaultAllowed
				&& essMode.value !== VenusOS.Ess_Hub4ModeState_Disabled
				&& !(maxChargeCurrentControl.isValid && maxChargeCurrentControl.value)

			onClicked: {
				if (maxChargePower.dataItem.value < 0) {
					maxChargePower.dataItem.setValue(1000)
				} else if (maxChargePower.dataItem.value >= 0) {
					maxChargePower.dataItem.setValue(-1)
				}
			}
		}

		ListSpinBox {
			id: maxChargePower

			//% "Maximum charge power"
			text: qsTrId("settings_ess_max_charge_power")
			allowed: defaultAllowed && maxChargePowerSwitch.visible && maxChargePowerSwitch.checked
			dataItem.uid: Global.systemSettings.serviceUid + "/Settings/CGwacs/MaxChargePower"
			suffix: Units.defaultUnitString(VenusOS.Units_Watt)
			from: 0
			to: 200000
			stepSize: 50
		}

		ListSwitch {
			id: maxInverterPowerSwitch

			//% "Limit inverter power"
			text: qsTrId("settings_ess_limit_inverter_power")
			checked: maxDischargePower.dataItem.value >= 0
			allowed: defaultAllowed
				&& essMode.value !== VenusOS.Ess_Hub4ModeState_Disabled
				&& batteryLifeState.dataItem.value !== VenusOS.Ess_BatteryLifeState_KeepCharged

			onClicked: {
				if (maxDischargePower.dataItem.value < 0) {
					maxDischargePower.dataItem.setValue(1000)
				} else if (maxDischargePower.dataItem.value >= 0) {
					maxDischargePower.dataItem.setValue(-1)
				}
			}
		}

		ListSpinBox {
			id: maxDischargePower

			//% "Maximum inverter power"
			text: qsTrId("settings_ess_max_inverter_power")
			allowed: defaultAllowed && maxInverterPowerSwitch.visible && maxInverterPowerSwitch.checked
			dataItem.uid: Global.systemSettings.serviceUid + "/Settings/CGwacs/MaxDischargePower"
			suffix: Units.defaultUnitString(VenusOS.Units_Watt)
			from: 0
			to: 300000
			stepSize: 50
		}

		ListSpinBox {
			//% "Grid setpoint"
			text: qsTrId("settings_ess_grid_setpoint")
			allowed: defaultAllowed && essMode.value !== VenusOS.Ess_Hub4ModeState_Disabled
			dataItem.uid: Global.systemSettings.serviceUid + "/Settings/CGwacs/AcPowerSetPoint"
			suffix: Units.defaultUnitString(VenusOS.Units_Watt)
			stepSize: 10
		}

		ListNavigation {
			//% "Grid feed-in"
			text: qsTrId("settings_ess_grid_feed_in")
			allowed: defaultAllowed && essMode.value !== VenusOS.Ess_Hub4ModeState_Disabled

			onClicked: {
				Global.pageManager.pushPage("/pages/settings/PageSettingsHub4Feedin.qml",
					{ title: text, hub4Mode: Qt.binding(function() { return essMode.value }) })
			}
		}

		ListNavigation {
			//% "Peak shaving"
			text: qsTrId("settings_ess_peak_shaving")
			allowed: defaultAllowed && essMode.value !== VenusOS.Ess_Hub4ModeState_Disabled
			onClicked: {
				Global.pageManager.pushPage("/pages/settings/PageSettingsHub4Peakshaving.qml", { title: text })
			}
		}

		ListNavigation {
			//% "Scheduled charge levels"
			text: qsTrId("settings_ess_scheduled_charge_levels")
			secondaryText: scheduleSoc.isValid
					  //% "Active (%1)"
					? qsTrId("settings_ess_active").arg(scheduleSoc.text)
					  //% "Inactive"
					: qsTrId("settings_ess_inactive")
			allowed: defaultAllowed
				&& essMode.value !== VenusOS.Ess_Hub4ModeState_Disabled
				&& batteryLifeState.dataItem.value !== VenusOS.Ess_BatteryLifeState_KeepCharged

			onClicked: {
				Global.pageManager.pushPage(scheduledChargeComponent, { title: text })
			}

			VeQuickItem {
				id: scheduleSoc
				uid: Global.system.serviceUid + "/Control/ScheduledSoc"
			}

			VeQuickItem {
				id: hasAcOutSystemItem
				uid: Global.systemSettings.serviceUid + "/Settings/SystemSetup/HasAcOutSystem"
			}

			Component {
				id: scheduledChargeComponent

				Page {
					GradientListView {
						model: 5
						delegate: ListChargeSchedule {
							scheduleNumber: modelData
						}
					}
				}
			}
		}

		ListNavigation {
			//% "Dynamic ESS"
			text: qsTrId("settings_ess_dynamic")
			allowed: (dEssModeItem.value > 0 || Global.systemSettings.canAccess(VenusOS.User_AccessType_Service))
					&& essMode.value !== VenusOS.Ess_Hub4ModeState_Disabled
					&& batteryLifeState.dataItem.value !== VenusOS.Ess_BatteryLifeState_KeepCharged
			onClicked: {
				Global.pageManager.pushPage("/pages/settings/PageSettingsDynamicEss.qml", { title: text })
			}

			VeQuickItem {
				id: dEssModeItem
				uid: Global.systemSettings.serviceUid + "/Settings/DynamicEss/Mode"
			}
		}

		ListNavigation {
			text: CommonWords.debug
			allowed: defaultAllowed
				&& essMode.value !== VenusOS.Ess_Hub4ModeState_Disabled
				&& Global.systemSettings.canAccess(VenusOS.User_AccessType_Service)

			onClicked: {
				Global.pageManager.pushPage("/pages/settings/PageHub4Debug.qml")
			}
		}
	}

	GradientListView {
		header: root._valid ? null : (Global.inverterChargers.acSystemDevices.count > 0 ? hasAcSystem : noEssHeader)
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

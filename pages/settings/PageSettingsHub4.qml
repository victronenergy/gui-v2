/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

ListPage {
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
			//% "Mode"
			text: qsTrId("settings_ess_mode")
			optionModel: Global.ess.stateModel
			listPage: root
			listIndex: ObjectModel.index
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
			dataSource: "com.victronenergy.settings/Settings/CGwacs/RunWithoutGridMeter"
			visible: defaultVisible && essMode.value !== VenusOS.Ess_Hub4ModeState_Disabled
			optionModel: [
				//% "External meter"
				{ display: qsTrId("settings_ess_external_meter"), value: 0 },
				//% "Inverter/Charger"
				{ display: qsTrId("settings_ess_inverter_charger"), value: 1 },
			]
			listPage: root
			listIndex: ObjectModel.index
		}

		ListSwitch {
			//% "Inverter AC output in use"
			text: qsTrId("settings_ess_inverter_ac_output_in_use")
			dataSource: "com.victronenergy.settings/Settings/SystemSetup/HasAcOutSystem"
			visible: defaultVisible && withoutGridMeter.currentIndex === 0
		}

		ListRadioButtonGroup {
			//% "Multiphase regulation"
			text: qsTrId("settings_ess_multiphase_regulation")
			dataSource: essMode.source
			visible: defaultVisible
				 && essMode.value !== VenusOS.Ess_Hub4ModeState_Disabled
				 && batteryLifeState.dataValue !== VenusOS.Ess_BatteryLifeState_KeepCharged
			defaultSecondaryText: ""
			listPage: root
			listIndex: ObjectModel.index
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

			property var _minSocDialog

			//% "Minimum SOC (unless grid fails)"
			text: qsTrId("settings_ess_min_soc")
			button.text: Global.ess.minimumStateOfCharge + "%"
			visible: defaultVisible
				&& essMode.value !== VenusOS.Ess_Hub4ModeState_Disabled
				&& batteryLifeState.dataValue !== VenusOS.Ess_BatteryLifeState_KeepCharged
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

		ListTextItem {
			//% "Active SOC limit"
			text: qsTrId("settings_ess_active_soc_limit")
			visible: defaultVisible
				&& essMode.value !== VenusOS.Ess_Hub4ModeState_Disabled
				&& Global.ess.isBatteryLifeActive(batteryLifeState.dataValue)
			secondaryText: Math.max(Global.ess.minimumStateOfCharge.value || 0, socLimit.value || 0) + "%"
		}

		ListRadioButtonGroup {
			id: batteryLifeState

			//% "BatteryLife state"
			text: qsTrId("settings_ess_batteryLife_state")
			dataSource: "com.victronenergy.settings/Settings/CGwacs/BatteryLife/State"
			visible: defaultVisible
				&& essMode.value !== VenusOS.Ess_Hub4ModeState_Disabled
				&& Global.ess.isBatteryLifeActive(dataValue)
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
			listPage: root
			listIndex: ObjectModel.index
		}

		ListSwitch {
			id: maxChargePowerSwitch

			//% "Limit charge power"
			text: qsTrId("settings_ess_limit_charge_power")
			checked: maxChargePower.value >= 0
			visible: defaultVisible
				&& essMode.value !== VenusOS.Ess_Hub4ModeState_Disabled
				&& !maxChargeCurrentControl.valid

			onCheckedChanged: {
				if (checked && maxChargePower.value < 0) {
					maxChargePower.setDataValue(1000)
				} else if (!checked && maxChargePower.value >= 0) {
					maxChargePower.setDataValue(-1)
				}
			}
		}

		ListSpinBox {
			id: maxChargePower

			//% "Maximum charge power"
			text: qsTrId("settings_ess_max_charge_power")
			visible: defaultVisible && maxChargePowerSwitch.visible && maxChargePowerSwitch.checked
			dataSource: "com.victronenergy.settings/Settings/CGwacs/MaxChargePower"
			suffix: "W"
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
				&& batteryLifeState.dataValue !== VenusOS.Ess_BatteryLifeState_KeepCharged

			onCheckedChanged: {
				if (checked && maxDischargePower.value < 0) {
					maxDischargePower.setDataValue(1000)
				} else if (!checked && maxDischargePower.value >= 0) {
					maxDischargePower.setDataValue(-1)
				}
			}
		}

		ListSpinBox {
			id: maxDischargePower

			//% "Maximum inverter power"
			text: qsTrId("settings_ess_max_inverter_power")
			visible: defaultVisible && maxInverterPowerSwitch.visible && maxInverterPowerSwitch.checked
			dataSource: "com.victronenergy.settings/Settings/CGwacs/MaxDischargePower"
			suffix: "W"
			to: 300000
			stepSize: 50
		}

		ListSpinBox {
			//% "Grid setpoint"
			text: qsTrId("settings_ess_grid_setpoint")
			visible: defaultVisible
				&& essMode.value !== VenusOS.Ess_Hub4ModeState_Disabled
				&& batteryLifeState.dataValue !== VenusOS.Ess_BatteryLifeState_KeepCharged
			dataSource: "com.victronenergy.settings/Settings/CGwacs/AcPowerSetPoint"
			suffix: "W"
			stepSize: 10
		}

		ListNavigationItem {
			//% "Grid feed-in"
			text: qsTrId("settings_ess_grid_feed_in")
			visible: defaultVisible && essMode.value !== VenusOS.Ess_Hub4ModeState_Disabled

			listPage: root
			listIndex: ObjectModel.index
			onClicked: {
				listPage.navigateTo("/pages/settings/PageSettingsHub4Feedin.qml",
					{ title: text, hub4Mode: Qt.binding(function() { return essMode.value }) },
					listIndex)
			}
		}

		ListNavigationItem {
			//% "Scheduled charging"
			text: qsTrId("settings_ess_scheduled_charging")
			visible: defaultVisible
				&& essMode.value !== VenusOS.Ess_Hub4ModeState_Disabled
				&& batteryLifeState.dataValue !== VenusOS.Ess_BatteryLifeState_KeepCharged

			listPage: root
			listIndex: ObjectModel.index
			onClicked: {
				listPage.navigateTo(scheduledChargeComponent, { title: text }, listIndex)
			}

			Component {
				id: scheduledChargeComponent

				ListPage {
					id: subListPage
					listView: GradientListView {
						model: 5
						delegate: CGwacsBatteryScheduleNavigationItem {
							listPage: subListPage
							listIndex: model.index
							scheduleNumber: modelData
						}
					}
				}
			}
		}

		ListNavigationItem {
			//% "Debug"
			text: qsTrId("settings_ess_debug")
			visible: defaultVisible
				&& essMode.value !== VenusOS.Ess_Hub4ModeState_Disabled
				&& Global.systemSettings.canAccess(VenusOS.User_AccessType_Service)

			listPage: root
			listIndex: ObjectModel.index
			onClicked: {
				listPage.navigateTo("/pages/settings/PageHub4Debug.qml", {}, listIndex)
			}
		}
	}

	listView: GradientListView {
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

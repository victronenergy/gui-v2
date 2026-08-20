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

	DelegateComponentModel {
		id: essSettings

		DelegateComponent {
			ListRadioButtonGroup {
				text: CommonWords.mode
				optionModel: Global.systemSettings.ess.stateModel
				currentIndex: {
					for (let i = 0; i < optionModel.length; ++i) {
						if (optionModel[i].value === Global.systemSettings.ess.state) {
							return i
						}
					}
					return -1
				}
				onOptionClicked: function(index) {
					Global.systemSettings.ess.setState(optionModel[index].value)
				}
			}
		}

		DelegateComponent {
			id: withoutGridMeterDC
			dataItem: VeQuickItem { uid: Global.systemSettings.serviceUid + "/Settings/CGwacs/RunWithoutGridMeter" }
			property int currentIndex: dataItem.valid ? dataItem.value : -1
			preferredVisible: essMode.value !== VenusOS.Ess_Hub4ModeState_Disabled
			ListRadioButtonGroup {
				id: withoutGridMeter

				//% "Grid metering"
				text: qsTrId("settings_ess_grid_metering")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/CGwacs/RunWithoutGridMeter"
				optionModel: [
					//% "External meter"
					{ display: qsTrId("settings_ess_external_meter"), value: 0 },
					//% "Inverter/Charger"
					{ display: qsTrId("settings_ess_inverter_charger"), value: 1 },
				]
			}
		}

		DelegateComponent {
			preferredVisible: withoutGridMeterDC.currentIndex === 0
					&& essMode.value !== VenusOS.Ess_Hub4ModeState_Disabled
			ListRadioButtonGroup {
				//% "Grid meter required"
				text: qsTrId("settings_ess_grid_meter_required")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/CGwacs/GridMeterRequired"
				optionModel: [
					{
						display: CommonWords.yes,
						value: 1,
						//% "A grid meter must be present for ESS operation. If not available, the system will switch to pass-through."
						caption: qsTrId("settings_ess_grid_meter_required_caption")
					},
					{
						display: CommonWords.no,
						value: 0,
						//% "The system will use a grid meter when present, but fall back to internal measurements if the connection to the grid meter is lost."
						caption: qsTrId("settings_ess_grid_meter_optional_caption")
					},
				]
			}
		}

		DelegateComponent {
			dataItem: VeQuickItem { uid: Global.systemSettings.serviceUid + "/Settings/CGwacs/BatteryUse" }
			preferredVisible: withoutGridMeterDC.currentIndex === 0 && (hasAcOutSystemItem.value === 1 || dataItem.value === 1)
			ListRadioButtonGroup {
				//% "Self-consumption from battery"
				text: qsTrId("settings_ess_self_consumption_battery")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/CGwacs/BatteryUse"
				optionModel: [
					//% "All system loads"
					{ display: qsTrId("settings_ess_all_system_loads"), value: 0 },
					//% "Only critical loads"
					{ display: qsTrId("settings_ess_only_critical_loads"), value: 1 },
				]
			}
		}

		DelegateComponent {
			preferredVisible: essMode.value !== VenusOS.Ess_Hub4ModeState_Disabled
				 && batteryLifeStateItem.value !== VenusOS.Ess_BatteryLifeState_KeepCharged
			ListRadioButtonGroup {
				//% "Multiphase regulation"
				text: qsTrId("settings_ess_multiphase_regulation")
				dataItem.uid: essMode.uid
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
		}

		DelegateComponent {
			preferredVisible: essMode.value !== VenusOS.Ess_Hub4ModeState_Disabled
				&& batteryLifeStateItem.value !== VenusOS.Ess_BatteryLifeState_KeepCharged
			ListButton {
				id: minSocLimit

				//% "Minimum SOC (unless grid fails)"
				text: qsTrId("settings_ess_min_soc")
				secondaryText: Global.systemSettings.ess.minimumStateOfCharge + "%"
				onClicked: Global.dialogLayer.open(minSocDialogComponent)

				Component {
					id: minSocDialogComponent

					ESSMinimumSOCDialog {
						minimumStateOfCharge: Global.systemSettings.ess.minimumStateOfCharge
						onAccepted: Global.systemSettings.ess.setMinimumStateOfCharge(minimumStateOfCharge)
					}
				}
			}
		}

		DelegateComponent {
			preferredVisible: essMode.value !== VenusOS.Ess_Hub4ModeState_Disabled
				&& Global.systemSettings.ess.isBatteryLifeActive(batteryLifeStateItem.value)
			ListQuantity {
				//% "Active SOC limit"
				text: qsTrId("settings_ess_active_soc_limit")
				value: Math.max(Global.systemSettings.ess.minimumStateOfCharge || 0, socLimit.value || 0)
				unit: VenusOS.Units_Percentage
			}
		}

		DelegateComponent {
			preferredVisible: essMode.value !== VenusOS.Ess_Hub4ModeState_Disabled
				&& Global.systemSettings.ess.isBatteryLifeActive(batteryLifeStateItem.value)
			ListRadioButtonGroup {
				id: batteryLifeState

				//% "BatteryLife state"
				text: qsTrId("settings_ess_batteryLife_state")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/CGwacs/BatteryLife/State"
				interactive: false
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
		}

		DelegateComponent {
			id: maxChargePowerSwitchDC
			dataItem: VeQuickItem { uid: Global.systemSettings.serviceUid + "/Settings/CGwacs/MaxChargePower" }
			property bool checked: dataItem.value >= 0
			preferredVisible: essMode.value !== VenusOS.Ess_Hub4ModeState_Disabled
				&& !(maxChargeCurrentControl.valid && maxChargeCurrentControl.value)
			ListSwitch {
				id: maxChargePowerSwitch

				//% "Limit charge power"
				text: qsTrId("settings_ess_limit_charge_power")
				checked: maxChargePowerSwitchDC.dataItem.value >= 0

				onClicked: {
					if (maxChargePowerSwitchDC.dataItem.value < 0) {
						maxChargePowerSwitchDC.dataItem.setValue(1000)
					} else if (maxChargePowerSwitchDC.dataItem.value >= 0) {
						maxChargePowerSwitchDC.dataItem.setValue(-1)
					}
				}
			}
		}

		DelegateComponent {
			preferredVisible: maxChargePowerSwitchDC.preferredVisible && maxChargePowerSwitchDC.checked
			ListSpinBox {
				id: maxChargePower

				//% "Maximum charge power"
				text: qsTrId("settings_ess_max_charge_power")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/CGwacs/MaxChargePower"
				suffix: Units.defaultUnitString(VenusOS.Units_Watt)
				from: 0
				to: 200000
				stepSize: 50
			}
		}

		DelegateComponent {
			id: maxInverterPowerSwitchDC
			dataItem: VeQuickItem { uid: Global.systemSettings.serviceUid + "/Settings/CGwacs/MaxDischargePower" }
			property bool checked: dataItem.value >= 0
			preferredVisible: essMode.value !== VenusOS.Ess_Hub4ModeState_Disabled
				&& batteryLifeStateItem.value !== VenusOS.Ess_BatteryLifeState_KeepCharged
			ListSwitch {
				id: maxInverterPowerSwitch

				//% "Limit inverter power"
				text: qsTrId("settings_ess_limit_inverter_power")
				checked: maxInverterPowerSwitchDC.dataItem.value >= 0

				onClicked: {
					if (maxInverterPowerSwitchDC.dataItem.value < 0) {
						maxInverterPowerSwitchDC.dataItem.setValue(1000)
					} else if (maxInverterPowerSwitchDC.dataItem.value >= 0) {
						maxInverterPowerSwitchDC.dataItem.setValue(-1)
					}
				}
			}
		}

		DelegateComponent {
			preferredVisible: maxInverterPowerSwitchDC.preferredVisible && maxInverterPowerSwitchDC.checked
			ListSpinBox {
				id: maxDischargePower

				//% "Maximum inverter power"
				text: qsTrId("settings_ess_max_inverter_power")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/CGwacs/MaxDischargePower"
				suffix: Units.defaultUnitString(VenusOS.Units_Watt)
				from: 0
				to: 300000
				stepSize: 50
			}
		}

		DelegateComponent {
			preferredVisible: essMode.value !== VenusOS.Ess_Hub4ModeState_Disabled
			ListSpinBox {
				//% "Grid setpoint"
				text: qsTrId("settings_ess_grid_setpoint")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/CGwacs/AcPowerSetPoint"
				suffix: Units.defaultUnitString(VenusOS.Units_Watt)
				stepSize: 10
			}
		}

		DelegateComponent {
			preferredVisible: essMode.value !== VenusOS.Ess_Hub4ModeState_Disabled
			ListNavigation {
				//% "Grid feed-in"
				text: qsTrId("settings_ess_grid_feed_in")

				onClicked: {
					Global.pageManager.pushPage("/pages/settings/PageSettingsHub4Feedin.qml",
						{ title: text, hub4Mode: Qt.binding(function() { return essMode.value }) })
				}
			}
		}

		DelegateComponent {
			preferredVisible: essMode.value !== VenusOS.Ess_Hub4ModeState_Disabled
			ListNavigation {
				//% "Peak shaving"
				text: qsTrId("settings_ess_peak_shaving")
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/PageSettingsHub4Peakshaving.qml", { title: text })
				}
			}
		}

		DelegateComponent {
			preferredVisible: essMode.value !== VenusOS.Ess_Hub4ModeState_Disabled
				&& batteryLifeStateItem.value !== VenusOS.Ess_BatteryLifeState_KeepCharged
			ListNavigation {
				//% "Scheduled charge levels"
				text: qsTrId("settings_ess_scheduled_charge_levels")
				secondaryText: scheduleSoc.valid
						  //% "Active (%1)"
						? qsTrId("settings_ess_active").arg(scheduleSoc.text)
						  //% "Inactive"
						: qsTrId("settings_ess_inactive")

				onClicked: {
					Global.pageManager.pushPage(scheduledChargeComponent, { title: text })
				}

				VeQuickItem {
					id: scheduleSoc
					uid: Global.system.serviceUid + "/Control/ScheduledSoc"
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
		}

		DelegateComponent {
			id: dEssModeItemDC
			dataItem: VeQuickItem { uid: Global.systemSettings.serviceUid + "/Settings/DynamicEss/Mode" }
			preferredVisible: (dEssModeItemDC.dataItem.value > 0 || Global.systemSettings.canAccess(VenusOS.User_AccessType_Service))
					&& essMode.value !== VenusOS.Ess_Hub4ModeState_Disabled
					&& batteryLifeStateItem.value !== VenusOS.Ess_BatteryLifeState_KeepCharged
			ListNavigation {
				//% "Dynamic ESS"
				text: qsTrId("settings_ess_dynamic")
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/PageSettingsDynamicEss.qml", { title: text })
				}
			}
		}

		DelegateComponent {
			preferredVisible: essMode.value !== VenusOS.Ess_Hub4ModeState_Disabled
				&& Global.systemSettings.canAccess(VenusOS.User_AccessType_Service)
			ListNavigation {
				text: CommonWords.debug

				onClicked: {
					Global.pageManager.pushPage("/pages/settings/PageHub4Debug.qml")
				}
			}
		}

		DelegateComponent {
			preferredVisible: maxChargePowerPercentageDC.preferredVisible || maxDischargePowerPercentageDC.preferredVisible
			SettingsListHeader {
				//% "Deprecated settings"
				text: qsTrId("settings_ess_deprecated")
			}
		}

		DelegateComponent {
			id: maxChargePowerPercentageDC
			dataItem: VeQuickItem { uid: Global.systemSettings.serviceUid + "/Settings/CGwacs/MaxChargePercentage" }
			preferredVisible: dataItem.value < 100.0
			ListSpinBox {
				id: maxChargePowerPercentage
				//% "Battery charge limit (% of CCL)"
				text: qsTrId("settings_ess_max_charge_percentage")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/CGwacs/MaxChargePercentage"
				suffix: Units.defaultUnitString(VenusOS.Units_Percentage)
				from: 0
				to: 100
			}
		}

		DelegateComponent {
			id: maxDischargePowerPercentageDC
			dataItem: VeQuickItem { uid: Global.systemSettings.serviceUid + "/Settings/CGwacs/MaxDischargePercentage" }
			preferredVisible: dataItem.value < 100.0
			ListSpinBox {
				id: maxDischargePowerPercentage
				//% "Battery discharge limit (% of DCL)"
				text: qsTrId("settings_ess_max_discharge_percentage")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/CGwacs/MaxDischargePercentage"
				suffix: Units.defaultUnitString(VenusOS.Units_Percentage)
				from: 0
				to: 100
			}
		}
	}

	FilteredDeviceModel {
		id: acSystemDevices
		serviceTypes: ["acsystem"]
	}

	GradientListView {
		header: root._valid ? null : (acSystemDevices.count > 0 ? hasAcSystem : noEssHeader)
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
		id: hasAcOutSystemItem
		uid: Global.systemSettings.serviceUid + "/Settings/SystemSetup/HasAcOutSystem"
	}
	VeQuickItem {
		id: maxChargeCurrentControl
		uid: Global.system.serviceUid + "/Control/MaxChargeCurrent"
	}
	VeQuickItem {
		id: batteryLifeStateItem
		uid: Global.systemSettings.serviceUid + "/Settings/CGwacs/BatteryLife/State"
	}
}

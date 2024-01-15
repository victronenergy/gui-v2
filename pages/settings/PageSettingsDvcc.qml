/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil
import QtQuick.Controls as C

Page {
	id: root

	GradientListView {
		id: dvccSettings

		model: ObjectModel {
			ListLabel {
				//% "<b>CAUTION:</b> Read the manual before adjusting."
				text: qsTrId("settings_dvcc_instructions")
				visible: commonSettings.userHasWriteAccess
			}

			DvccCommonSettings {
				id: commonSettings

				width: parent ? parent.width : 0
			}

			ListNavigationItem {
				//% "Charge Current limits"
				text: qsTrId("settings_dvcc_charge_current_limits")
				showAccessLevel: VenusOS.User_AccessType_Service
				onClicked: Global.pageManager.pushPage("/pages/settings/PageChargeCurrentLimits.qml", { title: text })
			}

			ListSwitch {
				id: maxChargeVoltageSwitch

				//% "Limit managed battery charge voltage"
				text: qsTrId("settings_dvcc_limit_managed_battery_charge_voltage")
				updateOnClick: false
				checked: maxChargeVoltage.dataItem.isValid && maxChargeVoltage.dataItem.value > 0
				visible: defaultVisible && commonSettings.dvccActive
				onClicked: {
					maxChargeVoltage.dataItem.setValue(maxChargeVoltage.dataItem.value === 0.0 ? 55.0 : 0.0)
				}
			}

			ListSpinBox {
				id: maxChargeVoltage

				//% "Maximum charge voltage"
				text: qsTrId("settings_dvcc_max_charge_voltage")
				visible: defaultVisible && maxChargeVoltageSwitch.visible && maxChargeVoltageSwitch.checked
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/SystemSetup/MaxChargeVoltage"
				suffix: "V"
				decimals: 1
			}

			ListDvccSwitch {
				//% "SVS - Shared voltage sense"
				text: qsTrId("settings_dvcc_shared_voltage_sense")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/SystemSetup/SharedVoltageSense"
				visible: defaultVisible && commonSettings.dvccActive
			}

			ListDvccSwitch {
				id: sharedTempSense

				//% "STS - Shared temperature sense"
				text: qsTrId("settings_dvcc_shared_temp_sense")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/SystemSetup/SharedTemperatureSense"
				visible: defaultVisible && commonSettings.dvccActive
			}

			ListRadioButtonGroup {
				id: temperatureServiceRadioButtons

				text: CommonWords.temperature_sensor
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/SystemSetup/TemperatureService"
				//% "Unavailable sensor, set another"
				defaultSecondaryText: qsTrId("settings_system_unavailable_sensor")
				visible: defaultVisible && commonSettings.dvccActive && sharedTempSense.checked

				VeQuickItem {
					uid: Global.system.serviceUid + "/AvailableTemperatureServices"
					onValueChanged: {
						if (value === undefined) {
							return
						}
						const modelArray = Utils.jsonSettingsToModel(value)
						if (modelArray) {
							temperatureServiceRadioButtons.optionModel = modelArray
						} else {
							console.warn("Unable to parse data from", uid)
						}
					}
				}
			}

			ListTextItem {
				//% "Used sensor"
				text: qsTrId("settings_dvcc_used_sensor")
				dataItem.uid: Global.system.serviceUid + "/AutoSelectedTemperatureService"
				visible: defaultVisible
					&& sharedTempSense.checked
					&& commonSettings.dvccActive
					&& temperatureServiceRadioButtons.secondaryText === "default"
			}

			ListSwitch {
				id: sharedCurrentSense

				//% "SCS - Shared current sense"
				text: qsTrId("settings_dvcc_shared_current_sense")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/SystemSetup/BatteryCurrentSense"
				visible: defaultVisible && commonSettings.dvccActive
			}

			ListRadioButtonGroup {
				//% "SCS status"
				text: qsTrId("settings_dvcc_scs_status")
				dataItem.uid: Global.system.serviceUid + "/Control/BatteryCurrentSense"
				visible: defaultVisible && commonSettings.dvccActive && sharedCurrentSense.checked
				enabled: false

				optionModel: [
					{ display: CommonWords.disabled, value: 0 },
					//% "Disabled (external control)"
					{ display: qsTrId("settings_dvcc_scs_disabled_external_control"), value: 1 },
					//% "Disabled (no chargers)"
					{ display: qsTrId("settings_dvcc_scs_disabled_no_chargers"), value: 2 },
					//% "Disabled (no battery monitor)"
					{ display: qsTrId("settings_dvcc_scs_disabled_no_battery_monitor"), value: 3 },
					{ display: CommonWords.active_status, value: 4 },
				]
			}

			ListRadioButtonGroup {
				id: bmsOptions

				readonly property var defaultOptionModel: [
					//% "Automatic selection"
					{ display: qsTrId("settings_dvcc_auto_selection"), value: -1 },
					//% "No BMS control"
					{ display: qsTrId("settings_dvcc_no_bms_control"), value: -255 },
				]

				//% "Controlling BMS"
				text: qsTrId("settings_dvcc_controlling_bms")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/SystemSetup/BmsInstance"
				optionModel: defaultOptionModel

				//: Shown when BMS instance is invalid
				//% "Unavailable, set another"
				defaultSecondaryText: qsTrId("settings_dvcc_unavailable_bms")


				VeQuickItem {
					uid: Global.system.serviceUid + "/AvailableBmsServices"
					onValueChanged: {
						if (value === undefined) {
							return
						}
						let options = bmsOptions.optionModel.slice(0, bmsOptions.defaultOptionModel.length)
						const bmses = value
						for (let i = 0; i < bmses.length; i++) {
							options.push({
								"display": bmses[i].name,
								"value": bmses[i].instance
							})
						}
						bmsOptions.optionModel = options
					}
				}
			}

			ListTextItem {
				//% "Auto selected"
				text: qsTrId("settings_dvcc_auto_selected")
				visible: defaultVisible && bmsOptions.currentValue === -1
				secondaryText: bmsService.isValid
							   ? bmsProductName.value || bmsCustomName.value
								 //: Indicates no option is selected
								 //% "None"
							   : qsTrId("settings_dvcc_auto_selected_none")

				VeQuickItem {
					id: bmsService
					uid: Global.system.serviceUid + "/ActiveBmsService"
				}

				VeQuickItem {
					id: bmsProductName
					uid: bmsService.isValid ? bmsService.value + "/ProductName" : ""
				}

				VeQuickItem {
					id: bmsCustomName
					uid: bmsService.isValid ? bmsService.value + "/CustomName" : ""
				}
			}
		}
	}
}

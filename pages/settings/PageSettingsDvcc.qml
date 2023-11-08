/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import QtQuick.Controls as C
import "/components/Utils.js" as Utils

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
				checked: maxChargeVoltage.dataValid && maxChargeVoltage.dataValue > 0
				visible: defaultVisible && commonSettings.dvccActive
				onClicked: {
					maxChargeVoltage.setDataValue(maxChargeVoltage.dataValue === 0.0 ? 55.0 : 0.0)
				}
			}

			ListSpinBox {
				id: maxChargeVoltage

				//% "Maximum charge voltage"
				text: qsTrId("settings_dvcc_max_charge_voltage")
				visible: defaultVisible && maxChargeVoltageSwitch.visible && maxChargeVoltageSwitch.checked
				dataSource: "com.victronenergy.settings/Settings/SystemSetup/MaxChargeVoltage"
				suffix: "V"
				decimals: 1
			}

			ListDvccSwitch {
				//% "SVS - Shared voltage sense"
				text: qsTrId("settings_dvcc_shared_voltage_sense")
				dataSource: "com.victronenergy.settings/Settings/SystemSetup/SharedVoltageSense"
				visible: defaultVisible && commonSettings.dvccActive
			}

			ListDvccSwitch {
				id: sharedTempSense

				//% "STS - Shared temperature sense"
				text: qsTrId("settings_dvcc_shared_temp_sense")
				dataSource: "com.victronenergy.settings/Settings/SystemSetup/SharedTemperatureSense"
				visible: defaultVisible && commonSettings.dvccActive
			}

			ListRadioButtonGroup {
				id: temperatureServiceRadioButtons

				//% "Temperature sensor"
				text: qsTrId("settings_dvcc_temp_sensor")
				dataSource: "com.victronenergy.settings/Settings/SystemSetup/TemperatureService"
				//% "Unavailable sensor, set another"
				defaultSecondaryText: qsTrId("settings_system_unavailable_sensor")
				visible: defaultVisible && commonSettings.dvccActive && sharedTempSense.checked

				DataPoint {
					source: "com.victronenergy.system/AvailableTemperatureServices"
					onValueChanged: {
						if (value === undefined) {
							return
						}
						const modelArray = Utils.jsonSettingsToModel(value)
						if (modelArray) {
							temperatureServiceRadioButtons.optionModel = modelArray
						} else {
							console.warn("Unable to parse data from", source)
						}
					}
				}
			}

			ListTextItem {
				//% "Used sensor"
				text: qsTrId("settings_dvcc_used_sensor")
				dataSource: "com.victronenergy.system/AutoSelectedTemperatureService"
				visible: defaultVisible
					&& sharedTempSense.checked
					&& commonSettings.dvccActive
					&& temperatureServiceRadioButtons.secondaryText === "default"
			}

			ListSwitch {
				id: sharedCurrentSense

				//% "SCS - Shared current sense"
				text: qsTrId("settings_dvcc_shared_current_sense")
				dataSource: "com.victronenergy.settings/Settings/SystemSetup/BatteryCurrentSense"
				visible: defaultVisible && commonSettings.dvccActive
			}

			ListRadioButtonGroup {
				//% "SCS status"
				text: qsTrId("settings_dvcc_scs_status")
				dataSource: "com.victronenergy.system/Control/BatteryCurrentSense"
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
					//% "Active"
					{ display: qsTrId("settings_dvcc_scs_active"), value: 4 },
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
				dataSource: "com.victronenergy.settings/Settings/SystemSetup/BmsInstance"
				optionModel: defaultOptionModel

				//: Shown when BMS instance is invalid
				//% "Unavailable, set another"
				defaultSecondaryText: qsTrId("settings_dvcc_unavailable_bms")


				DataPoint {
					source: "com.victronenergy.system/AvailableBmsServices"
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
				secondaryText: bmsService.valid
							   ? bmsProductName.value || bmsCustomName.value
								 //: Indicates no option is selected
								 //% "None"
							   : qsTrId("settings_dvcc_auto_selected_none")

				DataPoint {
					id: bmsService
					source: "com.victronenergy.system/ActiveBmsService"
				}

				DataPoint {
					id: bmsProductName
					source: bmsService.valid ? bmsService.value + "/ProductName" : ""
				}

				DataPoint {
					id: bmsCustomName
					source: bmsService.valid ? bmsService.value + "/CustomName" : ""
				}
			}
		}
	}
}

/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import QtQuick.Controls as C
import "/components/Utils.js" as Utils

Page {
	id: root

	SettingsListView {
		id: dvccSettings

		model: ObjectModel {
			SettingsLabel {
				//% "<b>CAUTION:</b> Read the manual before adjusting."
				text: qsTrId("settings_dvcc_instructions")
				visible: commonSettings.userHasWriteAccess
			}

			DvccCommonSettings {
				id: commonSettings

				width: parent ? parent.width : 0
			}

			SettingsListNavigationItem {
				//% "Charge Current limits"
				text: qsTrId("settings_dvcc_charge_current_limits")
				showAccessLevel: VenusOS.User_AccessType_Service
				onClicked: Global.pageManager.pushPage("/pages/settings/PageChargeCurrentLimits.qml", { title: text })
			}

			SettingsListSwitch {
				id: maxChargeVoltageSwitch

				//% "Limit managed battery charge voltage"
				text: qsTrId("settings_dvcc_limit_managed_battery_charge_voltage")
				updateOnClick: false
				checked: maxChargeVoltage.dataPoint.valid && maxChargeVoltage.dataPoint.value > 0
				visible: defaultVisible && commonSettings.dvccActive
				onClicked: {
					maxChargeVoltage.dataPoint.setValue(maxChargeVoltage.dataPoint.value === 0.0 ? 55.0 : 0.0)
				}
			}

			SettingsListSpinBox {
				id: maxChargeVoltage

				//% "Maximum charge voltage"
				text: qsTrId("settings_dvcc_max_charge_voltage")
				visible: defaultVisible && maxChargeVoltageSwitch.visible && maxChargeVoltageSwitch.checked
				source: "com.victronenergy.settings/Settings/SystemSetup/MaxChargeVoltage"
				suffix: "V"
				decimals: 1
			}

			SettingsListDvccSwitch {
				//% "SVS - Shared voltage sense"
				text: qsTrId("settings_dvcc_shared_voltage_sense")
				source: "com.victronenergy.settings/Settings/SystemSetup/SharedVoltageSense"
				visible: defaultVisible && commonSettings.dvccActive
			}

			SettingsListDvccSwitch {
				id: sharedTempSense

				//% "STS - Shared temperature sense"
				text: qsTrId("settings_dvcc_shared_temp_sense")
				source: "com.victronenergy.settings/Settings/SystemSetup/SharedTemperatureSense"
				visible: defaultVisible && commonSettings.dvccActive
			}

			SettingsListRadioButtonGroup {
				id: temperatureServiceRadioButtons

				//% "Temperature sensor"
				text: qsTrId("settings_dvcc_temp_sensor")
				source: "com.victronenergy.settings/Settings/SystemSetup/TemperatureService"
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
							temperatureServiceRadioButtons.model = modelArray
						} else {
							console.warn("Unable to parse data from", source)
						}
					}
				}
			}

			SettingsListTextItem {
				//% "Used sensor"
				text: qsTrId("settings_dvcc_used_sensor")
				source: "com.victronenergy.system/AutoSelectedTemperatureService"
				visible: defaultVisible
					&& sharedTempSense.checked
					&& commonSettings.dvccActive
					&& temperatureServiceRadioButtons.secondaryText === "default"
			}

			SettingsListSwitch {
				id: sharedCurrentSense

				//% "SCS - Shared current sense"
				text: qsTrId("settings_dvcc_shared_current_sense")
				source: "com.victronenergy.settings/Settings/SystemSetup/BatteryCurrentSense"
				visible: defaultVisible && commonSettings.dvccActive
			}

			SettingsListRadioButtonGroup {
				//% "SCS status"
				text: qsTrId("settings_dvcc_scs_status")
				source: "com.victronenergy.system/Control/BatteryCurrentSense"
				visible: defaultVisible && commonSettings.dvccActive && sharedCurrentSense.checked
				enabled: false

				model: [
					{ display: Global.commonWords.disabled, value: 0 },
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
		}
	}
}

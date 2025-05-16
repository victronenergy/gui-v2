/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import QtQuick.Controls as C

Page {
	id: root

	GradientListView {
		id: dvccSettings

		model: VisibleItemModel {
			PrimaryListLabel {
				//% "<b>CAUTION:</b> Read the manual before adjusting."
				text: qsTrId("settings_dvcc_instructions")
				preferredVisible: commonSettings.userHasWriteAccess
			}

			DvccCommonSettings {
				id: commonSettings

				width: parent ? parent.width : 0
			}

			ListNavigation {
				//% "Charge current limits"
				text: qsTrId("settings_dvcc_charge_current_limits")
				showAccessLevel: VenusOS.User_AccessType_Service
				onClicked: Global.pageManager.pushPage("/pages/settings/PageChargeCurrentLimits.qml", { title: text })
			}

			ListSwitch {
				id: maxChargeVoltageSwitch

				//% "Limit managed battery charge voltage"
				text: qsTrId("settings_dvcc_limit_managed_battery_charge_voltage")
				checked: maxChargeVoltage.dataItem.valid && maxChargeVoltage.dataItem.value > 0
				preferredVisible: commonSettings.dvccActive
				onClicked: {
					maxChargeVoltage.dataItem.setValue(maxChargeVoltage.dataItem.value === 0.0 ? 55.0 : 0.0)
				}
			}

			ListSpinBox {
				id: maxChargeVoltage

				//% "Maximum charge voltage"
				text: qsTrId("settings_dvcc_max_charge_voltage")
				preferredVisible: maxChargeVoltageSwitch.visible && maxChargeVoltageSwitch.checked
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/SystemSetup/MaxChargeVoltage"
				suffix: "V"
				decimals: 1
				stepSize: 0.1
			}

			ListSwitchForced {
				//% "SVS - Shared voltage sense"
				text: qsTrId("settings_dvcc_shared_voltage_sense")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/SystemSetup/SharedVoltageSense"
				preferredVisible: commonSettings.dvccActive
			}

			ListSwitchForced {
				id: sharedTempSense

				//% "STS - Shared temperature sense"
				text: qsTrId("settings_dvcc_shared_temp_sense")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/SystemSetup/SharedTemperatureSense"
				preferredVisible: commonSettings.dvccActive
			}

			ListRadioButtonGroup {
				id: temperatureServiceRadioButtons

				text: CommonWords.temperature_sensor
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/SystemSetup/TemperatureService"
				//% "Unavailable sensor, set another"
				defaultSecondaryText: qsTrId("settings_system_unavailable_sensor")
				preferredVisible: commonSettings.dvccActive && sharedTempSense.checked

				VeQuickItem {
					uid: Global.system.serviceUid + "/AvailableTemperatureServices"
					onValueChanged: {
						if (value === undefined) {
							return
						}
						const modelArray = Utils.jsonSettingsToModel(value)
						let serviceUids = []
						for (let i = 0; i < modelArray.length; ++i) {
							const serviceId = modelArray[i].value
							if (serviceId.startsWith("com.victronenergy.")) {
								const firstIndexOfSlash = serviceId.indexOf('/')
								const secondIndexOfSlash = serviceId.indexOf('/', firstIndexOfSlash + 1)
								const deviceInstanceSubstring = serviceId.substring(firstIndexOfSlash + 1, secondIndexOfSlash)
								serviceUids.push({
									optionIndex: i,
									serviceUid: BackendConnection.serviceUidFromName(serviceId.substr(0, firstIndexOfSlash), parseInt(deviceInstanceSubstring))
								})
							}
						}
						temperatureServiceRadioButtons.optionModel = modelArray
						temperatureServiceInstantiator.model = serviceUids
					}
				}

				Instantiator {
					id: temperatureServiceInstantiator
					delegate: Device {
						serviceUid: modelData.serviceUid
						onNameChanged: temperatureServiceRadioButtons.optionModel[modelData.optionIndex].display = name
					}
				}
			}

			ListText {
				//% "Used sensor"
				text: qsTrId("settings_dvcc_used_sensor")
				dataItem.uid: Global.system.serviceUid + "/AutoSelectedTemperatureService"
				preferredVisible: sharedTempSense.checked
					&& commonSettings.dvccActive
					&& temperatureServiceRadioButtons.secondaryText === "default"
			}

			ListSwitch {
				id: sharedCurrentSense

				//% "SCS - Shared current sense"
				text: qsTrId("settings_dvcc_shared_current_sense")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/SystemSetup/BatteryCurrentSense"
				preferredVisible: commonSettings.dvccActive
			}

			ListRadioButtonGroup {
				//% "SCS status"
				text: qsTrId("settings_dvcc_scs_status")
				dataItem.uid: Global.system.serviceUid + "/Control/BatteryCurrentSense"
				preferredVisible: commonSettings.dvccActive && sharedCurrentSense.checked
				interactive: false

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
				preferredVisible: commonSettings.dvccActive
						 // Only show if there are valid services published on /AvailableBmsServices or a valid active BMS service selected
						 && (bmsOptions.optionModel.length > 2 || bmsService.valid)

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

			ListText {
				id: bmsName

				readonly property string serviceUid: BackendConnection.serviceUidFromName(bmsService.value || "", bmsInstance.value || 0)

				//% "Auto selected"
				text: qsTrId("settings_dvcc_auto_selected")
				preferredVisible: bmsOptions.preferredVisible && bmsOptions.currentValue === -1
				secondaryText: bmsService.valid
							   ? bmsCustomName.value || bmsProductName.value || ""
								 //: Indicates no option is selected
								 //% "None"
							   : qsTrId("settings_dvcc_auto_selected_none")

				VeQuickItem {
					id: bmsService
					uid: Global.system.serviceUid + "/ActiveBmsService"
				}

				VeQuickItem {
					id: bmsInstance
					uid: Global.system.serviceUid + "/ActiveBmsInstance"
				}

				VeQuickItem {
					id: bmsProductName
					uid: bmsName.serviceUid ? "%1/ProductName".arg(bmsName.serviceUid) : ""
				}

				VeQuickItem {
					id: bmsCustomName
					uid: bmsName.serviceUid ? "%1/CustomName".arg(bmsName.serviceUid) : ""
				}
			}

			ListSwitch {
				//% "Control MK3-USB connected inverter/charger system"
				text: qsTrId("settings_dvcc_control_mk3_usb_inverter_charger_system")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/SystemSetup/DvccControlAllMultis"
				preferredVisible: commonSettings.dvccActive &&
						 nrVebusDevices.valid && nrVebusDevices.value > 1
				//% "Enable this setting when having a secondary MultiPlus or Quattro system powered by the same battery bank as the main inverter/charger system. When this setting is enabled, this secondary system will use the CVL and DCL parameters of the selected BMS."
				caption: qsTrId("settings_dvcc_control_mk3_usb_inverter_charger_system_caption")
				VeQuickItem {
					id: nrVebusDevices
					uid: Global.system.serviceUid + "/Devices/NumberOfVebusDevices"
				}
			}
		}
	}
}

/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	VeQuickItem {
		id: activeBmsServiceItem
		uid: Global.system.serviceUid + "/ActiveBmsService"
	}

	// Note: kept at page scope (rather than inside the 'Controlling BMS' delegate) because
	// bmsOptionsDC.preferredVisible depends on the optionModel this handler builds; if it lived
	// inside the delegate it would never run once that delegate is hidden.
	VeQuickItem {
		id: availableBmsServicesItem
		uid: Global.system.serviceUid + "/AvailableBmsServices"
		onValueChanged: {
			if (value === undefined) {
				return
			}
			let options = bmsOptionsDC.defaultOptionModel.slice()
			const bmses = value
			for (let i = 0; i < bmses.length; i++) {
				options.push({
					"display": bmses[i].name,
					"value": bmses[i].instance
				})
			}
			bmsOptionsDC.optionModel = options
		}
	}

	GradientListView {
		id: dvccSettings

		model: DelegateComponentModel {
			DelegateComponent {
				preferredVisible: commonSettingsDC.userHasWriteAccess
				PrimaryListLabel {
					//% "<b>CAUTION:</b> Read the manual before adjusting."
					text: qsTrId("settings_dvcc_instructions")
				}
			}

			DelegateComponent {
				id: commonSettingsDC
				dataItem: VeQuickItem { uid: Global.systemSettings.serviceUid + "/Settings/Services/Bol" }
				property bool dvccActive: dataItem.value === 1 || dataItem.value === VenusOS.Switch_ForcedOn
				property bool userHasWriteAccess: Global.systemSettings.canAccess(VenusOS.User_AccessType_Installer)
				DvccCommonSettings {
					id: commonSettings

					width: parent ? parent.width : 0
				}
			}

			DelegateComponent {
				ListNavigation {
					//% "Charge current limits"
					text: qsTrId("settings_dvcc_charge_current_limits")
					showAccessLevel: VenusOS.User_AccessType_Service
					onClicked: Global.pageManager.pushPage("/pages/settings/PageChargeCurrentLimits.qml", { title: text })
				}
			}

			DelegateComponent {
				id: maxChargeVoltageSwitchDC
				dataItem: VeQuickItem { uid: Global.systemSettings.serviceUid + "/Settings/SystemSetup/MaxChargeVoltage" }
				property bool checked: dataItem.valid && dataItem.value > 0
				preferredVisible: commonSettingsDC.dvccActive
				ListSwitch {
					id: maxChargeVoltageSwitch

					//% "Limit managed battery charge voltage"
					text: qsTrId("settings_dvcc_limit_managed_battery_charge_voltage")
					checked: maxChargeVoltageSwitchDC.dataItem.valid && maxChargeVoltageSwitchDC.dataItem.value > 0
					onClicked: {
						maxChargeVoltageSwitchDC.dataItem.setValue(maxChargeVoltageSwitchDC.dataItem.value === 0.0 ? 55.0 : 0.0)
					}
				}
			}

			DelegateComponent {
				preferredVisible: maxChargeVoltageSwitchDC.preferredVisible && maxChargeVoltageSwitchDC.checked
				ListSpinBox {
					id: maxChargeVoltage

					//% "Maximum charge voltage"
					text: qsTrId("settings_dvcc_max_charge_voltage")
					dataItem.uid: Global.systemSettings.serviceUid + "/Settings/SystemSetup/MaxChargeVoltage"
					suffix: "V"
					decimals: 1
					stepSize: 0.1
				}
			}

			DelegateComponent {
				preferredVisible: commonSettingsDC.dvccActive
				ListSwitchForced {
					//% "SVS - Shared voltage sense"
					text: qsTrId("settings_dvcc_shared_voltage_sense")
					dataItem.uid: Global.systemSettings.serviceUid + "/Settings/SystemSetup/SharedVoltageSense"
				}
			}

			DelegateComponent {
				id: sharedTempSenseDC
				dataItem: VeQuickItem { uid: Global.systemSettings.serviceUid + "/Settings/SystemSetup/SharedTemperatureSense" }
				property bool checked: dataItem.value === 1 || dataItem.value === VenusOS.Switch_ForcedOn
				preferredVisible: commonSettingsDC.dvccActive
				ListSwitchForced {
					id: sharedTempSense

					//% "STS - Shared temperature sense"
					text: qsTrId("settings_dvcc_shared_temp_sense")
					dataItem.uid: Global.systemSettings.serviceUid + "/Settings/SystemSetup/SharedTemperatureSense"
				}
			}

			DelegateComponent {
				preferredVisible: commonSettingsDC.dvccActive && sharedTempSenseDC.checked
				ListRadioButtonGroup {
					id: temperatureServiceRadioButtons

					text: CommonWords.temperature_sensor
					dataItem.uid: Global.systemSettings.serviceUid + "/Settings/SystemSetup/TemperatureService"
					//% "Unavailable sensor, set another"
					defaultSecondaryText: qsTrId("settings_system_unavailable_sensor")

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
			}

			DelegateComponent {
				id: usedSensorDC
				dataItem: VeQuickItem { uid: Global.system.serviceUid + "/AutoSelectedTemperatureService" }
				property VeQuickItem temperatureServiceItem: VeQuickItem {
					uid: Global.systemSettings.serviceUid + "/Settings/SystemSetup/TemperatureService"
				}
				preferredVisible: sharedTempSenseDC.checked
					&& commonSettingsDC.dvccActive
					&& usedSensorDC.temperatureServiceItem.value === "default"
				ListText {
					//% "Used sensor"
					text: qsTrId("settings_dvcc_used_sensor")
					dataItem.uid: Global.system.serviceUid + "/AutoSelectedTemperatureService"
				}
			}

			DelegateComponent {
				id: sharedCurrentSenseDC
				dataItem: VeQuickItem { uid: Global.systemSettings.serviceUid + "/Settings/SystemSetup/BatteryCurrentSense" }
				property bool checked: dataItem.value === 1
				preferredVisible: commonSettingsDC.dvccActive
				ListSwitch {
					id: sharedCurrentSense

					//% "SCS - Shared current sense"
					text: qsTrId("settings_dvcc_shared_current_sense")
					dataItem.uid: Global.systemSettings.serviceUid + "/Settings/SystemSetup/BatteryCurrentSense"
				}
			}

			DelegateComponent {
				preferredVisible: commonSettingsDC.dvccActive && sharedCurrentSenseDC.checked
				ListRadioButtonGroup {
					//% "SCS status"
					text: qsTrId("settings_dvcc_scs_status")
					dataItem.uid: Global.system.serviceUid + "/Control/BatteryCurrentSense"
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
			}

			DelegateComponent {
				id: bmsOptionsDC
				dataItem: VeQuickItem { uid: Global.systemSettings.serviceUid + "/Settings/SystemSetup/BmsInstance" }
				readonly property var defaultOptionModel: [
					//% "Automatic selection"
					{ display: qsTrId("settings_dvcc_auto_selection"), value: -1 },
					//% "No BMS control"
					{ display: qsTrId("settings_dvcc_no_bms_control"), value: -255 },
				]
				property var optionModel: defaultOptionModel
				property var currentValue: dataItem.valid ? dataItem.value : undefined
				preferredVisible: commonSettingsDC.dvccActive
						 // Only show if there are valid services published on /AvailableBmsServices or a valid active BMS service selected
						 && (optionModel.length > defaultOptionModel.length || activeBmsServiceItem.valid)
				ListRadioButtonGroup {
					id: bmsOptions

					//% "Controlling BMS"
					text: qsTrId("settings_dvcc_controlling_bms")
					dataItem.uid: Global.systemSettings.serviceUid + "/Settings/SystemSetup/BmsInstance"
					optionModel: bmsOptionsDC.optionModel

					//: Shown when BMS instance is invalid
					//% "Unavailable, set another"
					defaultSecondaryText: qsTrId("settings_dvcc_unavailable_bms")
				}
			}

			DelegateComponent {
				preferredVisible: bmsOptionsDC.preferredVisible && bmsOptionsDC.currentValue === -1
				ListText {
					id: bmsName

					readonly property string serviceUid: BackendConnection.serviceUidFromName(bmsService.value || "", bmsInstance.value || 0)

					//% "Auto selected"
					text: qsTrId("settings_dvcc_auto_selected")
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
			}

			DelegateComponent {
				id: dvccControlAllMultisDC
				dataItem: VeQuickItem {
					uid: Global.systemSettings.serviceUid + "/Settings/SystemSetup/DvccControlAllMultis"
				}
				property VeQuickItem nrVebusDevicesItem: VeQuickItem {
					uid: Global.system.serviceUid + "/Devices/NumberOfVebusDevices"
				}
				preferredVisible: commonSettingsDC.dvccActive
					&& nrVebusDevicesItem.valid
					&& nrVebusDevicesItem.value > 1
				ListSwitch {
					//% "Control MK3-USB connected inverter/charger system"
					text: qsTrId("settings_dvcc_control_mk3_usb_inverter_charger_system")
					dataItem.uid: Global.systemSettings.serviceUid + "/Settings/SystemSetup/DvccControlAllMultis"
					//% "Enable this setting when having a secondary MultiPlus or Quattro system powered by the same battery bank as the main inverter/charger system. When this setting is enabled, this secondary system will use the CVL and DCL parameters of the selected BMS."
					caption: qsTrId("settings_dvcc_control_mk3_usb_inverter_charger_system_caption")
				}
			}
		}
	}
}

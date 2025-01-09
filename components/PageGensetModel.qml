/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ObjectModel {
	id: root

	property string bindPrefix
	property string settingsBindPrefix: Global.systemSettings.serviceUid + "/Settings/Generator1"
	property string startStopBindPrefix: startStop1Uid
	readonly property string serviceType: BackendConnection.serviceTypeFromUid(bindPrefix)

	// On D-Bus, the startstop1 generator is at com.victronenergy.generator.startstop1.
	// On MQTT, the startstop1 generator is the one with GensetService=com.victronenergy.genset.*
	// (or GensetService=com.victronenergy.dcgenset.* if this is a dcgenset)
	readonly property string startStop1Uid: BackendConnection.type === BackendConnection.MqttSource
			? generatorWithGensetService
			: BackendConnection.uidPrefix() + "/com.victronenergy.generator.startstop1"
	property string generatorWithGensetService

	property Instantiator generatorObjects: Instantiator {
		model: BackendConnection.type === BackendConnection.MqttSource ? Global.generators.model : null
		delegate: VeQuickItem {
			uid: model.device.serviceUid + "/GensetService"
			onValueChanged: {
				if ( (isValid && root.dcGenset && value.startsWith("com.victronenergy.dcgenset."))
						|| (isValid && !root.dcGenset && value.startsWith("com.victronenergy.genset.")) ) {
						root.generatorWithGensetService = model.device.serviceUid
				}
			}
		}
	}

	readonly property bool dcGenset: serviceType === "dcgenset"
	readonly property int nrOfPhases: phases.isValid ? phases.value
												   : dcGenset ? 0
															  : 3
	readonly property VeQuickItem phases: VeQuickItem {
		uid: root.bindPrefix + "/NrOfPhases"
	}

	readonly property VeQuickItem gensetEnabled: VeQuickItem {
		uid: root.startStopBindPrefix ? root.startStopBindPrefix + "/Enabled" : ""
	}

	PrimaryListLabel {
		allowed: root.gensetEnabled.value === 0
		//% "This genset controller requires a helper relay to be controlled but the helper relay is not configured. Please configure Relay 1 under Settings → Relay to \"Connected genset helper relay\"."
		text: qsTrId("genset_controller_requires_helper_relay")
	}

	ListSwitch {
		id: autostartSwitch
		//% "Auto start functionality"
		text: qsTrId("ac-in-genset_auto_start_functionality")
		allowed: root.gensetEnabled.value === 1
		dataItem.uid: root.startStopBindPrefix ? root.startStopBindPrefix + "/AutoStartEnabled" : ""
		updateDataOnClick: false

		onClicked: {
			if (!checked) {
				autostartSwitch.dataItem.setValue(true)
			} else {
				// check if they really want to disable
				Global.dialogLayer.open(confirmationDialogComponent)
			}
		}

		Component {
			id: confirmationDialogComponent

			GeneratorDisableAutoStartDialog {
				onAccepted: autostartSwitch.dataItem.setValue(false)
			}
		}
	}

	ListItem {
		text: CommonWords.manual_control
		allowed: root.gensetEnabled.value === 1
		content.children: [
			GeneratorManualControlButton {
				generatorUid: root.startStopBindPrefix
				gensetUid: root.bindPrefix
			}
		]
	}

	ListText {
		//% "Current run time"
		text: qsTrId("settings_page_genset_generator_run_time")
		secondaryText: dataItem.isValid ? Utils.secondsToString(dataItem.value, false) : "0"
		dataItem.uid: root.startStopBindPrefix ? root.startStopBindPrefix + "/Runtime" : ""
		allowed: generatorState.value >= 1 && generatorState.value <= 3 // Running, Warm-up, Cool-down
	}

	ListText {
		//% "Control status"
		text: qsTrId("ac-in-genset_auto_control_status")
		secondaryText: activeCondition.isAutoStarted && generatorState.value === VenusOS.Generators_State_Running
						   ? CommonWords.autostarted_dot_running_by.arg(Global.generators.runningByText(activeCondition.value))
						   : Global.generators.stateAndCondition(generatorState.value, activeCondition.value)

		VeQuickItem {
			id: activeCondition
			readonly property bool isAutoStarted: isValid && Global.generators.isAutoStarted(value)
			uid: root.startStopBindPrefix ? root.startStopBindPrefix + "/RunningByConditionCode" : ""
		}

		VeQuickItem {
			id: generatorState
			uid: root.startStopBindPrefix ? root.startStopBindPrefix + "/State" : ""
		}
	}

	ListGeneratorError {
		//% "Control error code"
		text: qsTrId("ac-in-genset_control_error_code")
		allowed: defaultAllowed && dataItem.isValid
		dataItem.uid: root.startStopBindPrefix ? root.startStopBindPrefix + "/Error" : ""
	}

	ListText {
		//% "Genset status"
		text: qsTrId("ac-in-genset_status")
		secondaryText: Global.acInputs.gensetStatusCodeToText(gensetStatus.value)

		VeQuickItem {
			id: gensetStatus
			uid: root.bindPrefix + "/StatusCode"
		}
	}

	ListNavigation {
		//% "Genset error codes"
		text: qsTrId("ac-in-genset_error")
		secondaryText: {
			let errorCodes = ""
			for (let i = 0; i < errorModel.count; ++i) {
				const errorCode = errorModel.get(i).errorCode
				if (errorCode) {
					errorCodes += (errorCodes.length ? " " : "") + errorCode
				}
			}
			return errorCodes.length ? errorCodes : CommonWords.none_errors
		}

		allowed: defaultAllowed && _dataItem.isValid
		enabled: secondaryText !== CommonWords.none_errors

		onClicked: Global.notificationLayer.popAndGoToNotifications()

		VeQuickItem {
			id: _dataItem

			uid: root.bindPrefix + "/Error/0/Id"
		}

		GensetErrorModel {
			id: errorModel

			uidPrefix: root.bindPrefix
		}
	}

	Column {
		width: parent ? parent.width : 0

		Repeater {
			id: phaseRepeater

			model: root.nrOfPhases
			delegate: ListQuantityGroup {
				text: phaseRepeater.count === 1
						//% "AC"
					  ? qsTrId("ac-in-genset_ac")
					  : CommonWords.ac_phase_x.arg(model.index + 1)

				textModel: [
					{ value: phaseVoltage.value, unit: VenusOS.Units_Volt_AC },
					{ value: phaseCurrent.value, unit: VenusOS.Units_Amp },
					{ value: phasePower.value, unit: VenusOS.Units_Watt },
				]

				VeQuickItem {
					id: phaseVoltage
					uid: root.bindPrefix + "/Ac/L" + (model.index + 1) + "/Voltage"
				}
				VeQuickItem {
					id: phaseCurrent
					uid: root.bindPrefix + "/Ac/L" + (model.index + 1) + "/Current"
				}
				VeQuickItem {
					id: phasePower
					uid: root.bindPrefix + "/Ac/L" + (model.index + 1) + "/Power"
				}
			}
		}
	}

	ListText {
		//% "Remote start mode"
		text: qsTrId("ac-in-genset_remote_start_mode")
		dataItem.uid: root.bindPrefix + "/RemoteStartModeEnabled"
		secondaryText: CommonWords.enabledOrDisabled(dataItem.value)
	}

	ListDcOutputQuantityGroup {
		bindPrefix: root.bindPrefix
		allowed: defaultAllowed && root.dcGenset
	}

	ListNavigation {
		//% "Engine"
		text: qsTrId("ac-in-genset_engine")
		onClicked: {
			Global.pageManager.pushPage(engineComponent, {"title": text})
		}

		Component {
			id: engineComponent

			Page {
				GradientListView {
					model: ObjectModel {
						ListQuantity {
							//% "Speed"
							text: qsTrId("ac-in-genset_speed")
							dataItem.uid: root.bindPrefix + "/Engine/Speed"
							unit: VenusOS.Units_RevolutionsPerMinute
						}

						ListQuantity {
							//% "Load"
							text: qsTrId("ac-in-genset_load")
							dataItem.uid: root.bindPrefix + "/Engine/Load"
							allowed: defaultAllowed && dataItem.isValid
							unit: VenusOS.Units_Percentage
						}

						ListQuantity {
							//% "Oil pressure"
							text: qsTrId("ac-in-genset_oil_pressure")
							dataItem.uid: root.bindPrefix + "/Engine/OilPressure"
							allowed: defaultAllowed && dataItem.isValid
							unit: VenusOS.Units_Kilopascal
						}

						ListTemperature {
							//% "Oil temperature"
							text: qsTrId("ac-in-genset_oil_temperature")
							allowed: defaultAllowed && dataItem.isValid
							dataItem.uid: root.bindPrefix + "/Engine/OilTemperature"
							precision: 0
						}

						ListTemperature {
							//% "Coolant temperature"
							text: qsTrId("ac-in-genset_coolant_temperature")
							allowed: defaultAllowed && dataItem.isValid
							dataItem.uid: root.bindPrefix + "/Engine/CoolantTemperature"
							precision: 0
						}

						ListTemperature {
							//% "Exhaust temperature"
							text: qsTrId("ac-in-genset_exhaust_temperature")
							allowed: defaultAllowed && dataItem.isValid
							dataItem.uid: root.bindPrefix + "/Engine/ExaustTemperature"
						}

						ListTemperature {
							//% "Winding temperature"
							text: qsTrId("ac-in-genset_winding_temperature")
							allowed: defaultAllowed && dataItem.isValid
							dataItem.uid: root.bindPrefix + "/Engine/WindingTemperature"
						}

						ListTemperature {
							//% "Heatsink temperature"
							text: qsTrId("genset_heatsink_temperature")
							dataItem.uid: root.bindPrefix + "/HeatsinkTemperature"
							allowed: defaultAllowed && dataItem.isValid
						}

						ListQuantity {
							//% "Starter battery voltage"
							text: qsTrId("ac-in-genset_starter_battery_voltage")
							dataItem.uid: root.bindPrefix + "/StarterVoltage"
							allowed: defaultAllowed && dataItem.isValid
							unit: VenusOS.Units_Volt_DC
						}

						ListText {
							//% "Number of starts"
							text: qsTrId("ac-in-genset_number_of_starts")
							dataItem.uid: root.bindPrefix + "/Engine/Starts"
							allowed: defaultAllowed && dataItem.isValid
						}
					}
				}
			}
		}
	}

	ListNavigation {
		//% "Run time and service"
		text: qsTrId("page_settings_generator_run_time_and_service")
		onClicked: Global.pageManager.pushPage("/pages/settings/PageGeneratorRuntimeService.qml",
											   {
												   title: text,
												   settingsBindPrefix: root.settingsBindPrefix,
												   startStopBindPrefix: root.startStopBindPrefix,
												   gensetBindPrefix: root.bindPrefix
											   })
	}

	ListNavigation {
		//% "DC genset settings"
		text: qsTrId("page_genset_model_dc_genset_settings")
		allowed: defaultAllowed && (chargeVoltage.isValid || chargeCurrent.isValid || bmsControlled.isValid)
		onClicked: Global.pageManager.pushPage(settingsComponent, {"title": text})

		VeQuickItem {
			id: chargeVoltage
			uid: root.bindPrefix + "/Settings/ChargeVoltage"
		}

		VeQuickItem {
			id: chargeCurrent
			uid: root.bindPrefix + "/Settings/ChargeCurrentLimit"
		}

		VeQuickItem {
			id: bmsControlled
			uid: root.bindPrefix + "/Settings/BmsPresent"
		}

		Component {
			id: settingsComponent

			Page {
				GradientListView {
					model: ObjectModel {
						ListSpinBox {
							//% "Charge voltage"
							text: qsTrId("genset_charge_voltage")
							dataItem.uid: root.bindPrefix + "/Settings/ChargeVoltage"
							decimals: 1
							stepSize: 0.1
							suffix: Units.defaultUnitString(VenusOS.Units_Volt_DC)
							allowed: defaultAllowed && dataItem.isValid
							enabled: bmsControlled.dataItem.value === 0
						}

						ListText {
							//% "The charge voltage is currently controlled by the BMS."
							text: qsTrId("genset_charge_voltage_controlled_by_bms")
							allowed: defaultAllowed && bmsControlled.dataItem.value === 1
						}

						ListSpinBox {
							//% "Charge current limit"
							text: qsTrId("genset_charge_current_limit")
							dataItem.uid: root.bindPrefix + "/Settings/ChargeCurrentLimit"
							suffix: Units.defaultUnitString(VenusOS.Units_Amp)
							allowed: defaultAllowed && dataItem.isValid
						}

						ListText {
							id: bmsControlled

							//% "BMS Controlled"
							text: qsTrId("genset_bms_controlled")
							secondaryText: CommonWords.yesOrNo(dataItem.value)
							dataItem.uid: root.bindPrefix + "/Settings/BmsPresent"
							allowed: defaultAllowed && dataItem.isValid
							bottomContentChildren: PrimaryListLabel {
								//% "BMS control is enabled automatically when a BMS is present. Reset it if the system configuration changed or if there is no BMS present."
								text: qsTrId("genset_bms_control_enabled_automatically")
								allowed: bmsControlled.dataItem.value === 1
							}
						}

						ListButton {
							//% "BMS control"
							text: qsTrId("genset_bms_control")
							secondaryText: CommonWords.press_to_reset
							visible: defaultAllowed && bmsControlled.dataItem.value === 1
							onClicked: bmsControlled.dataItem.setValue(0)
						}
					}
				}
			}
		}
	}

	ListNavigation { // to test, use the 'gdh' simulation. Not visible with the 'gdf' simulation.
		text: CommonWords.settings
		onClicked: {
			Global.pageManager.pushPage("/pages/settings/PageSettingsGenerator.qml",
										{ title: text, settingsBindPrefix: root.settingsBindPrefix, startStopBindPrefix: root.startStopBindPrefix })
		}
	}

	ListNavigation {
		text: CommonWords.device_info_title
		onClicked: {
			Global.pageManager.pushPage("/pages/settings/PageDeviceInfo.qml",
					{ "title": text, "bindPrefix": root.bindPrefix })
		}
	}
}

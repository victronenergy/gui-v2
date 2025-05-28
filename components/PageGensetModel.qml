/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

VisibleItemModel {
	id: root

	property string bindPrefix
	property string settingsBindPrefix: Global.systemSettings.serviceUid + "/Settings/Generator1"
	property string startStopBindPrefix: _startStop1Finder.startStop1Uid
	readonly property string serviceType: BackendConnection.serviceTypeFromUid(bindPrefix)
	readonly property bool dcGenset: serviceType === "dcgenset"
	readonly property int nrOfPhases: phases.valid ? phases.value
												   : dcGenset ? 0
															  : 3

	// In case of multiple gensets, startstop will control the one with the lowest device instance.
	// Check if this genset is controlled by startstop by checking if the instance is the same.
	// When not controlled by startstop, the genset can only be monitored, so hide some controls.
	readonly property bool isStartStopControlled: startStopGensetInstance.valid && gensetInstance.valid ?
											startStopGensetInstance.value === gensetInstance.value : false

	readonly property bool isGensetEnabled: gensetEnabled.valid ? gensetEnabled.value === 1 : false

	readonly property VeQuickItem startStopGensetInstance: VeQuickItem {
		uid: root.startStopBindPrefix ? root.startStopBindPrefix + "/GensetInstance" : ""
	}

	readonly property VeQuickItem gensetInstance: VeQuickItem {
		uid: root.bindPrefix + "/DeviceInstance"
	}

	readonly property VeQuickItem phases: VeQuickItem {
		uid: root.bindPrefix + "/NrOfPhases"
	}

	readonly property VeQuickItem gensetEnabled: VeQuickItem {
		uid: root.startStopBindPrefix ? root.startStopBindPrefix + "/Enabled" : ""
	}

	readonly property GensetStartStop1Finder _startStop1Finder: GensetStartStop1Finder {
		gensetServiceUid: root.bindPrefix
	}

	// Show when startstop controlled but not enabled (because the required helper relay is not configured) and only if the genset service is present.
	PrimaryListLabel {
		preferredVisible: gensetInstance.valid && root.isStartStopControlled && !root.isGensetEnabled
		//% "This genset controller requires a helper relay to be controlled but the helper relay is not configured. Please configure Relay 1 under Settings → Relay to \"Connected genset helper relay\"."
		text: qsTrId("genset_controller_requires_helper_relay")
	}

	// Show when not startstop controlled, but only if the genset service is present.
	PrimaryListLabel {
		preferredVisible: gensetInstance.valid && !root.isStartStopControlled
		//% "Multiple genset controllers detected.\nThe GX device can only control one connected genset and takes the one with the lowest VRM instance number. To avoid unexpected behavior, make sure that only one unit is available to the GX device."
		text: qsTrId("genset_controller_multiple_genset_controllers")
	}

	ListSwitch {
		id: autostartSwitch
		//% "Auto start functionality"
		text: qsTrId("ac-in-genset_auto_start_functionality")
		preferredVisible: root.isGensetEnabled && root.isStartStopControlled
		dataItem.uid: root.startStopBindPrefix ? root.startStopBindPrefix + "/AutoStartEnabled" : ""
		updateDataOnClick: false

		onClicked: {
			if (!checked) {
				autostartSwitch.dataItem.setValue(1)
			} else {
				// check if they really want to disable
				Global.dialogLayer.open(confirmationDialogComponent)
			}
		}

		Component {
			id: confirmationDialogComponent

			GeneratorDisableAutoStartDialog {
				onAccepted: autostartSwitch.dataItem.setValue(0)
			}
		}
	}

	ListItem {
		text: CommonWords.manual_control
		preferredVisible: root.isGensetEnabled && root.isStartStopControlled
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
		secondaryText: dataItem.valid ? Utils.secondsToString(dataItem.value, false) : "0"
		dataItem.uid: root.startStopBindPrefix ? root.startStopBindPrefix + "/Runtime" : ""
		preferredVisible: generatorState.value >= 1 && generatorState.value <= 3 // Running, Warm-up, Cool-down
	}

	ListText {
		//% "Control status"
		text: qsTrId("ac-in-genset_auto_control_status")
		secondaryText: activeCondition.isAutoStarted && generatorState.value === VenusOS.Generators_State_Running
						   ? CommonWords.autostarted_dot_running_by.arg(Global.generators.runningByText(activeCondition.value))
						   : Global.generators.stateAndCondition(generatorState.value, activeCondition.value)
		preferredVisible: root.isStartStopControlled

		VeQuickItem {
			id: activeCondition
			readonly property bool isAutoStarted: valid && Global.generators.isAutoStarted(value)
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
		preferredVisible: dataItem.valid && root.isStartStopControlled
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

		preferredVisible: _dataItem.valid
		interactive: secondaryText !== CommonWords.none_errors

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

	SettingsColumn {
		width: parent ? parent.width : 0
		preferredVisible: phaseRepeater.count > 0

		Repeater {
			id: phaseRepeater

			model: root.nrOfPhases
			delegate: ListQuantityGroup {
				id: phaseDelegate

				required property int index
				readonly property string bindPrefix: `${root.bindPrefix}/Ac/L${index + 1}`

				text: phaseRepeater.count === 1
						//% "AC"
					  ? qsTrId("ac-in-genset_ac")
					  : CommonWords.ac_phase_x.arg(index + 1)
				model: QuantityObjectModel {
					QuantityObject { object: phaseVoltage; unit: VenusOS.Units_Volt_AC }
					QuantityObject { object: phaseCurrent; unit: VenusOS.Units_Amp }
					QuantityObject { object: phasePower; unit: VenusOS.Units_Watt }
				}

				VeQuickItem {
					id: phaseVoltage
					uid: phaseDelegate.bindPrefix + "/Voltage"
				}
				VeQuickItem {
					id: phaseCurrent
					uid: phaseDelegate.bindPrefix + "/Current"
				}
				VeQuickItem {
					id: phasePower
					uid: phaseDelegate.bindPrefix + "/Power"
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
		preferredVisible: root.dcGenset
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
					model: VisibleItemModel {
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
							preferredVisible: dataItem.valid
							unit: VenusOS.Units_Percentage
						}

						ListQuantity {
							//% "Oil pressure"
							text: qsTrId("ac-in-genset_oil_pressure")
							dataItem.uid: root.bindPrefix + "/Engine/OilPressure"
							preferredVisible: dataItem.valid
							unit: VenusOS.Units_Kilopascal
						}

						ListTemperature {
							//% "Oil temperature"
							text: qsTrId("ac-in-genset_oil_temperature")
							preferredVisible: dataItem.valid
							dataItem.uid: root.bindPrefix + "/Engine/OilTemperature"
							precision: 0
						}

						ListTemperature {
							//% "Coolant temperature"
							text: qsTrId("ac-in-genset_coolant_temperature")
							preferredVisible: dataItem.valid
							dataItem.uid: root.bindPrefix + "/Engine/CoolantTemperature"
							precision: 0
						}

						ListTemperature {
							//% "Exhaust temperature"
							text: qsTrId("ac-in-genset_exhaust_temperature")
							preferredVisible: dataItem.valid
							dataItem.uid: root.bindPrefix + "/Engine/ExaustTemperature"
						}

						ListTemperature {
							//% "Winding temperature"
							text: qsTrId("ac-in-genset_winding_temperature")
							preferredVisible: dataItem.valid
							dataItem.uid: root.bindPrefix + "/Engine/WindingTemperature"
						}

						ListTemperature {
							//% "Heatsink temperature"
							text: qsTrId("genset_heatsink_temperature")
							dataItem.uid: root.bindPrefix + "/HeatsinkTemperature"
							preferredVisible: dataItem.valid
						}

						ListQuantity {
							//% "Starter battery voltage"
							text: qsTrId("ac-in-genset_starter_battery_voltage")
							dataItem.uid: root.bindPrefix + "/StarterVoltage"
							preferredVisible: dataItem.valid
							unit: VenusOS.Units_Volt_DC
						}

						ListText {
							//% "Number of starts"
							text: qsTrId("ac-in-genset_number_of_starts")
							dataItem.uid: root.bindPrefix + "/Engine/Starts"
							preferredVisible: dataItem.valid
						}
					}
				}
			}
		}
	}

	ListNavigation {
		//% "Run time and service"
		text: qsTrId("page_settings_generator_run_time_and_service")
		preferredVisible: root.isStartStopControlled
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
		preferredVisible: root.isStartStopControlled && (chargeVoltage.valid || chargeCurrent.valid || bmsControlled.valid)
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
					model: VisibleItemModel {
						ListSpinBox {
							//% "Charge voltage"
							text: qsTrId("genset_charge_voltage")
							dataItem.uid: root.bindPrefix + "/Settings/ChargeVoltage"
							decimals: 1
							stepSize: 0.1
							suffix: Units.defaultUnitString(VenusOS.Units_Volt_DC)
							preferredVisible: dataItem.valid
							interactive: dataItem.valid && bmsControlled.dataItem.value === 0
						}

						ListText {
							//% "The charge voltage is currently controlled by the BMS."
							text: qsTrId("genset_charge_voltage_controlled_by_bms")
							preferredVisible: bmsControlled.dataItem.value === 1
						}

						ListSpinBox {
							//% "Charge current limit"
							text: qsTrId("genset_charge_current_limit")
							dataItem.uid: root.bindPrefix + "/Settings/ChargeCurrentLimit"
							suffix: Units.defaultUnitString(VenusOS.Units_Amp)
							preferredVisible: dataItem.valid
						}

						ListText {
							id: bmsControlled

							text: CommonWords.bms_controlled
							secondaryText: CommonWords.yesOrNo(dataItem.value)
							dataItem.uid: root.bindPrefix + "/Settings/BmsPresent"
							preferredVisible: dataItem.valid
							caption: bmsControlled.dataItem.value === 1 ? CommonWords.bms_control_info : ""
						}

						ListButton {
							text: CommonWords.bms_control
							secondaryText: CommonWords.press_to_reset
							preferredVisible: bmsControlled.dataItem.value === 1
							onClicked: bmsControlled.dataItem.setValue(0)
						}
					}
				}
			}
		}
	}

	ListNavigation { // to test, use the 'gdh' simulation. Not visible with the 'gdf' simulation.
		text: CommonWords.settings
		preferredVisible: root.isStartStopControlled
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

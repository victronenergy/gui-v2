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

	// On D-Bus, the startstop1 generator is at com.victronenergy.generator.startstop1.
	// On MQTT, the startstop1 generator is the one with GensetService=com.victronenergy.genset.*
	readonly property string startStop1Uid: BackendConnection.type === BackendConnection.MqttSource
			? generatorWithGensetService
			: BackendConnection.uidPrefix() + "/com.victronenergy.generator.startstop1"
	property string generatorWithGensetService

	property Instantiator generatorObjects: Instantiator {
		model: BackendConnection.type === BackendConnection.MqttSource ? Global.generators.model : null
		delegate: VeQuickItem {
			uid: model.device.serviceUid + "/GensetService"
			onValueChanged: {
				if (value !== undefined && value.startsWith("com.victronenergy.genset.")) {
					root.generatorWithGensetService = model.device.serviceUid
				}
			}
		}
	}

	readonly property var nrOfPhases: VeQuickItem {
		uid: root.bindPrefix + "/NrOfPhases"
	}

	ListSwitch {
		//% "Auto start functionality"
		text: qsTrId("ac-in-genset_auto_start_functionality")
		dataItem.uid: root.startStopBindPrefix ? root.startStopBindPrefix + "/AutoStartEnabled" : ""
	}

	ListItem {
		text: CommonWords.manual_control
		content.children: [
			GeneratorManualControlButton {
				generatorUid: root.startStopBindPrefix
				gensetUid: root.bindPrefix
			}
		]
	}

	ListTextItem {
		//% "Current run time"
		text: qsTrId("settings_page_genset_generator_run_time")
		secondaryText: dataItem.isValid ? Utils.secondsToString(dataItem.value, false) : "0"
		dataItem.uid: root.startStopBindPrefix ? root.startStopBindPrefix + "/Runtime" : ""
		allowed: generatorState.value >= 1 && generatorState.value <= 3 // Running, Warm-up, Cool-down
	}

	ListTextItem {
		//% "Control status"
		text: qsTrId("ac-in-genset_auto_control_status")
		secondaryText: activeCondition.isValid ? Global.generators.stateToText(generatorState.value, activeCondition.value) : "--"

		VeQuickItem {
			id: activeCondition
			uid: root.startStopBindPrefix ? root.startStopBindPrefix + "/RunningByCondition" : ""
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

	ListTextItem {
		//% "Genset status"
		text: qsTrId("ac-in-genset_status")
		secondaryText: Global.acInputs.gensetStatusCodeToText(gensetStatus.value)

		VeQuickItem {
			id: gensetStatus
			uid: root.bindPrefix + "/StatusCode"
		}
	}

	ListNavigationItem {
		//% "Genset error codes"
		text: qsTrId("ac-in-genset_error")
		secondaryText: {
			let errorCodes = ""
			for (let i = 0; i < errorModel.errorCodes.length; ++i) {
				if (errorModel.errorCodes[i]) {
					errorCodes += (errorCodes.length ? " " : "") + errorModel.errorCodes[i]
				}
			}
			return errorCodes.length ? errorCodes : CommonWords.none_errors
		}

		allowed: defaultAllowed && dataItem.isValid
		enabled: secondaryText !== CommonWords.none_errors

		onClicked: Global.notificationLayer.popAndGoToNotifications()

		property VeQuickItem dataItem: VeQuickItem {
			uid: root.bindPrefix + "/Error/0/Id"
		}
		property GensetErrorModel errorModel: GensetErrorModel {
			uidPrefix: root.bindPrefix
		}
	}

	ListButton {
		//% "Clear genset error"
		text: qsTrId("ac-in-clear-genset_error")
		secondaryText: CommonWords.press_to_clear
		allowed: gensetStatus.value === 10
		onClicked: startItem.setValue(0)

		VeQuickItem {
			id: startItem
			uid: root.bindPrefix + "/Start"
		}
	}

	Column {
		width: parent ? parent.width : 0

		Repeater {
			id: phaseRepeater

			model: root.nrOfPhases.value || 3
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

	ListTextItem {
		//% "Remote start mode"
		text: qsTrId("ac-in-genset_remote_start_mode")
		dataItem.uid: root.bindPrefix + "/RemoteStartModeEnabled"
		secondaryText: CommonWords.enabledOrDisabled(dataItem.value)
	}

	ListNavigationItem {
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
						ListQuantityItem {
							//% "Speed"
							text: qsTrId("ac-in-genset_speed")
							dataItem.uid: root.bindPrefix + "/Engine/Speed"
							unit: VenusOS.Units_RevolutionsPerMinute
						}

						ListQuantityItem {
							//% "Load"
							text: qsTrId("ac-in-genset_load")
							dataItem.uid: root.bindPrefix + "/Engine/Load"
							allowed: defaultAllowed && dataItem.isValid
							unit: VenusOS.Units_Percentage
						}

						ListQuantityItem {
							//% "Oil pressure"
							text: qsTrId("ac-in-genset_oil_pressure")
							dataItem.uid: root.bindPrefix + "/Engine/OilPressure"
							allowed: defaultAllowed && dataItem.isValid
							unit: VenusOS.Units_Kilopascal
						}

						ListTemperatureItem {
							//% "Oil temperature"
							text: qsTrId("ac-in-genset_oil_temperature")
							allowed: defaultAllowed && dataItem.isValid
							dataItem.uid: root.bindPrefix + "/Engine/OilTemperature"
							precision: 0
						}

						ListTemperatureItem {
							//% "Coolant temperature"
							text: qsTrId("ac-in-genset_coolant_temperature")
							allowed: defaultAllowed && dataItem.isValid
							dataItem.uid: root.bindPrefix + "/Engine/CoolantTemperature"
							precision: 0
						}

						ListTemperatureItem {
							//% "Exhaust temperature"
							text: qsTrId("ac-in-genset_exhaust_temperature")
							allowed: defaultAllowed && dataItem.isValid
							dataItem.uid: root.bindPrefix + "/Engine/ExaustTemperature"
						}

						ListTemperatureItem {
							//% "Winding temperature"
							text: qsTrId("ac-in-genset_winding_temperature")
							allowed: defaultAllowed && dataItem.isValid
							dataItem.uid: root.bindPrefix + "/Engine/WindingTemperature"
						}

						ListQuantityItem {
							//% "Starter battery voltage"
							text: qsTrId("ac-in-genset_starter_battery_voltage")
							dataItem.uid: root.bindPrefix + "/StarterVoltage"
							allowed: defaultAllowed && dataItem.isValid
							unit: VenusOS.Units_Volt_DC
						}

						ListTextItem {
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

	ListNavigationItem {
		text: CommonWords.settings
			onClicked: {
				Global.pageManager.pushPage("/pages/settings/PageSettingsGenerator.qml",
					{ title: text, settingsBindPrefix: root.settingsBindPrefix, startStopBindPrefix: root.startStopBindPrefix })
			}
	}

	ListNavigationItem {
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

	ListNavigationItem {
		text: CommonWords.device_info_title
		onClicked: {
			Global.pageManager.pushPage("/pages/settings/PageDeviceInfo.qml",
					{ "title": text, "bindPrefix": root.bindPrefix })
		}
	}
}

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

	readonly property VeQuickItem gensetEnabled: VeQuickItem {
		uid: root.startStopBindPrefix ? root.startStopBindPrefix + "/Enabled" : ""
	}

	ListLabel {
		allowed: root.gensetEnabled.value === 0
		//% "This genset controller requires a helper relay to be controlled but the helper relay is not configured. Please configure Relay 1 under Settings → Relay to \"Connected genset helper relay\"."
		text: qsTrId("genset_controller_requires_helper_relay")
	}

	ListSwitch {
		//% "Auto start functionality"
		text: qsTrId("ac-in-genset_auto_start_functionality")
		allowed: root.gensetEnabled.value === 1
		dataItem.uid: root.startStopBindPrefix ? root.startStopBindPrefix + "/AutoStartEnabled" : ""
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

	ListFpGensetErrorItem {
		//% "Genset error code"
		text: qsTrId("ac-in-genset_error")
		dataItem.uid: root.bindPrefix + "/ErrorCode"
		allowed: defaultAllowed && dataItem.isValid
		nrOfPhases: root.nrOfPhases.value || 3
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
		//% "Auto start/stop"
		text: qsTrId("ac-in-genset_auto_start_stop")
		onClicked: {
			const props = {
				"title": text,
				"settingsBindPrefix": root.settingsBindPrefix,
				"startStopBindPrefix": root.startStopBindPrefix
			}
			Global.pageManager.pushPage("/pages/settings/PageGenerator.qml", props)
		}
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

						ListTextItem {
							//% "Operating time"
							text: qsTrId("ac-in-genset_operating_time")
							allowed: defaultAllowed && dataItem.isValid
							dataItem.uid: root.bindPrefix + "/Engine/OperatingHours"
							secondaryText: Utils.formatAsHHMM(dataItem.value, true)
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
		text: CommonWords.device_info_title
		onClicked: {
			Global.pageManager.pushPage("/pages/settings/PageDeviceInfo.qml",
					{ "title": text, "bindPrefix": root.bindPrefix })
		}
	}
}

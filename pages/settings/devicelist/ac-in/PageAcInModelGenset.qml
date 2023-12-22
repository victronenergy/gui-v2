/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil
import Victron.Units
import Victron.Utils

ObjectModel {
	id: root

	property string bindPrefix

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

	readonly property var nrOfPhases: DataPoint {
		source: root.bindPrefix + "/NrOfPhases"
	}

	ListRadioButtonGroup {
		readonly property int index_on: 0
		readonly property int index_off: 1
		readonly property int index_autoStartStop: 2

		text: CommonWords.mode
		enabled: gensetStatus.valid
		optionModel: [
			{ display: CommonWords.on, value: 1 },
			{ display: CommonWords.off, value: 0 },
			{ display: generatorNavigationItem.text, value: 2 },
		]
		updateOnClick: false
		currentIndex: autoStartStopItem.value === 1 ? index_autoStartStop
					: modeItem.value === 1 ? index_on : index_off

		onOptionClicked: function(index) {
			if (index === index_off) {
				autoStartStopItem.setValue(0)
				modeItem.setValue(0)
			} else if (index === index_on) {
				if (autoStart.value === 0) {
					//% "AutoStart functionality is currently disabled, enable it on the genset panel in order to start the genset from this menu."
					Global.showToastNotification(VenusOS.Notification_Info, qsTrId("ac-in-genset_autostart_functionality_disabled"), 7000)
					return
				}
				autoStartStopItem.setValue(0)
				modeItem.setValue(1)
			} else if (index === index_autoStartStop) {
				autoStartStopItem.setValue(1)
				modeItem.setValue(0)
			}
		}

		DataPoint {
			id: modeItem
			source: root.startStop1Uid + "/ManualStart"
		}
		DataPoint {
			id: autoStartStopItem
			source: root.startStop1Uid + "/AutoStartEnabled"
		}
		DataPoint {
			id: autoStart
			source: root.bindPrefix + "/AutoStart"
		}
	}

	ListTextItem {
		text: CommonWords.status
		secondaryText: Global.acInputs.gensetStatusCodeToText(gensetStatus.value)

		DataPoint {
			id: gensetStatus
			source: root.bindPrefix + "/StatusCode"
		}
	}

	ListFpGensetErrorItem {
		text: CommonWords.error_code
		dataSource: root.bindPrefix + "/ErrorCode"
		visible: defaultVisible && dataValid
		nrOfPhases: root.nrOfPhases.value || 3
	}

	ListButton {
		text: CommonWords.clear_error_action
		secondaryText: CommonWords.press_to_clear
		visible: gensetStatus.value === 10
		onClicked: startItem.setValue(0)

		DataPoint {
			id: startItem
			source: root.bindPrefix + "/Start"
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
					{ value: phaseVoltage.value, unit: VenusOS.Units_Volt },
					{ value: phaseCurrent.value, unit: VenusOS.Units_Amp },
					{ value: phasePower.value, unit: VenusOS.Units_Watt },
				]

				DataPoint {
					id: phaseVoltage
					source: root.bindPrefix + "/Ac/L" + (model.index + 1) + "/Voltage"
				}
				DataPoint {
					id: phaseCurrent
					source: root.bindPrefix + "/Ac/L" + (model.index + 1) + "/Current"
				}
				DataPoint {
					id: phasePower
					source: root.bindPrefix + "/Ac/L" + (model.index + 1) + "/Power"
				}
			}
		}
	}

	ListNavigationItem {
		id: generatorNavigationItem
		//% "Auto start/stop"
		text: qsTrId("ac-in-genset_auto_start_stop")
		visible: autoStartStopItem.value === 1
		onClicked: {
			const props = {
				"title": text,
				"settingsBindPrefix": Global.systemSettings.serviceUid + "/Settings/Generator1",
				"startStopBindPrefix": root.startStop1Uid,
				"allowDisableAutostart": false,
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
							dataSource: root.bindPrefix + "/Engine/Speed"
							unit: VenusOS.Units_RevolutionsPerMinute
						}

						ListTextItem {
							//% "Load"
							text: qsTrId("ac-in-genset_load")
							dataSource: root.bindPrefix + "/Engine/Load"
							visible: defaultVisible && dataValid
						}

						ListTextItem {
							//% "Oil Pressure"
							text: qsTrId("ac-in-genset_oil_pressure")
							dataSource: root.bindPrefix + "/Engine/OilPressure"
							visible: defaultVisible && dataValid
						}

						ListQuantityItem {
							//% "Coolant temperature"
							text: qsTrId("ac-in-genset_coolant_temperature")
							visible: defaultVisible && dataValid
							dataSource: root.bindPrefix + "/Engine/CoolantTemperature"
							value: Units.convertFromCelsius(dataValue, Global.systemSettings.temperatureUnit.value)
							unit: Global.systemSettings.temperatureUnit.value
						}

						ListQuantityItem {
							//% "Exhaust temperature"
							text: qsTrId("ac-in-genset_exhaust_temperature")
							visible: defaultVisible && dataValid
							dataSource: root.bindPrefix + "/Engine/ExaustTemperature"
							value: Units.convertFromCelsius(dataValue, Global.systemSettings.temperatureUnit.value)
							unit: Global.systemSettings.temperatureUnit.value
						}

						ListQuantityItem {
							//% "Winding temperature"
							text: qsTrId("ac-in-genset_winding_temperature")
							visible: defaultVisible && dataValid
							dataSource: root.bindPrefix + "/Engine/WindingTemperature"
							value: Units.convertFromCelsius(dataValue, Global.systemSettings.temperatureUnit.value)
							unit: Global.systemSettings.temperatureUnit.value
						}

						ListTextItem {
							//% "Operating time"
							text: qsTrId("ac-in-genset_operating_time")
							visible: defaultVisible && dataValid
							dataSource: root.bindPrefix + "/Engine/OperatingHours"
							secondaryText: Utils.secondsToString(dataValue)
						}

						ListQuantityItem {
							//% "Starter battery voltage"
							text: qsTrId("ac-in-genset_starter_battery_voltage")
							dataSource: root.bindPrefix + "/StarterVoltage"
							visible: defaultVisible && dataValid
							unit: VenusOS.Units_Volt
						}

						ListTextItem {
							//% "Number of starts"
							text: qsTrId("ac-in-genset_number_of_starts")
							dataSource: root.bindPrefix + "/Engine/Starts"
							visible: defaultVisible && dataValid
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

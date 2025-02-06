/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListNavigation {
	id: root

	property string bindPrefix
	property string unit: ""
	property string timeUnit: "s"
	property int decimals: 1
	property bool startValueIsGreater: true
	property bool supportsWarmup: false
	property bool showTankServices:false
	property string name: text
	property string startStopBindPrefix

	//% "Use %1 value to start/stop"
	property string enableDescription: qsTrId("generator_condition_use_value_to_start_stop").arg(name)

	//% "Start when %1 is higher than"
	readonly property string startValueDescriptionHigher: qsTrId("generator_condition_start_when_property_is_higher_than").arg(root.name)

	//% "Start when %1 is lower than"
	readonly property string startValueDescriptionLower: qsTrId("generator_condition_start_when_property_is_lower_than").arg(root.name)
	readonly property string startValueDescription: startValueIsGreater ? startValueDescriptionHigher : startValueDescriptionLower
	property string startTimeDescription: CommonWords.start_after_the_condition_is_reached_for

	//% "Stop when %1 is higher than"
	readonly property string stopValueDescriptionHigher: qsTrId("generator_condition_stop_when_property_is_higher_than").arg(root.name)

	//% "Stop when %1 is lower than"
	readonly property string stopValueDescriptionLower: qsTrId("generator_condition_stop_when_property_is_lower_than").arg(root.name)
	readonly property string stopValueDescription: !startValueIsGreater ? stopValueDescriptionHigher : stopValueDescriptionLower
	property string stopTimeDescription: CommonWords.stop_after_the_condition_is_reached_for

	// Autocalculate step size based on number of decimals
	readonly property real stepSize: Math.pow(10, -decimals)

	secondaryText: dataItem.value === 1 ? CommonWords.enabled : CommonWords.disabled
	onClicked: Global.pageManager.pushPage(subpage)

	VeQuickItem {
		id: dataItem

		uid: bindPrefix + "/Enabled"
	}

	Component {
		id: subpage

		Page {
			title: root.text

			GradientListView {

				model: ObjectModel {

					ListSwitch {
						text: root.enableDescription
						dataItem.uid: bindPrefix + "/Enabled"
					}

					ListRadioButtonGroup {
						id: tankService
						preferredVisible: showTankServices && dataItem.isValid

						//% "Tank service"
						text: qsTrId("page_generator_conditions_tank_service")
						//% "Unavailable tank service, set another"
						defaultSecondaryText: qsTrId("page_generator_conditions_unavailable_tank_service_set_another")
						dataItem.uid: bindPrefix + "/TankService"

						VeQuickItem {
							id: availableTankServices

							uid: startStopBindPrefix + "/AvailableTankServices"
							onValueChanged: {
								if (value === undefined) {
									return
								}
								const modelArray = Utils.jsonSettingsToModel(value)
								if (modelArray) {
									tankService.optionModel = modelArray
								} else {
									console.warn("Unable to parse data from", source)
								}
							}
						}
					}

					ListSpinBox {
						id: startValue

						text: startValueDescription
						preferredVisible: dataItem.isValid
						dataItem.uid: bindPrefix + "/StartValue"
						suffix: root.unit
						decimals: root.decimals
						stepSize: root.stepSize
						from: stopValue.dataItem.isValid && root.startValueIsGreater ? stopValue.value + stepSize : dataItem.defaultMin
						to: stopValue.dataItem.isValid && !root.startValueIsGreater ? stopValue.value - stepSize : dataItem.defaultMax
					}

					ListSpinBox {
						id: quietHoursStartValue

						text: CommonWords.start_value_during_quiet_hours
						preferredVisible: dataItem.isValid
						dataItem.uid: bindPrefix + "/QuietHoursStartValue"
						suffix: root.unit
						decimals: root.decimals
						stepSize: root.stepSize
						from: quietHoursStopValue.dataItem.isValid && root.startValueIsGreater ? quietHoursStopValue.value + stepSize : dataItem.defaultMin
						to: quietHoursStopValue.dataItem.isValid && !root.startValueIsGreater ? quietHoursStopValue.value - stepSize : dataItem.defaultMax
					}

					ListSpinBox {
						id: startTime

						text: startTimeDescription
						preferredVisible: dataItem.isValid
						dataItem.uid: bindPrefix + "/StartTimer"
						suffix: root.timeUnit
					}

					ListSpinBox {
						id: stopValue

						text: stopValueDescription
						preferredVisible: dataItem.isValid
						dataItem.uid: bindPrefix + "/StopValue"
						suffix: root.unit
						decimals: root.decimals
						stepSize: root.stepSize
						to: startValue.dataItem.isValid && root.startValueIsGreater ? startValue.value - stepSize : dataItem.defaultMax
						from: startValue.dataItem.isValid && !root.startValueIsGreater ? startValue.value + stepSize : dataItem.defaultMin
					}

					ListSpinBox {
						id: quietHoursStopValue

						text: CommonWords.stop_value_during_quiet_hours
						preferredVisible: dataItem.isValid
						dataItem.uid: bindPrefix + "/QuietHoursStopValue"
						suffix: root.unit
						decimals: root.decimals
						stepSize: root.stepSize
						to: quietHoursStartValue.dataItem.isValid && root.startValueIsGreater ? quietHoursStartValue.value - stepSize : dataItem.defaultMax
						from: quietHoursStartValue.dataItem.isValid && !root.startValueIsGreater ? quietHoursStartValue.value + stepSize : dataItem.defaultMin
					}

					ListSpinBox {
						id: stopTime

						text: stopTimeDescription
						preferredVisible: dataItem.isValid
						dataItem.uid: bindPrefix + "/StopTimer"
						suffix: root.timeUnit
					}

					ListSwitch {
						//% "Skip generator warm-up"
						text: qsTrId("settings_generator_condition_skip_warmup")
						dataItem.uid: bindPrefix + "/SkipWarmup"
						preferredVisible: root.supportsWarmup
					}

					ListSwitch {
						//% "Trigger warning when the generator is stopped"
						text: qsTrId("settings_generator_condition_tank_level_enable_warning")
						dataItem.uid: bindPrefix + "/WarningEnabled"
						preferredVisible: showTankServices
					}
				}
			}
		}
	}
}

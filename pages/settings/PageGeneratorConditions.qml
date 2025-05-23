/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string bindPrefix
	property string startStopBindPrefix

	VeQuickItem {
		id: stopOnAc1Item

		uid: bindPrefix + "/StopWhenAc1Available"
	}

	VeQuickItem {
		id: stopOnAc2Item

		uid: bindPrefix + "/StopWhenAc2Available"
	}

	VeQuickItem {
		id: capabilities

		uid: startStopBindPrefix + "/Capabilities"
	}

	GradientListView {
		id: settingsListView

		model: VisibleItemModel {

			ListRadioButtonGroup {
				id: monitorService

				//% "Battery monitor"
				text: qsTrId("page_generator_conditions_battery_monitor")
				//% "Unavailable monitor, set another"
				defaultSecondaryText: qsTrId("page_generator_conditions_unavailable_monitor_set_another")
				dataItem.uid: bindPrefix + "/BatteryService"
				preferredVisible: dataItem.value !== "default"

				VeQuickItem {
					id: availableBatteryServices

					uid: Global.system.serviceUid + "/AvailableBatteryMeasurements"
					onValueChanged: {
						if (value === undefined) {
							return
						}
						const modelArray = Utils.jsonSettingsToModel(value)
						if (modelArray) {
							monitorService.optionModel = modelArray
						} else {
							console.warn("Unable to parse data from", source)
						}
					}
				}
			}

			ListRadioButtonGroup {
				//% "On loss of communication"
				text: qsTrId("page_generator_conditions_on_loss_of_communication")
				dataItem.uid: bindPrefix + "/OnLossCommunication"
				optionModel: [
					//% "Stop generator"
					{ display: qsTrId("page_generator_conditions_stop_generator"), value: 0 },
					//% "Start generator"
					{ display: qsTrId("page_generator_conditions_start_generator"), value: 1 },
					//% "Keep generator running"
					{ display: qsTrId("page_generator_conditions_keep_generator_running"), value: 2 },
				]
			}

			ListRadioButtonGroup {
				//% "Stop generator when AC-input is available"
				text: qsTrId("page_generator_conditions_stop_generator_when_ac_input_available")
				currentIndex: stopOnAc1Item.value === 1
					   ? 1 : stopOnAc2Item.value === 1
							  ? 2 : 0
				optionModel: [
					{ display: CommonWords.disabled, value: 0 },
					{ display: CommonWords.acInputFromNumber(1), value: 1 },
					{ display: CommonWords.acInputFromNumber(2), value: 2, readOnly: !(capabilities.value & 1) },
				]

				onOptionClicked: function(index) {
					stopOnAc1Item.setValue(index & 1)
					stopOnAc2Item.setValue((index & 2) >> 1)
					if (index > 0) {
						//% "Make sure that the generator is not connected to AC input %1 when using this option"
						Global.showToastNotification(VenusOS.Notification_Info, qsTrId("page_generator_conditions_make_sure_generator_is_not_connected").arg(index),
																   Theme.animation_generator_stopWhenAc1Available_toastNotification_autoClose_duration)
					}
				}
			}

			GeneratorCondition {
				//% "Battery SOC"
				text: qsTrId("page_generator_conditions_battery_soc")
				bindPrefix: root.bindPrefix + "/Soc"
				startValueIsGreater: false
				decimals: 0
				unit: "%"
			}

			GeneratorCondition {
				text: CommonWords.battery_current
				bindPrefix: root.bindPrefix + "/BatteryCurrent"
				unit: Units.defaultUnitString(VenusOS.Units_Amp)
			}

			GeneratorCondition {
				text: CommonWords.battery_voltage
				bindPrefix: root.bindPrefix + "/BatteryVoltage"
				startValueIsGreater: false
				unit: "V"
			}

			ListNavigation {
				text: CommonWords.ac_load
				secondaryText: acLoadEnabled.value === 1 ? CommonWords.enabled : CommonWords.disabled
				onClicked: Global.pageManager.pushPage("/pages/settings/PageGeneratorAcLoad.qml", { title: text, bindPrefix: root.bindPrefix + "/AcLoad"})

				VeQuickItem {
					id: acLoadEnabled

					uid: root.bindPrefix + "/AcLoad/Enabled"
				}
			}

			GeneratorCondition {
				//% "Inverter high temperature"
				text: qsTrId("page_generator_conditions_inverter_high_temperature")
				//% "Start on high temperature warning"
				enableDescription: qsTrId("page_generator_conditions_start_on_high_temperature_warning")
				startTimeDescription: CommonWords.start_when_warning_is_active_for
				stopTimeDescription: CommonWords.when_warning_is_cleared_stop_after
				bindPrefix: root.bindPrefix + "/InverterHighTemp"
			}

			GeneratorCondition {
				text: CommonWords.inverter_overload
				//% "Start on overload warning"
				enableDescription: qsTrId("page_generator_conditions_start_on_overload_warning")
				startTimeDescription: CommonWords.start_when_warning_is_active_for
				stopTimeDescription: CommonWords.when_warning_is_cleared_stop_after
				supportsWarmup: (capabilities.value & 1)
				bindPrefix: root.bindPrefix + "/InverterOverload"
			}

			GeneratorCondition {
				//% "Tank level"
				text: qsTrId("page_generator_conditions_tank_level")

				//% "Stop on tank level"
				enableDescription: qsTrId("page_generator_conditions_stop_on_tank_level")
				showTankServices: true
				startStopBindPrefix: root.startStopBindPrefix

				bindPrefix: root.bindPrefix + "/TankLevel"
				decimals: 0
				unit: "%"
			}

			ListNavigation {
				//% "Periodic run"
				text: qsTrId("page_generator_conditions_periodic_run")
				secondaryText: testRunEnabled.value === 1 ? CommonWords.enabled : CommonWords.disabled
				onClicked: Global.pageManager.pushPage("/pages/settings/PageGeneratorTestRun.qml", { title: text, bindPrefix: root.bindPrefix })

				VeQuickItem {
					id: testRunEnabled

					uid: root.bindPrefix + "/TestRun/Enabled"
				}
			}
		}
	}
}

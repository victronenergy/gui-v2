/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "/components/Utils.js" as Utils

Page {
	id: root

	property string bindPrefix
	property variant availableBatteryMonitors: availableBatteryServices.valid ? availableBatteryServices.value : ""

	DataPoint {
		id: availableBatteryServices
		source: "com.victronenergy.system/AvailableBatteryMeasurements"
	}

	SettingsListView {
		id: settingsListView

		model: ObjectModel {

			SettingsListRadioButtonGroup {
				id: monitorService

				//% "Battery monitor"
				text: qsTrId("page_generator_conditions_battery_monitor")
				//% "Unavailable monitor, set another"
				defaultSecondaryText: qsTrId("page_generator_conditions_unavailable_monitor_set_another")
				source: bindPrefix + "/BatteryService"
				visible: dataPoint.value !== "default"
			}

			SettingsListRadioButtonGroup {
				//% "On loss of communication"
				text: qsTrId("page_generator_conditions_on_loss_of_communication")
				source: bindPrefix + "/OnLossCommunication"
				optionModel: [
					//% "Stop generator"
					{ display: qsTrId("page_generator_conditions_stop_generator"), value: 0 },
					//% "Start generator"
					{ display: qsTrId("page_generator_conditions_start_generator"), value: 1 },
					//% "Keep generator running"
					{ display: qsTrId("page_generator_conditions_keep_generator_running"), value: 2 },
				]
			}

			SettingsListSwitch {
				id: enableSwitch

				//% "Do not run generator when AC1 is in use"
				text: qsTrId("page_generator_conditions_do_not_run_generator_when_ac1_is_in_use")
				source: bindPrefix + "/StopWhenAc1Available"
				onClicked: {
					if (!checked) {
						//% "Make sure that the generator is not connected to the inverter AC input 1 when using this option."
						Global.dialogManager.showToastNotification(VenusOS.Notification_Info, qsTrId("page_generator_conditions_make_sure_generator_is_not_connected"),
																   Theme.animation.generator.stopWhenAc1Available.toastNotification.autoClose.duration)
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
				//% "Battery current"
				text: qsTrId("page_generator_conditions_battery_current")
				bindPrefix: root.bindPrefix + "/BatteryCurrent"
				unit: "A"
			}

			GeneratorCondition {
				text: CommonWords.battery_voltage
				bindPrefix: root.bindPrefix + "/BatteryVoltage"
				startValueIsGreater: false
				unit: "V"
			}

			SettingsListNavigationItem {
				text: CommonWords.ac_load
				secondaryText: acLoadEnabled.value === 1 ? CommonWords.enabled : CommonWords.disabled
				onClicked: Global.pageManager.pushPage("/pages/settings/PageGeneratorAcLoad.qml", { bindPrefix: root.bindPrefix + "/AcLoad"})

				DataPoint {
					id: acLoadEnabled
					source: root.bindPrefix + "/AcLoad/Enabled"
				}
			}
			// TODO: Inverter high temperature
			// TODO: Inverter overload
			// TODO: Periodic run
		}
	}
}


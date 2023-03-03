/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "/components/Utils.js" as Utils

Page {
	id: root

	readonly property string settingsBindPrefix: "com.victronenergy.settings"
	readonly property string pumpBindPrefix: "com.victronenergy.pump.startstop0"

	SettingsListView {
		id: settingsListView

		model: relayFunction.value === undefined
			   ? startStopModel
			   : relayFunction.value === VenusOS.Relay_Function_Tank_Pump ? startStopModel : disabledModel

		DataPoint {
			id: relayFunction
			source: settingsBindPrefix + "/Settings/Relay/Function"
		}
	}

	ObjectModel {
		id: disabledModel

		SettingsLabel {
			horizontalAlignment: Text.AlignHCenter
			//% "Tank pump start/stop function is not enabled. Go to relay settings and set function to \"Tank pump\"."
			text: qsTrId("settings_pump_function_not_enabled" )
		}
	}

	ObjectModel {
		id: startStopModel

		SettingsListTextItem {
			//% "Pump state"
			text: qsTrId("settings_pump_state")
			source: root.pumpBindPrefix + "/State"
			secondaryText: CommonWords.onOrOff(dataPoint.value)
		}

		SettingsListRadioButtonGroup {
			//% "Mode"
			text: qsTrId("settings_pump_mode")
			optionModel: [
				//% "Auto"
				{ display: qsTrId("settings_pump_auto"), value: 0 },
				{ display: CommonWords.onOrOff(1), value: 1 },
				{ display: CommonWords.onOrOff(0), value: 2 },
			]
			source: root.settingsBindPrefix + "/Settings/Pump0/Mode"
		}

		SettingsListRadioButtonGroup {
			id: tankSensor

			//% "Tank sensor"
			text: qsTrId("settings_tank_sensor")
			source: root.settingsBindPrefix + "/Settings/Pump0/TankService"
			//% "Unavailable sensor, set another"
			defaultSecondaryText: qsTrId("settings_tank_unavailable_sensor")

			DataPoint {
				id: availableTankServices

				source: root.pumpBindPrefix + "/AvailableTankServices"
				onValueChanged: {
					if (value === undefined) {
						return
					}
					const modelArray = Utils.jsonSettingsToModel(value)
					if (modelArray) {
						tankSensor.optionModel = modelArray
					} else {
						console.warn("Unable to parse data from", source)
					}
				}
			}
		}

		SettingsListSpinBox {
			//% "Start level"
			text: qsTrId("settings_tank_start_level")
			source: root.settingsBindPrefix + "/Settings/Pump0/StartValue"
			from: 0
			to: 100
			suffix: "%"
		}

		SettingsListSpinBox {
			//% "Stop level"
			text: qsTrId("settings_tank_stop_level")
			source: root.settingsBindPrefix + "/Settings/Pump0/StopValue"
			from: 0
			to: 100
			suffix: "%"
		}
	}
}

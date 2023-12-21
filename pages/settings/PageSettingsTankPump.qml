/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Utils

Page {
	id: root

	readonly property string settingsBindPrefix: Global.systemSettings.serviceUid

	// On D-Bus, the service is com.victronenergy.pump.startstop0
	// On MQTT, there is only one pump service, so it is mqtt/pump/0
	readonly property string pumpBindPrefix: BackendConnection.type === BackendConnection.MqttSource
			? BackendConnection.serviceUidForType("pump")
			: BackendConnection.uidPrefix() + "/com.victronenergy.pump.startstop0"

	GradientListView {
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

		ListLabel {
			horizontalAlignment: Text.AlignHCenter
			//% "Tank pump start/stop function is not enabled. Go to relay settings and set function to \"Tank pump\"."
			text: qsTrId("settings_pump_function_not_enabled" )
		}
	}

	ObjectModel {
		id: startStopModel

		ListTextItem {
			//% "Pump state"
			text: qsTrId("settings_pump_state")
			dataSource: root.pumpBindPrefix + "/State"
			secondaryText: CommonWords.onOrOff(dataValue)
		}

		ListRadioButtonGroup {
			text: CommonWords.mode
			optionModel: [
				//% "Auto"
				{ display: qsTrId("settings_pump_auto"), value: 0 },
				{ display: CommonWords.onOrOff(1), value: 1 },
				{ display: CommonWords.onOrOff(0), value: 2 },
			]
			dataSource: root.settingsBindPrefix + "/Settings/Pump0/Mode"
		}

		ListRadioButtonGroup {
			id: tankSensor

			//% "Tank sensor"
			text: qsTrId("settings_tank_sensor")
			dataSource: root.settingsBindPrefix + "/Settings/Pump0/TankService"
			//% "Unavailable sensor, set another"
			defaultSecondaryText: qsTrId("settings_tank_unavailable_sensor")

			DataPoint {
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

		ListSpinBox {
			//% "Start level"
			text: qsTrId("settings_tank_start_level")
			dataSource: root.settingsBindPrefix + "/Settings/Pump0/StartValue"
			from: 0
			to: 100
			suffix: "%"
		}

		ListSpinBox {
			//% "Stop level"
			text: qsTrId("settings_tank_stop_level")
			dataSource: root.settingsBindPrefix + "/Settings/Pump0/StopValue"
			from: 0
			to: 100
			suffix: "%"
		}
	}
}

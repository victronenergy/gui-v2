/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

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

		VeQuickItem {
			id: relayFunction
			uid: settingsBindPrefix + "/Settings/Relay/Function"
		}
	}

	AllowedItemModel {
		id: disabledModel

		PrimaryListLabel {
			//% "Tank pump start/stop function is not enabled. Go to relay settings and set function to \"Tank pump\"."
			text: qsTrId("settings_pump_function_not_enabled" )
		}
	}

	AllowedItemModel {
		id: startStopModel

		ListText {
			//% "Pump state"
			text: qsTrId("settings_pump_state")
			dataItem.uid: root.pumpBindPrefix + "/State"
			secondaryText: CommonWords.onOrOff(dataItem.value)
		}

		ListRadioButtonGroup {
			text: CommonWords.mode
			optionModel: [
				//% "Auto"
				{ display: qsTrId("settings_pump_auto"), value: 0 },
				{ display: CommonWords.onOrOff(1), value: 1 },
				{ display: CommonWords.onOrOff(0), value: 2 },
			]
			dataItem.uid: root.settingsBindPrefix + "/Settings/Pump0/Mode"
		}

		ListRadioButtonGroup {
			id: tankSensor

			//% "Tank sensor"
			text: qsTrId("settings_tank_sensor")
			dataItem.uid: root.settingsBindPrefix + "/Settings/Pump0/TankService"
			//% "Unavailable sensor, set another"
			defaultSecondaryText: qsTrId("settings_tank_unavailable_sensor")

			VeQuickItem {
				uid: root.pumpBindPrefix + "/AvailableTankServices"
				onValueChanged: {
					if (value === undefined) {
						return
					}
					const modelArray = Utils.jsonSettingsToModel(value)
					if (modelArray) {
						tankSensor.optionModel = modelArray
					} else {
						console.warn("Unable to parse data from", uid)
					}
				}
			}
		}

		ListSpinBox {
			//% "Start level"
			text: qsTrId("settings_tank_start_level")
			dataItem.uid: root.settingsBindPrefix + "/Settings/Pump0/StartValue"
			from: 0
			to: 100
			suffix: "%"
		}

		ListSpinBox {
			//% "Stop level"
			text: qsTrId("settings_tank_stop_level")
			dataItem.uid: root.settingsBindPrefix + "/Settings/Pump0/StopValue"
			from: 0
			to: 100
			suffix: "%"
		}
	}
}

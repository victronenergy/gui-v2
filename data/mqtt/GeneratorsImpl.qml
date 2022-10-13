/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.Velib
import Victron.VenusOS
import "/components/Utils.js" as Utils

QtObject {
	id: root

	property var veServiceIds
	onVeServiceIdsChanged: Qt.callLater(_getGenerators)

	property var _generators: []

	function _getGenerators() {
		let generatorIds = []
		for (let i = 0; i < veServiceIds.length; ++i) {
			let id = veServiceIds[i]
			if (id.startsWith("generator.")) {
				generatorIds.push(veServiceIds[i])
			}
		}

		if (Utils.arrayCompare(_generators, generatorIds) !== 0) {
			_generators = generatorIds
		}
	}

	property Instantiator generatorObjects: Instantiator {
		model: _generators
		delegate: QtObject {
			id: generator

			property string uid: modelData
			property string mqttUid: "mqtt/" + uid

			property int state: -1
			property int manualStartTimer
			property int runtime: -1
			property int runningBy: -1
			property int deviceInstance: -1

			function start(durationSecs) {
				_manualStartTimer.setValue(durationSecs)
				_manualStart.setValue(1)
			}

			function stop() {
				_manualStart.setValue(0)
			}

			property bool _valid: state >= 0
			on_ValidChanged: {
				const index = Utils.findIndex(Global.generators.model, generator)
				if (_valid && index < 0) {
					Global.generators.addGenerator(generator)
					if (!Global.generators.first) {
						Global.generators.first = generator
					}
				} else if (!_valid && index >= 0) {
					Global.generators.removeGenerator(index)
					if (Global.generators.first == generator) {
						Global.generators.first = null
					}
				}
			}

			property VeQuickItem _state: VeQuickItem {
				uid: mqttUid + "/State"
				onValueChanged: generator.state = value === undefined ? -1 : value
			}
			property VeQuickItem _manualStart: VeQuickItem {
				uid: mqttUid + "/ManualStart"
				// no valueChanged handler, only used to start/stop the generator
			}
			property VeQuickItem _manualStartTimer: VeQuickItem {
				uid: mqttUid + "/ManualStartTimer"
				onValueChanged: generator.manualStartTimer = value === undefined ? -1 : value
			}
			property VeQuickItem _runtime: VeQuickItem {
				uid: mqttUid + "/Runtime"
				onValueChanged: generator.runtime = value === undefined ? -1 : value
			}
			property VeQuickItem _runningBy: VeQuickItem {
				uid: mqttUid + "/RunningByConditionCode"
				onValueChanged: generator.runningBy = value === undefined ? -1 : value
			}
			property VeQuickItem _deviceInstance: VeQuickItem {
				uid: mqttUid + "/DeviceInstance"
				onValueChanged: {
					generator.deviceInstance = value === undefined ? -1 : value

					// Set first to the one with the lowest DeviceInstance
					if (!Global.generators.first && generator.deviceInstance >= 0) {
						Global.generators.first = generator
					}
					for (let i = 0; i < generatorObjects.count; ++i) {
						const currentGenerator = generatorObjects.objectAt(i)
						if (currentGenerator.deviceInstance >= 0
								&& currentGenerator.deviceInstance < Global.generators.first.deviceInstance) {
							rootGlobal.generatorsgenerator0 = currentGenerator
						}
					}
				}
			}
		}
	}
}

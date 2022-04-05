/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.Velib
import "/components/Utils.js" as Utils

Item {
	id: root

	enum GeneratorState {
		Stopped = 0,    // not 2 as documented?
		Running = 1,
		Error = 10
	}

	enum GeneratorRunningBy {
		NotRunning = 0,
		Manual = 1,
		TestRun = 2,
		LossOfCommunication = 3,
		Soc = 4,
		Acload = 5,
		BatteryCurrent = 6,
		BatteryVoltage = 7,
		InverterHighTemp = 8,
		InverterOverload = 9
	}

	property ListModel model: ListModel {}
	property QtObject generator0  // the first valid generator

	property var _generators: []

	function _getGenerators() {
		const childIds = veDBus.childIds

		let generatorIds = []
		for (let i = 0; i < childIds.length; ++i) {
			let id = childIds[i]
			if (id.startsWith("com.victronenergy.generator.")) {
				generatorIds.push(childIds[i])
			}
		}

		if (Utils.arrayCompare(_generators, generatorIds) !== 0) {
			_generators = generatorIds
		}
	}

	Connections {
		target: veDBus
		function onChildIdsChanged() { Qt.callLater(_getGenerators) }
		Component.onCompleted: _getGenerators()
	}

	Instantiator {
		model: _generators
		delegate: QtObject {
			id: generator

			property string uid: modelData
			property string dbusUid: "dbus/" + uid

			property int state: -1
			property int manualStartTimer
			property int runtime: -1
			property int runningBy: -1

			function start(durationSecs) {
				_manualStartTimer.setValue(durationSecs)
				_manualStart.setValue(1)
			}

			function stop() {
				_manualStart.setValue(0)
			}

			property bool _valid: state >= 0
			on_ValidChanged: {
				const index = Utils.findIndex(root.model, generator)
				if (_valid && index < 0) {
					root.model.append({ generator: generator })
					if (!root.generator0) {
						root.generator0 = generator
					}
				} else if (!_valid && index >= 0) {
					root.model.remove(index)
					if (root.generator0 == generator) {
						root.generator0 = null
					}
				}
			}

			property VeQuickItem _state: VeQuickItem {
				uid: dbusUid + "/State"
				onValueChanged: generator.state = value === undefined ? -1 : value
			}
			property VeQuickItem _manualStart: VeQuickItem {
				uid: dbusUid + "/ManualStart"
				// no valueChanged handler, only used to start/stop the generator
			}
			property VeQuickItem _manualStartTimer: VeQuickItem {
				uid: dbusUid + "/ManualStartTimer"
				onValueChanged: generator.manualStartTimer = value === undefined ? -1 : value
			}
			property VeQuickItem _runtime: VeQuickItem {
				uid: dbusUid + "/Runtime"
				onValueChanged: generator.runtime = value === undefined ? -1 : value
			}
			property VeQuickItem _runningBy: VeQuickItem {
				uid: dbusUid + "/RunningByConditionCode"
				onValueChanged: generator.runningBy = value === undefined ? -1 : value
			}
		}
	}
}

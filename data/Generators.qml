/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.Velib
import "/components/Utils.js" as Utils

Item {
	id: root

	enum GeneratorType {
		Relay = 0,
		FischerPanda = 1
	}

	enum GeneratorState {
		Running = 0,
		Stopped = 1,
		Error = 10
	}

	enum GeneratorRunningBy {
		Stopped = 0,
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
	property QtObject generator  // the first valid generator

	property var _generators: []

	function _getGenerators() {
		const childIds = veStartStop.childIds

		let generatorIds = []
		for (let i = 0; i < childIds.length; ++i) {
			let id = childIds[i]
			if ([ 'Generator0', 'Generator1', 'FischerPanda0' ].indexOf(id) !== -1) {
				generatorIds.push(id)
			}
		}

		if (Utils.arrayCompare(_generators, generatorIds) !== 0) {
			_generators = generatorIds
		}
	}

	VeQuickItem {
		id: veStartStop
		uid: "dbus/com.victronenergy.generator.startstop0"
	}

	Connections {
		target: veStartStop
		function onChildIdsChanged() { Qt.callLater(_getGenerators) }
		Component.onCompleted: _getGenerators()
	}

	Instantiator {
		model: _generators
		delegate: QtObject {
			id: generator

			property string uid: modelData
			property string dbusUid: veStartStop.uid + "/" + generator.uid

			property int state: -1
			property bool manualStart
			property int runtime: -1
			property int runningBy: -1

			property bool _valid: state >= 0
			on_ValidChanged: {
				const index = Utils.findIndex(root.model, generator)
				if (_valid && index < 0) {
					root.model.append({ generator: generator })
					if (!root.generator) {
						root.generator = generator
					}
				} else if (!_valid && index >= 0) {
					root.model.remove(index)
					if (root.generator == generator) {
						root.generator = null
					}
				}
			}

			property VeQuickItem _state: VeQuickItem {
				uid: dbusUid + "/State"
				onValueChanged: generator.state = value === undefined ? -1 : value
			}
			property VeQuickItem _manualStart: VeQuickItem {
				uid: dbusUid + "/ManualStart"
				onValueChanged: generator.manualStart = value === undefined ? false : value
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

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
		function onChildIdsChanged() { _getGenerators() }
		Component.onCompleted: _getGenerators()
	}

	Instantiator {
		model: _generators
		delegate: QtObject {
			id: generator

			property string uid: modelData
			property int state: -1
			property bool manualStart
			property int runtime: -1
			property int runningBy: -1

			property bool valid: state >= 0
			onValidChanged: {
				const index = Utils.findIndex(root.model, generator)
				if (valid && index < 0) {
					root.model.append({ generator: generator })
				} else if (!valid && index >= 0) {
					root.model.remove(index)
				}
			}

			property VeQuickItem _state: VeQuickItem {
				uid: veStartStop.uid + "/" + generator.uid + "/State"
				onValueChanged: generator.state = value === undefined ? -1 : value
			}
			property VeQuickItem _manualStart: VeQuickItem {
				uid: veStartStop.uid + "/" + generator.uid + "/ManualStart"
				onValueChanged: generator.manualStart = value === undefined ? false : value
			}
			property VeQuickItem _runtime: VeQuickItem {
				uid: veStartStop.uid + "/" + generator.uid + "/Runtime"
				onValueChanged: generator.runtime = value === undefined ? -1 : value
			}
			property VeQuickItem _runningBy: VeQuickItem {
				uid: veStartStop.uid + "/" + generator.uid + "/RunningByConditionCode"
				onValueChanged: generator.runningBy = value === undefined ? -1 : value
			}
		}
	}
}

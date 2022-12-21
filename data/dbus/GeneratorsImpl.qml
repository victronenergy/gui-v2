/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.Velib
import Victron.VenusOS
import "/components/Utils.js" as Utils

QtObject {
	id: root

	property Instantiator generatorObjects: Instantiator {
		model: VeQItemSortTableModel {
			dynamicSortFilter: true
			filterRole: VeQItemTableModel.UniqueIdRole
			filterRegExp: "^dbus/com\.victronenergy\.generator\."
			model: Global.dataServiceModel
		}

		delegate: QtObject {
			id: generator

			property string dbusUid: model.uid

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
				} else if (!_valid && index >= 0) {
					Global.generators.removeGenerator(index)
				}
				Global.generators.refreshFirstGenerator()
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
			property VeQuickItem _deviceInstance: VeQuickItem {
				uid: dbusUid + "/DeviceInstance"
				onValueChanged: {
					generator.deviceInstance = value === undefined ? -1 : value
					Global.generators.refreshFirstGenerator()
				}
			}
		}
	}
}

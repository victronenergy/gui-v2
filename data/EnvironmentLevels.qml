/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
//import Victron.Velib
import "/components/Utils.js" as Utils

Item {
	id: root

	property ListModel model: ListModel {}

	property var _environmentInputs: []

	function _getEnvironmentInputs() {
		const childIds = veDBus.childIds

		let environmentInputIds = []
		for (let i = 0; i < childIds.length; ++i) {
			let id = childIds[i]
			if (id.startsWith("com.victronenergy.temperature.")) {
				environmentInputIds.push(id)
			}
		}

		if (Utils.arrayCompare(_environmentInputs, environmentInputIds) !== 0) {
			_environmentInputs = environmentInputIds
		}
	}
/*
	Connections {
		target: veDBus
		function onChildIdsChanged() { Qt.callLater(_getEnvironmentInputs) }
		Component.onCompleted: _getEnvironmentInputs()
	}
*/
	Instantiator {
		model: root._environmentInputs

		delegate: QtObject {
			id: input

			property string customName: "" // _veCustomName.value || ""
			property string productName: "" // _veCustomName.value || ""
			property real temperature
			property real humidity

			property string _dbusUid: modelData
/*
			property var _veCustomName: VeQuickItem {
				uid: _dbusUid ? "dbus/" + _dbusUid + "/CustomName" : ""
			}
			property var _veProductName: VeQuickItem {
				uid: _dbusUid ? "dbus/" + _dbusUid + "/ProductName" : ""
			}
			property var _veTemperature: VeQuickItem {
				uid: _dbusUid ? "dbus/" + _dbusUid + "/Temperature" : ""
				onValueChanged: input.temperature = value === undefined ? NaN : value
			}
			property var _veHumidity: VeQuickItem {
				uid: _dbusUid ? "dbus/" + _dbusUid + "/Humidity" : ""
				onValueChanged: input.humidity = value === undefined ? NaN : value
			}
*/
			Component.onCompleted: {
				root.model.append({ input: input })
			}
			Component.onDestruction: {
				const index = Utils.findIndex(root.model, input)
				if (index >= 0) {
					root.model.remove(index)
				}
			}
		}
	}
}

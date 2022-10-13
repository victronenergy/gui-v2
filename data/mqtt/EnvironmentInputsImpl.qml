/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.Velib
import Victron.VenusOS
import "/components/Utils.js" as Utils

QtObject {
	id: root

	property var veServiceIds
	onVeServiceIdsChanged: Qt.callLater(_getEnvironmentInputs)

	property var _environmentInputs: []

	function _getEnvironmentInputs() {
		let environmentInputIds = []
		for (let i = 0; i < veServiceIds.length; ++i) {
			let id = veServiceIds[i]
			if (id.startsWith("temperature")) {
				environmentInputIds.push(id)
			}
		}

		if (Utils.arrayCompare(_environmentInputs, environmentInputIds) !== 0) {
			_environmentInputs = environmentInputIds
		}
	}

	property Instantiator inputObjects: Instantiator {
		model: root._environmentInputs

		delegate: QtObject {
			id: input

			property string customName: _veCustomName.value || ""
			property string productName: _veCustomName.value || ""
			property real temperature_celsius
			property real humidity

			property string _mqttUid: modelData

			property var _veCustomName: VeQuickItem {
				uid: _mqttUid ? "mqtt/" + _mqttUid + "/CustomName" : ""
			}
			property var _veProductName: VeQuickItem {
				uid: _mqttUid ? "mqtt/" + _mqttUid + "/ProductName" : ""
			}
			property var _veTemperature: VeQuickItem {
				uid: _mqttUid ? "mqtt/" + _mqttUid + "/Temperature" : ""
				onValueChanged: input.temperature_celsius = value === undefined ? NaN : value
			}
			property var _veHumidity: VeQuickItem {
				uid: _mqttUid ? "mqtt/" + _mqttUid + "/Humidity" : ""
				onValueChanged: input.humidity = value === undefined ? NaN : value
			}

			Component.onCompleted: {
				Global.environmentInputs.addInput(input)
			}
			Component.onDestruction: {
				const index = Utils.findIndex(Global.environmentInputs.model, input)
				if (index >= 0) {
					Global.environmentInputs.removeInput(index)
				}
			}
		}
	}
}

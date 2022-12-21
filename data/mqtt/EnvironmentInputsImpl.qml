/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.Velib
import Victron.VenusOS
import "/components/Utils.js" as Utils

QtObject {
	id: root

	property Instantiator inputObjects: Instantiator {
		model: VeQItemTableModel {
			uids: ["mqtt/temperature"]
			flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
		}

		delegate: QtObject {
			id: input

			property string customName: _veCustomName.value || ""
			property string productName: _veCustomName.value || ""
			property real temperature_celsius
			property real humidity

			property string _mqttUid: model.uid

			property var _veCustomName: VeQuickItem {
				uid: _mqttUid + "/CustomName"
			}
			property var _veProductName: VeQuickItem {
				uid: _mqttUid + "/ProductName"
			}
			property var _veTemperature: VeQuickItem {
				uid: _mqttUid + "/Temperature"
				onValueChanged: input.temperature_celsius = value === undefined ? NaN : value
			}
			property var _veHumidity: VeQuickItem {
				uid: _mqttUid + "/Humidity"
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

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
		model: VeQItemSortTableModel {
			dynamicSortFilter: true
			filterRole: VeQItemTableModel.UniqueIdRole
			filterRegExp: "^dbus/com\.victronenergy\.temperature\."
			model: Global.dataServiceModel
		}

		delegate: QtObject {
			id: input

			property string customName: _veCustomName.value || ""
			property string productName: _veCustomName.value || ""
			property real temperature_celsius
			property real humidity

			property string _dbusUid: model.uid

			property var _veCustomName: VeQuickItem {
				uid: _dbusUid + "/CustomName"
			}
			property var _veProductName: VeQuickItem {
				uid: _dbusUid + "/ProductName"
			}
			property var _veTemperature: VeQuickItem {
				uid: _dbusUid + "/Temperature"
				onValueChanged: input.temperature_celsius = value === undefined ? NaN : value
			}
			property var _veHumidity: VeQuickItem {
				uid: _dbusUid + "/Humidity"
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

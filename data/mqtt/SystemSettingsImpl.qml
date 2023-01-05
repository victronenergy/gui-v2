/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil

QtObject {
	id: root

	property Connections briefSettingsConn: Connections {
		target: Global.systemSettings.briefView

		function onSetGaugeRequested(index, value) {
			const obj = briefViewLevels.objectAt(index)
			if (obj) {
				obj.setValue(value === VenusOS.Tank_Type_Battery ? -1 : value)
			} else {
				console.warn("No gauge at index", index)
			}
		}
	}

	property Instantiator briefViewLevels: Instantiator {
		model: 4
		delegate: VeQuickItem {
			function _update() {
				if (value !== undefined) {
					const v = value === -1 ? VenusOS.Tank_Type_Battery : value
					Global.systemSettings.briefView.setGauge(model.index, v)
				}
			}
			uid: "mqtt/settings/0/Settings/Gui/BriefView/Level/" + (model.index + 1)
			Component.onCompleted: _update()
			onValueChanged: _update()
		}
	}
}

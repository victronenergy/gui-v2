/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import Victron.Velib

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

	property VeQuickItem accessLevel: VeQuickItem {
		 uid: "mqtt/settings/0/Settings/System/AccessLevel"
	}

	property VeQuickItem demoMode: VeQuickItem {
		uid: "mqtt/settings/0/Settings/Gui/DemoMode"
	}

	property VeQuickItem colorScheme: VeQuickItem {
		uid: "mqtt/settings/0/Settings/Gui/ColorScheme"
		 onValueChanged: {
			 if (value === Theme.Dark) {
				Theme.load(Theme.screenSize, Theme.Dark)
			 } else if (value === Theme.Light) {
				Theme.load(Theme.screenSize, Theme.Light)
			 }
		 }
	}

	property VeQuickItem energyUnit: VeQuickItem {
		uid: "mqtt/settings/0/Settings/Gui/Units/Energy"
	}

	property VeQuickItem temperatureUnit: VeQuickItem {
		uid: "mqtt/settings/0/Settings/Gui/Units/Temperature"
	}

	property VeQuickItem volumeUnit: VeQuickItem {
		uid: "mqtt/settings/0/Settings/Gui/Units/Volume"
	}

	property VeQuickItem showPercentages: VeQuickItem {
		uid: "mqtt/settings/0/Settings/Gui/BriefView/ShowPercentages"
	}

	Component.onCompleted: Global.systemSettings.setDataSource(root)
}

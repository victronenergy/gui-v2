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
			uid: "dbus/com.victronenergy.settings/Settings/Gui/BriefView/Level/" + (model.index + 1)
			Component.onCompleted: _update()
			onValueChanged: _update()
		}
	}

	property DataPoint accessLevel: DataPoint {
		 source: "com.victronenergy.settings/Settings/System/AccessLevel"
	}

	property DataPoint demoMode: DataPoint {
		 source: "com.victronenergy.settings/Settings/Gui/DemoMode"
	}

	property DataPoint colorScheme: DataPoint {
		 source: "com.victronenergy.settings/Settings/Gui/ColorScheme"
		 onValueChanged: {
			 if (value === Theme.Dark) {
				Theme.load(Theme.screenSize, Theme.Dark)
			 } else if (value === Theme.Light) {
				Theme.load(Theme.screenSize, Theme.Light)
			 }
		 }
	}

	property DataPoint energyUnit: DataPoint {
		 source: "com.victronenergy.settings/Settings/Gui/Units/Energy"
	}

	property DataPoint temperatureUnit: DataPoint {
		 source: "com.victronenergy.settings/Settings/Gui/Units/Temperature"
	}

	property DataPoint volumeUnit: DataPoint {
		source: "com.victronenergy.settings/Settings/Gui/Units/Volume"
	}

	property DataPoint showPercentages: DataPoint {
		 source: "com.victronenergy.settings/Settings/Gui/BriefView/ShowPercentages"
	}

	Component.onCompleted: Global.systemSettings.setDataSource(root)
}

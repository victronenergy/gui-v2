/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import Victron.Velib

QtObject {
	id: root

	property var veSettings

	property Connections sysSettingsConn: Connections {
		target: Global.systemSettings

		function onSetAccessLevelRequested(accessLevel) {
			veAccessLevel.setValue(accessLevel)
		}

		function onSetColorSchemeRequested(colorScheme) {
			Theme.load(Theme.screenSize, colorScheme)
			veColorScheme.setValue(colorScheme)
		}

		// Don't connect to onSetDemoModeRequested() here, it is handled from DataPoint in main.qml.
	}

	property Connections briefSettingsConn: Connections {
		target: Global.systemSettings.briefView

		function onSetGaugeRequested(index, value) {
			const obj = briefViewLevels.objectAt(index)
			if (obj) {
				obj.setValue(value === VenusOS.Tank_Type_Battery ? -1 : value)
				Global.systemSettings.briefView.setGauge(index, value)
			} else {
				console.warn("No gauge at index", index)
			}
		}

		function onSetShowPercentagesRequested(value) {
			veShowPercentages.setValue(value ? 1 : 0)
			Global.systemSettings.briefView.showPercentages = value
		}
	}

	property Instantiator briefViewLevels: Instantiator {
		model: 4
		delegate: VeQuickItem {
			uid: veSettings.childUId("/Settings/Gui/BriefView/Level/" + (model.index + 1))

			onValueChanged: {
				if (value !== undefined) {
					const v = value === -1 ? VenusOS.Tank_Type_Battery : value
					Global.systemSettings.briefView.setGauge(model.index, v)
				}
			}
		}
	}

	property VeQuickItem veShowPercentages: VeQuickItem {
		uid: veSettings.childUId("/Settings/Gui/BriefView/ShowPercentages")
		onValueChanged: if (value !== undefined) Global.systemSettings.briefView.showPercentages = value === 1
	}

	property VeQuickItem veAccessLevel: VeQuickItem {
		uid: veSettings.childUId("/Settings/System/AccessLevel")
		onValueChanged: if (value !== undefined) Global.systemSettings.accessLevel = value
	}

	property VeQuickItem veColorScheme: VeQuickItem {
		uid: veSettings.childUId("/Settings/Gui/ColorScheme")
		onValueChanged: {
			if (value !== undefined) {
				if (value === Theme.Dark) {
					Theme.load(Theme.screenSize, Theme.Dark)
				} else if (value === Theme.Light) {
					Theme.load(Theme.screenSize, Theme.Light)
				}
				Global.systemSettings.colorScheme = value
			}
		}
	}
}

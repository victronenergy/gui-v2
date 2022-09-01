/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import Victron.Velib

QtObject {
	id: root

	property Connections sysSettingsConn: Connections {
		target: Global.systemSettings

		// Don't connect to onSetDemoModeRequested() here, it is handled from DataPoint in main.qml.

		function onSetAccessLevelRequested(accessLevel) {
			veAccessLevel.setValue(accessLevel)
		}

		function onSetColorSchemeRequested(colorScheme) {
			Theme.load(Theme.screenSize, colorScheme)
			veColorScheme.setValue(colorScheme)
		}

		function onSetEnergyUnitRequested(energyUnit) {
			veEnergyUnit.setValue(energyUnit)
			Global.systemSettings.energyUnit = energyUnit
		}

		function onSetTemperatureUnitRequested(temperatureUnit) {
			veTemperatureUnit.setValue(temperatureUnit)
			Global.systemSettings.temperatureUnit = temperatureUnit
		}

		function onSetVolumeUnitRequested(volumeUnit) {
			veVolumeUnit.setValue(volumeUnit)
			Global.systemSettings.volumeUnit = volumeUnit
		}
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
			uid: "dbus/com.victronenergy.settings/Settings/Gui/BriefView/Level/" + (model.index + 1)

			Component.onCompleted: valueChanged(this, value)
			onValueChanged: {
				if (value !== undefined) {
					const v = value === -1 ? VenusOS.Tank_Type_Battery : value
					Global.systemSettings.briefView.setGauge(model.index, v)
				}
			}
		}
	}

	property VeQuickItem veShowPercentages: VeQuickItem {
		uid: "dbus/com.victronenergy.settings/Settings/Gui/BriefView/ShowPercentages"
		Component.onCompleted: valueChanged(this, value)
		onValueChanged: if (value !== undefined) Global.systemSettings.briefView.showPercentages = value === 1
	}

	property VeQuickItem veAccessLevel: VeQuickItem {
		uid: "dbus/com.victronenergy.settings/Settings/System/AccessLevel"
		Component.onCompleted: valueChanged(this, value)
		onValueChanged: if (value !== undefined) Global.systemSettings.accessLevel = value
	}

	property VeQuickItem veColorScheme: VeQuickItem {
		uid: "dbus/com.victronenergy.settings/Settings/Gui/ColorScheme"
		Component.onCompleted: valueChanged(this, value)
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

	property VeQuickItem veEnergyUnit: VeQuickItem {
		uid: "dbus/com.victronenergy.settings/Settings/Gui/Units/Energy"
		Component.onCompleted: valueChanged(this, value)
		onValueChanged: if (value !== undefined) Global.systemSettings.energyUnit = value
	}

	property VeQuickItem veTemperatureUnit: VeQuickItem {
		uid: "dbus/com.victronenergy.settings/Settings/Gui/Units/Temperature"
		Component.onCompleted: valueChanged(this, value)
		onValueChanged: if (value !== undefined) Global.systemSettings.temperatureUnit = value
	}

	property VeQuickItem veVolumeUnit: VeQuickItem {
		uid: "dbus/com.victronenergy.settings/Settings/Gui/Units/Volume"
		Component.onCompleted: valueChanged(this, value)
		onValueChanged: if (value !== undefined) Global.systemSettings.volumeUnit = value
	}
}

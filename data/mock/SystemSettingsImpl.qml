/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	Component.onCompleted: {
		Global.systemSettings.accessLevel = VenusOS.User_AccessType_User
		Global.systemSettings.demoMode = 1
		Global.systemSettings.colorScheme = Theme.Dark
		Global.systemSettings.energyUnit = VenusOS.Units_Energy_Watt
		Global.systemSettings.temperatureUnit = VenusOS.Units_Temperature_Celsius
		Global.systemSettings.volumeUnit = VenusOS.Units_Volume_CubicMeter

		Global.systemSettings.briefView.showPercentages = false
	}

	property Connections sysSettingsConn: Connections {
		target: Global.systemSettings

		// Don't connect to onSetDemoModeRequested() here, it is handled from DataPoint in main.qml.

		function onSetAccessLevelRequested(accessLevel) {
			Global.systemSettings.accessLevel = accessLevel
		}

		function onSetColorSchemeRequested(colorScheme) {
			Theme.load(Theme.screenSize, colorScheme)
			Global.systemSettings.colorScheme = colorScheme
		}

		function onSetEnergyUnitRequested(energyUnit) {
			Global.systemSettings.energyUnit = energyUnit
		}

		function onSetTemperatureUnitRequested(temperatureUnit) {
			Global.systemSettings.temperatureUnit = temperatureUnit
		}

		function onSetVolumeUnitRequested(volumeUnit) {
			Global.systemSettings.volumeUnit = volumeUnit
		}
	}

	property Connections briefSettingsConn: Connections {
		target: Global.systemSettings.briefView

		function onSetGaugeRequested(index, value) {
			Global.systemSettings.briefView.setGauge(index, value)
		}

		function onSetShowPercentagesRequested(value) {
			Global.systemSettings.briefView.showPercentages = value
		}
	}

}

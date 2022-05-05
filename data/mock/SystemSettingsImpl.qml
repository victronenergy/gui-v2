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
		Global.systemSettings.displayMode = Theme.Dark

		Global.systemSettings.briefView.showPercentages = false
	}

	property Connections sysSettingsConn: Connections {
		target: Global.systemSettings

		function onSetAccessLevelRequested(accessLevel) {
			Global.systemSettings.accessLevel = accessLevel
		}

		function onSetDisplayModeRequested(displayMode) {
			Theme.load(Theme.screenSize, displayMode)
			Global.systemSettings.displayMode = displayMode
		}

		// Don't connect to onSetDemoModeRequested() here, it is handled from DataPoint in main.qml.
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

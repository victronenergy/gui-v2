/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	Component.onCompleted: {
		Global.systemSettings.accessLevel.setValue(VenusOS.User_AccessType_User)
		Global.systemSettings.demoMode.setValue(VenusOS.SystemSettings_DemoModeActive)
		Global.systemSettings.colorScheme.setValue(Theme.Dark)
		Global.systemSettings.energyUnit.setValue(VenusOS.Units_Energy_Watt)
		Global.systemSettings.temperatureUnit.setValue(VenusOS.Units_Temperature_Celsius)
		Global.systemSettings.volumeUnit.setValue(VenusOS.Units_Volume_CubicMeter)
		Global.systemSettings.briefView.showPercentages.setValue(false)
	}

	property Connections briefSettingsConn: Connections {
		target: Global.systemSettings.briefView

		function onSetGaugeRequested(index, value) {
			Global.systemSettings.briefView.setGauge(index, value)
		}
	}

}

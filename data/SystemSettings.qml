/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	property int accessLevel
	property int demoMode
	property int colorScheme

	signal setAccessLevelRequested(accessLevel: int)
	signal setDemoModeRequested(demoMode: int)
	signal setColorSchemeRequested(colorScheme: int)

	property QtObject briefView: QtObject {
		// Default settings
		property ListModel gauges: ListModel {
			ListElement { value: VenusOS.Tank_Type_Battery }
			ListElement { value: VenusOS.Tank_Type_Fuel }
			ListElement { value: VenusOS.Tank_Type_FreshWater }
			ListElement { value: VenusOS.Tank_Type_BlackWater }
		}
		property bool showPercentages

		signal setGaugeRequested(index: int, value: var)
		signal setShowPercentagesRequested(value: bool)

		function setGauge(index, value) {
			gauges.setProperty(index, "value", value)
		}
	}

	function reset() {
		// no-op
	}

	Component.onCompleted: Global.systemSettings = root
}

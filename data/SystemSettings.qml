/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

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

	property QtObject briefView: QtObject {
		// Default settings
		property ListModel gauges: ListModel {
			ListElement { value: VenusOS.Tank_Type_Battery }
			ListElement { value: VenusOS.Tank_Type_Fuel }
			ListElement { value: VenusOS.Tank_Type_FreshWater }
			ListElement { value: VenusOS.Tank_Type_BlackWater }
		}

		property DataPoint showPercentages: DataPoint {
			 source: "com.victronenergy.settings/Settings/Gui/BriefView/ShowPercentages"
		}

		signal setGaugeRequested(index: int, value: var)

		function setGauge(index, value) {
			gauges.setProperty(index, "value", value)
		}
	}

	function reset() {
		// no-op
	}

	Component.onCompleted: Global.systemSettings = root
}

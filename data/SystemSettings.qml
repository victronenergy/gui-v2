/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	function canAccess(level) {
		return accessLevel.valid && accessLevel.value >= level
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

	property QtObject temperatureUnit: QtObject {
		// translate /System/Units/Temperature from string to enum value
		readonly property var value: _unitDataPoint.value === "fahrenheit"
				? VenusOS.Units_Temperature_Fahrenheit
				: VenusOS.Units_Temperature_Celsius

		function setValue(v) {
			if (v === VenusOS.Units_Temperature_Celsius) {
				_unitDataPoint.setValue("celsius")
			} else if (v === VenusOS.Units_Temperature_Fahrenheit) {
				_unitDataPoint.setValue("fahrenheit")
			} else {
				console.warn("Unsupported temperature unit:", v)
			}
		}

		readonly property DataPoint _unitDataPoint: DataPoint {
			id: _unitDataPoint
			source: "com.victronenergy.settings/Settings/System/Units/Temperature"
		}
	}

	property DataPoint volumeUnit: DataPoint {
		source: "com.victronenergy.settings/Settings/System/VolumeUnit"
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

	// TODO get canBusStats from venus-platform when available, as equivalent of vePlatform.canBusStats(gateway)
	property var _canBusStats: ({})
	function canBusStatistics(gateway) {
		return _canBusStats[gateway] || ""
	}

	function reset() {
		// no-op
	}

	Component.onCompleted: Global.systemSettings = root
}

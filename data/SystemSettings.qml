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
		property QtObject centralGauges: QtObject {
			property var value: []

			function setValue(gaugeTypesArray) {
				if (gaugeTypesArray.length !== _savedLevels.count) {
					console.warn("Cannot change central gauges, got gauge array length",
							gaugeTypesArray.length, "expected", _savedLevels.count)
					return
				}
				for (let i = 0; i < _savedLevels.count; ++i) {
					const obj = _savedLevels.objectAt(i)
					if (obj.value !== gaugeTypesArray[i]) {
						obj.setValue(gaugeTypesArray[i])
					}
				}
			}

			function _refresh() {
				let levels = []
				for (let i = 0; i < _savedLevels.count; ++i) {
					const obj = _savedLevels.objectAt(i)
					levels.push(obj && obj.value !== undefined ? obj.value : VenusOS.Tank_Type_Battery)
				}
				value = levels
			}

			property Instantiator _savedLevels: Instantiator {
				model: Theme.geometry.briefPage.centerGauge.maximumGaugeCount
				delegate: DataPoint {
					source: "com.victronenergy.settings/Settings/Gui/BriefView/Level/" + (model.index + 1)
					onValueChanged: {
						if (value !== undefined) {
							Qt.callLater(briefView.centralGauges._refresh)
						}
					}
				}
			}
		}

		property DataPoint showPercentages: DataPoint {
			 source: "com.victronenergy.settings/Settings/Gui/BriefView/ShowPercentages"
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

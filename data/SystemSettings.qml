/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "/components/Units.js" as Units

QtObject {
	id: root

	function canAccess(level) {
		return accessLevel.valid && accessLevel.value >= level
	}

	function convertTemperature(celsius_value) {
		return temperatureUnit.value === VenusOS.Units_Temperature_Celsius
				? celsius_value
				: Units.celsiusToFahrenheit(celsius_value)
	}

	property DataPoint accessLevel: DataPoint {
		 source: "com.victronenergy.settings/Settings/System/AccessLevel"
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

	property QtObject electricalQuantity: QtObject {
		// Values for /Settings/Gui/ElectricalPowerIndicator: 0 = watts, 1 = amps
		readonly property var value: _electricalQuantityDataPoint.value === 1 ? VenusOS.Units_Amp : VenusOS.Units_Watt

		function setValue(v) {
			if (v === VenusOS.Units_Watt) {
				_electricalQuantityDataPoint.setValue(0)
			} else if (v === VenusOS.Units_Amp) {
				_electricalQuantityDataPoint.setValue(1)
			} else {
				console.warn("Unsupported electrical quantity:", v)
			}
		}

		readonly property DataPoint _electricalQuantityDataPoint: DataPoint {
			id: _electricalQuantityDataPoint
			source: "com.victronenergy.settings/Settings/Gui/ElectricalPowerIndicator"
		}
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
					source: "com.victronenergy.settings/Settings/Gui/BriefView/Level/" + model.index
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

	property DataPoint time: DataPoint {
		source: "com.victronenergy.platform/Device/Time"
		onValueChanged: {
			if (value !== undefined) {
				ClockTime.setClockTime(value)
			}
		}

		// Periodically ensure system time is up-to-date.
		property Timer _updateTime: Timer {
			interval: 60000
			repeat: true
			triggeredOnStart: true
			running: BackendConnection.applicationVisible
			onTriggered: root.time.refresh()
		}
	}

	property DataPoint timeZone: DataPoint {
		source: "com.victronenergy.settings/Settings/System/TimeZone"
		onValueChanged: {
			if (value !== undefined) {
				ClockTime.systemTimeZone = value
				root.time.refresh() // ensure the time value is the latest one from the server
			}
		}
	}

	property DataPoint language: DataPoint {
		source: "com.victronenergy.settings/Settings/Gui/Language"
		onValueChanged: {
			if (value !== undefined && !Global.changingLanguage
					&& value != Language.toCode(Language.current)) {
				Global.changingLanguage = true
				Language.setCurrentLanguageCode(value)
				Qt.callLater(Global.main.retranslateUi)
			}
		}
	}

	function reset() {
		// no-op
	}

	Component.onCompleted: Global.systemSettings = root
}

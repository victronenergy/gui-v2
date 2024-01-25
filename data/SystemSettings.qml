/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	readonly property string serviceUid: BackendConnection.serviceUidForType("settings")

	property int electricalQuantity: VenusOS.Units_None
	property int temperatureUnit: VenusOS.Units_None
	property string temperatureUnitSuffix
	property int volumeUnit: VenusOS.Units_None

	function canAccess(level) {
		return accessLevel.isValid && accessLevel.value >= level
	}

	function setElectricalQuantity(value) {
		switch (value) {
			case VenusOS.Units_Watt:
				_electricalQuantity.setValue(_electricalQuantity.ve_watt)
				break
			case VenusOS.Units_Amp:
				_electricalQuantity.setValue(_electricalQuantity.ve_amp)
				break
			default:
				console.warn("setElectricalQuantity() unknown value:", value)
				break
		}
	}

	function setTemperatureUnit(value) {
		switch (value) {
			case VenusOS.Units_Temperature_Celsius:
				_temperatureUnit.setValue(_temperatureUnit.ve_celsius)
				break
			case VenusOS.Units_Temperature_Fahrenheit:
				_temperatureUnit.setValue(_temperatureUnit.ve_fahrenheit)
				break
			default:
				// Other units are not supported, including kelvin
				console.warn("setTemperatureUnit() unknown value:", value)
				break
		}
	}

	function setVolumeUnit(value) {
		switch (value) {
			case VenusOS.Units_Volume_CubicMeter:
				_volumeUnit.setValue(_volumeUnit.ve_cm3)
				break
			case VenusOS.Units_Volume_Liter:
				_volumeUnit.setValue(_volumeUnit.ve_liter)
				break
			case VenusOS.Units_Volume_GallonImperial:
				_volumeUnit.setValue(_volumeUnit.ve_gallonImperial)
				break
			case VenusOS.Units_Volume_GallonUS:
				_volumeUnit.setValue(_volumeUnit.ve_gallonUs)
				break
			default:
				console.warn("setVolumeUnit() unknown value:", value)
				break
		}
	}

	function convertFromCelsius(celsius_value) {
		return Units.convert(celsius_value, VenusOS.Units_Temperature_Celsius, temperatureUnit)
	}

	function networkStatusToText(status) {
		switch (status) {
		case VenusOS.Link_NetworkStatus_Slave:
			//: Network status: Slave
			//% "Slave"
			return qsTrId("systemsettings_networkstatus_slave")
		case VenusOS.Link_NetworkStatus_GroupMaster:
			//: Network status: Group Master
			//% "Group Master"
			return qsTrId("systemsettings_networkstatus_group_master")
		case VenusOS.Link_NetworkStatus_InstanceMaster:
			//: Network status: Instance Master
			//% "Instance Master"
			return qsTrId("systemsettings_networkstatus_instance_master")
		case VenusOS.Link_NetworkStatus_GroupAndInstanceMaster:
			//: Network status: Group & Instance Master
			//% "Group & Instance Master"
			return qsTrId("systemsettings_networkstatus_group_and_instance_master")
		case VenusOS.Link_NetworkStatus_Standalone:
			//: Network status: Standalone
			//% "Standalone"
			return qsTrId("systemsettings_networkstatus_standalone")
		case VenusOS.Link_NetworkStatus_StandaloneAndGroupMaster:
			//: Network status: Standalone & Group Master
			//% "Standalone & Group Master"
			return qsTrId("systemsettings_networkstatus_standalone_and_group_master")
		default:
			return ""
		}
	}

	property VeQuickItem accessLevel: VeQuickItem {
		 uid: root.serviceUid + "/Settings/System/AccessLevel"
	}

	property VeQuickItem colorScheme: VeQuickItem {
		 uid: root.serviceUid + "/Settings/Gui/ColorScheme"
		 onValueChanged: {
			 if (value === Theme.Dark) {
				 Theme.colorScheme = Theme.Dark
			 } else if (value === Theme.Light) {
				 Theme.colorScheme = Theme.Light
			 }
		 }
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
				model: Theme.geometry_briefPage_centerGauge_maximumGaugeCount
				delegate: VeQuickItem {
					uid: root.serviceUid + "/Settings/Gui/BriefView/Level/" + model.index
					onValueChanged: {
						if (value !== undefined) {
							Qt.callLater(briefView.centralGauges._refresh)
						}
					}
				}
			}
		}

		property VeQuickItem showPercentages: VeQuickItem {
			 uid: root.serviceUid + "/Settings/Gui/BriefView/ShowPercentages"
		}
	}

	property VeQuickItem time: VeQuickItem {
		uid: Global.venusPlatform.serviceUid + "/Device/Time"
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
			onTriggered: root.time.getValue(true)   // force value refresh
		}
	}

	property VeQuickItem timeZone: VeQuickItem {
		uid: root.serviceUid + "/Settings/System/TimeZone"
		onValueChanged: {
			if (value !== undefined) {
				ClockTime.systemTimeZone = value
				root.time.getValue(true)    // ensure the time value is the latest one from the server
			}
		}
	}

	property VeQuickItem language: VeQuickItem {
		uid: root.serviceUid + "/Settings/Gui/Language"
		onValueChanged: {
			if (value !== undefined && !Global.changingLanguage
					&& value != Language.toCode(Language.current)) {
				Global.changingLanguage = true
				Language.setCurrentLanguageCode(value)
				Qt.callLater(Global.main.retranslateUi)
			}
		}
	}

	property VeQuickItem _electricalQuantity: VeQuickItem {
		readonly property int ve_watt: 0
		readonly property int ve_amp: 1

		uid: root.serviceUid + "/Settings/Gui/ElectricalPowerIndicator"
		onValueChanged: {
			switch (value) {
			case ve_watt:
				root.electricalQuantity = VenusOS.Units_Watt
				break
			case ve_amp:
				root.electricalQuantity = VenusOS.Units_Amp
				break
			default:
				console.warn("Cannot load electrical quantity,", uid, "has unsupported value:", value, "default to watts")
				root.electricalQuantity = VenusOS.Units_Watt
				break
			}
		}
	}

	property VeQuickItem _temperatureUnit: VeQuickItem {
		readonly property string ve_celsius: "celsius"
		readonly property string ve_fahrenheit: "fahrenheit"

		uid: root.serviceUid + "/Settings/System/Units/Temperature"
		onValueChanged: {
			switch (value) {
			case ve_celsius:
				root.temperatureUnit = VenusOS.Units_Temperature_Celsius
				root.temperatureUnitSuffix = "C"
				break
			case ve_fahrenheit:
				root.temperatureUnit = VenusOS.Units_Temperature_Fahrenheit
				root.temperatureUnitSuffix = "F"
				break
			default:
				console.warn("Cannot load temperature unit,", uid, "has unsupported value:", value, "default to celsius")
				root.temperatureUnit = VenusOS.Units_Temperature_Celsius
				root.temperatureUnitSuffix = "C"
				break
			}
		}
	}

	property VeQuickItem _volumeUnit: VeQuickItem {
		readonly property int ve_cm3: 0
		readonly property int ve_liter: 1
		readonly property int ve_gallonImperial: 2
		readonly property int ve_gallonUs: 3

		uid: root.serviceUid + "/Settings/System/VolumeUnit"
		onValueChanged: {
			switch (value) {
			case ve_cm3:
				root.volumeUnit = VenusOS.Units_Volume_CubicMeter
				break
			case ve_liter:
				root.volumeUnit = VenusOS.Units_Volume_Liter
				break
			case ve_gallonImperial:
				root.volumeUnit = VenusOS.Units_Volume_GallonImperial
				break
			case ve_gallonUs:
				root.volumeUnit = VenusOS.Units_Volume_GallonUS
				break
			default:
				console.warn("Cannot load volume unit,", uid, "has unsupported value:", value, "default to m3")
				root.volumeUnit = VenusOS.Units_Volume_CubicMeter
				break
			}
		}
	}

	function reset() {
		// no-op
	}

	Component.onCompleted: Global.systemSettings = root
}

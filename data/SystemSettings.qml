/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	readonly property string serviceUid: BackendConnection.serviceUidForType("settings")
	readonly property bool needsOnboarding: _onboardingState.needsOnboarding
			// It's hard to skip onboarding without touch, so disable onboarding if touch is disabled.
			&& _touchEnabled.valid && _touchEnabled.value !== 0

	property int electricalQuantity: VenusOS.Units_None
	property int temperatureUnit: VenusOS.Units_None
	property string temperatureUnitSuffix
	property int volumeUnit: VenusOS.Units_None
	property int altitudeUnit: VenusOS.Units_None
	readonly property StartPageConfiguration startPageConfiguration: StartPageConfiguration {
		systemSettingsUid: root.serviceUid
	}
	readonly property int speedUnit: {
		switch (_speedUnit.value) {
		case "km/h":
			return VenusOS.Units_Speed_KilometersPerHour
		case "m/s":
			return VenusOS.Units_Speed_MetresPerSecond
		case "kt":
			return VenusOS.Units_Speed_Knots
		case "mph":
			return VenusOS.Units_Speed_MilesPerHour
		default:
			return VenusOS.Units_None
		}
	}

	function canAccess(level) {
		return accessLevel.valid && accessLevel.value >= level
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

	function setOnboardingDone() {
		_onboardingState.setDoneFlag()
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
		property var centralGauges: []

		readonly property VeQuickItem unit: VeQuickItem {
			 uid: root.serviceUid + "/Settings/Gui/BriefView/Unit"
		}

		function _refreshCentralGauges() {
			let levels = []
			for (let i = 0; i < Theme.geometry_briefPage_centerGauge_maximumGaugeCount; ++i) {
				const obj = _savedLevels.objectAt(i)

				// Each level value is an integer or a string, to indicate the data to be shown
				// for that gauge level:
				// - string: the tank id (to show the level for that particular tank) or a
				// battery id (to show the SOC for that battery from the system /Batteries list)
				// - integer: Tank_Type_Battery (to show the system battery), or a tank type to
				// show the aggregate level for all tanks of that type.
				if (!obj || !obj.valid || obj.value === "") {
					continue
				}
				let centerGaugeType
				const tankType = parseInt(obj.value)
				if (isNaN(tankType)) {
					centerGaugeType = BackendConnection.portableIdInfo(obj.value).type === "tank"
							? VenusOS.BriefView_CentralGauge_TankId
							: VenusOS.BriefView_CentralGauge_BatteryId
				} else if (tankType === VenusOS.Tank_Type_None) {
					centerGaugeType = VenusOS.BriefView_CentralGauge_None
				} else if (tankType === VenusOS.Tank_Type_Battery) {
					centerGaugeType = VenusOS.BriefView_CentralGauge_SystemBattery
				} else {
					centerGaugeType = VenusOS.BriefView_CentralGauge_TankAggregate
				}
				levels.push({ centerGaugeType: centerGaugeType, value: obj.value })
			}
			centralGauges = levels
		}

		readonly property Instantiator _savedLevels: Instantiator {
			model: VeQItemTableModel {
				uids: [ root.serviceUid + "/Settings/Gui2/BriefView/Level" ]
				flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
			}
			delegate: VeQuickItem {
				uid: model.uid
				onValueChanged: Qt.callLater(root.briefView._refreshCentralGauges)
			}
		}
	}

	property VeQuickItem time: VeQuickItem {
		uid: Global.venusPlatform.serviceUid + "/Device/Time"
		onValueChanged: {
			if (value !== undefined) {
				ClockTime.clockTime = value
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
				Date.timeZoneUpdated()      // Inform the JS engine that the system tz has changed.
				root.time.getValue(true)    // ensure the time value is the latest one from the server
			}
		}
	}

	property VeQuickItem language: VeQuickItem {
		id: languageChangeListener
		property bool changingLanguage: false
		uid: root.serviceUid + "/Settings/Gui/Language"
		onValueChanged: {
			if (!languageChangeListener.changingLanguage
					&& value !== undefined
					&& value != Language.toCode(Language.current)) {
				languageChangeListener.changingLanguage = true
				if (!Language.setCurrentLanguageCode(value)) {
					// failed.  set the settings value back to the previous one.
					setValue(Language.toCode(Language.current))
				}
				Qt.callLater(function() { languageChangeListener.changingLanguage = false })
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
				root.temperatureUnitSuffix = "°C"
				break
			case ve_fahrenheit:
				root.temperatureUnit = VenusOS.Units_Temperature_Fahrenheit
				root.temperatureUnitSuffix = "°F"
				break
			default:
				console.warn("Cannot load temperature unit,", uid, "has unsupported value:", value, "default to celsius")
				root.temperatureUnit = VenusOS.Units_Temperature_Celsius
				root.temperatureUnitSuffix = "°C"
				break
			}
		}
	}

	property VeQuickItem _speedUnit: VeQuickItem {
		uid: Global.systemSettings.serviceUid + "/Settings/Gps/SpeedUnit"
	}

	property VeQuickItem _altitudeUnit: VeQuickItem {
		readonly property string ve_meter: "meter"
		readonly property string ve_foot: "foot"

		uid: root.serviceUid + "/Settings/System/Units/Altitude"
		onValueChanged: {
			switch (value) {
			case ve_meter:
				root.altitudeUnit = VenusOS.Units_Altitude_Meter
				break
			case ve_foot:
				root.altitudeUnit = VenusOS.Units_Altitude_Foot
				break
			default:
				console.warn("Cannot load altitude unit,", uid, "has unsupported value:", value, "default to meter")
				root.altitudeUnit = VenusOS.Units_Altitude_Meter
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

	readonly property VeQuickItem _onboardingState: VeQuickItem {
		readonly property bool needsOnboarding: !_forceOnboardingDone
			&& valid
			&& ( (Qt.platform.os === "wasm" && !(value & VenusOS.OnboardingState_DoneWasm))
				|| (Qt.platform.os !== "wasm" && !(value & VenusOS.OnboardingState_DoneNative)) )

		property bool _forceOnboardingDone

		function setDoneFlag() {
			_forceOnboardingDone = true
			if (Qt.platform.os === "wasm") {
				setValue(value | VenusOS.OnboardingState_DoneWasm)
			} else {
				setValue(value | VenusOS.OnboardingState_DoneNative)
			}
		}

		uid: root.serviceUid + "/Settings/Gui2/OnBoarding"
	}

	readonly property VeQuickItem _touchEnabled: VeQuickItem {
		uid: root.serviceUid + "/Settings/Gui/TouchEnabled"
	}

	function reset() {
		// no-op
	}

	Component.onCompleted: Global.systemSettings = root
}

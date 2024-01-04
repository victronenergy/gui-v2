/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil
import Victron.Units

QtObject {
	id: root

	readonly property string serviceUid: BackendConnection.serviceUidForType("settings")

	function canAccess(level) {
		return accessLevel.isValid && accessLevel.value >= level
	}

	function convertTemperature(celsius_value) {
		return temperatureUnit.value === VenusOS.Units_Temperature_Celsius
				? celsius_value
				: Units.celsiusToFahrenheit(celsius_value)
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

	property QtObject electricalQuantity: QtObject {
		// Values for /Settings/Gui/ElectricalPowerIndicator: 0 = watts, 1 = amps
		readonly property var value: _electricalQuantityDataItem.value === 1 ? VenusOS.Units_Amp : VenusOS.Units_Watt

		function setValue(v) {
			if (v === VenusOS.Units_Watt) {
				_electricalQuantityDataItem.setValue(0)
			} else if (v === VenusOS.Units_Amp) {
				_electricalQuantityDataItem.setValue(1)
			} else {
				console.warn("Unsupported electrical quantity:", v)
			}
		}

		readonly property VeQuickItem _electricalQuantityDataItem: VeQuickItem {
			id: _electricalQuantityDataItem
			uid: root.serviceUid + "/Settings/Gui/ElectricalPowerIndicator"
		}
	}

	property QtObject temperatureUnit: QtObject {
		// translate /System/Units/Temperature from string to enum value
		readonly property var value: _unitDataItem.value === "fahrenheit"
				? VenusOS.Units_Temperature_Fahrenheit
				: VenusOS.Units_Temperature_Celsius

		function setValue(v) {
			if (v === VenusOS.Units_Temperature_Celsius) {
				_unitDataItem.setValue("celsius")
			} else if (v === VenusOS.Units_Temperature_Fahrenheit) {
				_unitDataItem.setValue("fahrenheit")
			} else {
				console.warn("Unsupported temperature unit:", v)
			}
		}

		readonly property VeQuickItem _unitDataItem: VeQuickItem {
			id: _unitDataItem
			uid: root.serviceUid + "/Settings/System/Units/Temperature"
		}
	}

	property VeQuickItem volumeUnit: VeQuickItem {
		uid: root.serviceUid + "/Settings/System/VolumeUnit"
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

	function reset() {
		// no-op
	}

	Component.onCompleted: Global.systemSettings = root
}

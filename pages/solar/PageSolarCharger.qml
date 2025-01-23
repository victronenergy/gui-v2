/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	required property string bindPrefix
	readonly property int trackerCount: nrOfTrackers.isValid ? nrOfTrackers.value : 1
	readonly property SolarDevice solarDevice: Global.solarDevices.model.deviceAt(Global.solarDevices.model.indexOf(bindPrefix))

	function _isModelSupported() {
		if (!device.productId || !firmwareVersion.isValid) {
			return true
		}

		// MPPT 70/15 (product id 0x300) has limited VE.Text support
		if (device.productId === 0x300) {
			return false
		}

		// Reserved space for VE.Direct Solar chargers 0xA040..0xA07F: 64 items
		if (device.productId >= 0xA040 && device.productId <= 0xA07F) {
			// Fw versions < v1.09 are not supported
			return firmwareVersion.value >= 0x109
		}

		// Supported: e.g. VE.Can
		return true
	}

	title: device.name

	Device {
		id: device
		serviceUid: root.bindPrefix
	}

	VeQuickItem {
		id: firmwareVersion
		uid: root.bindPrefix + "/FirmwareVersion"
	}

	VeQuickItem {
		id: nrOfTrackers
		uid: root.bindPrefix + "/NrOfTrackers"
	}

	VeQuickItem {
		id: lowBatteryAlarm
		uid: root.bindPrefix + "/Alarms/LowVoltage"
	}

	VeQuickItem {
		id: highBatteryAlarm
		uid: root.bindPrefix + "/Alarms/HighVoltage"
	}

	VeQuickItem {
		id: highTemperatureAlarm
		uid: root.bindPrefix + "/Alarms/HighTemperature"
	}

	VeQuickItem {
		id: shortCircuitAlarm
		uid: root.bindPrefix + "/Alarms/ShortCircuit"
	}

	GradientListView {
		model: _isModelSupported() ? supportedProductModel : unsupportedProductModel
	}

	ObjectModel {
		id: unsupportedProductModel

		PrimaryListLabel {
			text: {
				//% "Unfortunately the connected MPPT Solar Charger is not compatible.";
				const unsupported = qsTrId("solarcharger_not_supported")
				let reason = ""
				if (device.productId === 0x300) { // MPPT 70/15
					//% "The 70/15 needs to be from year/week 1308 or later. MPPT 70/15's currently shipped from our warehouse are compatible."
					reason = qsTrId("solarcharger_not_supported_reason_70_15")
				} else if (firmwareVersion.value < 0x109) {
					//% "The firmware version in the MPPT Solar Charger must be v1.09 or later. Contact Victron Service for update instructions and files."
					reason = qsTrId("solarcharger_not_supported_reason_version")
				}
				return unsupported + (reason ? "\n" + reason : "")
			}
		}

		ListNavigation {
			text: CommonWords.device_info_title
			onClicked: {
				Global.pageManager.pushPage("/pages/settings/PageDeviceInfo.qml",
						{ "title": text, "bindPrefix": root.bindPrefix })
			}
		}
	}

	ObjectModel {
		id: supportedProductModel

		ListText {
			text: CommonWords.state
			secondaryText: Global.system.systemStateToText(dataItem.value)
			dataItem.uid: root.bindPrefix + "/State"
		}

		ListQuantityGroup {
			readonly property real pvCurrent: {
				if (!pvVoltage.value || !pvTotalPower.isValid) {
					return NaN
				}
				return pvTotalPower.value / pvVoltage.value
			}

			//: PV power for solar charger
			//% "PV"
			text: qsTrId("solarcharger_pv")
			preferredVisible: root.trackerCount < 2

			// PV voltage and current are not visible in parallel mode
			textModel: [
				{ value: pvVoltage.value, unit: VenusOS.Units_Volt_DC, visible: pvVoltage.isValid },
				{ value: pvCurrent, unit: VenusOS.Units_Amp, visible: !isNaN(pvCurrent) },
				{ value: pvTotalPower.value, unit: VenusOS.Units_Watt },
			]

			VeQuickItem {
				id: pvVoltage
				uid: root.bindPrefix + "/Pv/V"
			}

			VeQuickItem {
				id: pvTotalPower
				uid: root.bindPrefix + "/Yield/Power"
			}
		}

		ListQuantity {
			//% "Total PV power"
			text: qsTrId("solarcharger_total_power")
			preferredVisible: root.trackerCount >= 2
			value: pvTotalPower.value
			unit: VenusOS.Units_Watt
		}

		QuantityTable {
			// TODO set preferredVisible instead, when VisibleItemModel is available
			visible: root.trackerCount > 1
			rowCount: root.trackerCount
			units: [
				{ title: CommonWords.tracker, unit: VenusOS.Units_None },
				{ title: CommonWords.voltage, unit: VenusOS.Units_Volt_DC },
				{ title: CommonWords.current_amps, unit: VenusOS.Units_Amp },
				{ title: CommonWords.power_watts, unit: VenusOS.Units_Watt }
			]
			valueForModelIndex: function(trackerIndex, column) {
				const tracker = trackerObjects.objectAt(trackerIndex)
				if (column === 0) {
					return Global.solarDevices.formatTrackerName(tracker.name, trackerIndex, root.trackerCount, root.solarDevice.name, VenusOS.TrackerName_NoDevicePrefix)
				} else if (column === 1) {
					return tracker.voltage
				} else if (column === 2) {
					return tracker.current
				} else if (column === 3) {
					return tracker.power
				}
			}

			Instantiator {
				id: trackerObjects
				model: root.solarDevice.trackerCount
				delegate: SolarTracker {
					required property int index

					device: root.solarDevice
					trackerIndex: index
				}
			}
		}

		ListQuantityGroup {
			text: CommonWords.battery
			textModel: [
				{ value: batteryVoltage.value, unit: VenusOS.Units_Volt_DC, },
				{ value: batteryCurrent.value, unit: VenusOS.Units_Amp },

				// Only available on CANbus chargers
				{ value: batteryTemperature.value, unit: Global.systemSettings.temperatureUnit, visible: batteryTemperature.isValid }
			]

			VeQuickItem {
				id: batteryVoltage
				uid: root.bindPrefix + "/Dc/0/Voltage"
			}

			VeQuickItem {
				id: batteryCurrent
				uid: root.bindPrefix + "/Dc/0/Current"
			}

			VeQuickItem {
				id: batteryTemperature
				uid: root.bindPrefix + "/Dc/0/Temperature"
				sourceUnit: Units.unitToVeUnit(VenusOS.Units_Temperature_Celsius)
				displayUnit: Units.unitToVeUnit(Global.systemSettings.temperatureUnit)
			}
		}

		// This is actually the user resettable yield
		ListQuantity {
			//: Solar charger total yield
			//% "Total yield"
			text: qsTrId("solarcharger_total_yield")
			preferredVisible: dataItem.isValid
			unit: VenusOS.Units_Energy_KiloWattHour
			dataItem.uid: root.bindPrefix + "/Yield/User"
		}

		ListQuantity {
			//: Solar charger system yield
			//% "System yield"
			text: qsTrId("solarcharger_system_yield")
			preferredVisible: dataItem.isValid
			unit: VenusOS.Units_Energy_KiloWattHour
			dataItem.uid: root.bindPrefix + "/Yield/System"
		}

		// Only available on 15A chargers.
		// If load is on and current present, show current.
		// Otherwise show the state of the load output.
		ListQuantity {
			id: loadQuantityItem

			//% "Load"
			text: qsTrId("solarcharger_load")
			dataItem.uid: root.bindPrefix + "/Load/I"
			unit: VenusOS.Units_Amp
			preferredVisible: dataItem.isValid && loadState.dataItem.value === 1
		}

		ListText {
			id: loadState

			text: loadQuantityItem.text
			dataItem.uid: root.bindPrefix + "/Load/State"
			preferredVisible: dataItem.isValid && !loadQuantityItem.visible
			secondaryText: CommonWords.yesOrNo(dataItem.value)
		}

		ListText {
			text: CommonWords.error
			dataItem.uid: root.bindPrefix + "/ErrorCode"
			secondaryText: ChargerError.description(dataItem.value)
		}

		// This is the master´s relay state
		ListRelayState {
			dataItem.uid: root.bindPrefix + "/Relay/0/State"
		}

		ListNavigation {
			text: CommonWords.alarm_status
			preferredVisible: lowBatteryAlarm.isValid
							  || highBatteryAlarm.isValid
							  || highTemperatureAlarm.isValid
							  || shortCircuitAlarm.isValid
			onClicked: {
				Global.pageManager.pushPage(alarmStatusComponent, { "title": text })
			}
		}

		ListNavigation {
			text: CommonWords.daily_history
			preferredVisible: root.trackerCount > 0
			onClicked: {
				Global.pageManager.pushPage("/pages/solar/SolarHistoryPage.qml",
						{ "solarHistory": solarHistory })
			}

			SolarHistory {
				id: solarHistory
				bindPrefix: root.bindPrefix
				deviceName: root.title
				trackerCount: root.trackerCount
			}
		}

		ListNavigation {
			text: CommonWords.overall_history
			preferredVisible: root.trackerCount > 0
			onClicked: {
				Global.pageManager.pushPage("/pages/settings/devicelist/inverter/PageSolarStats.qml",
						{ "title": text, "bindPrefix": root.bindPrefix })
			}
		}

		ListNavigation {
			//% "Networked operation"
			text: qsTrId("charger_networked_operation")
			preferredVisible: linkNetworkStatus.isValid
			onClicked: {
				Global.pageManager.pushPage("/pages/solar/PageSolarParallelOperation.qml",
						{ "title": text, "bindPrefix": root.bindPrefix })
			}

			VeQuickItem {
				id: linkNetworkStatus
				uid: root.bindPrefix + "/Link/NetworkStatus"
			}
		}

		ListNavigation {
			text: CommonWords.device_info_title
			onClicked: {
				Global.pageManager.pushPage("/pages/settings/PageDeviceInfo.qml",
						{ "title": text, "bindPrefix": root.bindPrefix })
			}
		}
	}

	Component {
		id: alarmStatusComponent

		Page {
			GradientListView {
				model: [
					//% "Low battery voltage alarm"
					{ display: qsTrId("charger_alarms_low_battery_voltage_alarm"), path: lowBatteryAlarm.uid },
					//% "High battery voltage alarm"
					{ display: qsTrId("charger_alarms_high_battery_voltage_alarm"), path: highBatteryAlarm.uid },
					//% "High temperature alarm"
					{ display: qsTrId("charger_alarms_high_temperature_alarm"), path: highTemperatureAlarm.uid },
					//% "Short circuit alarm"
					{ display: qsTrId("charger_alarms_short_circuit_alarm"), path: shortCircuitAlarm.uid },
				]
				delegate: ListAlarm {
					text: modelData.display
					dataItem.uid: root.bindPrefix + modelData.path
					preferredVisible: dataItem.isValid
				}
			}
		}
	}
}

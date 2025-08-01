/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	Provides a list of settings for a solarcharger device.
*/
DevicePage {
	id: root

	required property string bindPrefix
	readonly property int trackerCount: nrOfTrackers.valid ? nrOfTrackers.value : 1
	readonly property SolarDevice solarDevice: Global.solarInputs.devices.deviceAt(Global.solarInputs.devices.indexOf(bindPrefix))

	function _isModelSupported() {
		if (!device.productId || !firmwareVersion.valid) {
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

	serviceUid: root.bindPrefix
	settingsModel: _isModelSupported() ? supportedProductModel : unsupportedProductModel

	VeQuickItem {
		id: firmwareVersion
		uid: root.bindPrefix + "/FirmwareVersion"
	}

	VeQuickItem {
		id: nrOfTrackers
		uid: root.bindPrefix + "/NrOfTrackers"
	}

	VeQuickItem {
		id: highTemperatureAlarm
		uid: root.bindPrefix + "/Alarms/HighTemperature"
	}

	VeQuickItem {
		id: shortCircuitAlarm
		uid: root.bindPrefix + "/Alarms/ShortCircuit"
	}

	VisibleItemModel {
		id: unsupportedProductModel

		PrimaryListLabel {
			text: {
				//% "Unfortunately the connected MPPT Solar Charger is not compatible."
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
	}

	VisibleItemModel {
		id: supportedProductModel

		ListText {
			text: CommonWords.state
			secondaryText: Global.system.systemStateToText(dataItem.value)
			dataItem.uid: root.bindPrefix + "/State"
		}

		ListQuantityGroup {
			id: pvQuantities

			readonly property real pvCurrent: {
				if (!pvVoltage.value || !pvTotalPower.valid) {
					return NaN
				}
				return pvTotalPower.value / pvVoltage.value
			}

			//: PV power for solar charger
			//% "PV"
			text: qsTrId("solarcharger_pv")
			preferredVisible: root.trackerCount < 2

			// PV voltage and current are not visible in parallel mode
			model: QuantityObjectModel {
				filterType: QuantityObjectModel.HasValue

				QuantityObject { object: pvVoltage; unit: VenusOS.Units_Volt_DC }
				QuantityObject { object: pvQuantities; key: "pvCurrent"; unit: VenusOS.Units_Amp }
				QuantityObject { object: pvTotalPower; unit: VenusOS.Units_Watt; defaultValue: "--" }
			}

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

		BaseListItem {
			width: parent ? parent.width : 0
			height: trackerTable.y + trackerTable.height
			preferredVisible: root.trackerCount > 1

			QuantityTable {
				id: trackerTable
				width: parent.width
				model: root.trackerCount > 1 ? root.trackerCount : 0
				header: count > 0 ? tableHeaderComponent : null
				delegate: QuantityTable.TableRow {
					id: tableRow

					preferredVisible: tracker.enabled
					headerText: Global.solarInputs.formatTrackerName(
							tracker.name, index, root.trackerCount, root.solarDevice.name,
							VenusOS.TrackerName_NoDevicePrefix)
					model: QuantityObjectModel {
						QuantityObject { object: tracker; key: "voltage"; unit: VenusOS.Units_Volt_DC }
						QuantityObject { object: tracker; key: "current"; unit: VenusOS.Units_Amp }
						QuantityObject { object: tracker; key: "power"; unit: VenusOS.Units_Watt }
					}

					SolarTracker {
						id: tracker
						device: root.solarDevice
						trackerIndex: tableRow.index
					}
				}

				Component {
					id: tableHeaderComponent

					QuantityTable.TableHeader {
						headerText: CommonWords.tracker
						model: [
							{ text: CommonWords.voltage, unit: VenusOS.Units_Volt_DC },
							{ text: CommonWords.current_amps, unit: VenusOS.Units_Amp },
							{ text: CommonWords.power_watts, unit: VenusOS.Units_Watt }
						]
					}
				}
			}
		}

		ListQuantityGroup {
			text: CommonWords.battery
			model: QuantityObjectModel {
				filterType: QuantityObjectModel.HasValue

				QuantityObject { object: batteryVoltage; unit: VenusOS.Units_Volt_DC; defaultValue: "--" }
				QuantityObject { object: batteryCurrent; unit: VenusOS.Units_Amp; defaultValue: "--" }

				// Only available on CANbus chargers
				QuantityObject { object: batteryTemperature; unit: VenusOS.Units_Watt }
			}

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
			preferredVisible: dataItem.valid
			unit: VenusOS.Units_Energy_KiloWattHour
			dataItem.uid: root.bindPrefix + "/Yield/User"
		}

		ListQuantity {
			//: Solar charger system yield
			//% "System yield"
			text: qsTrId("solarcharger_system_yield")
			preferredVisible: dataItem.valid
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
			preferredVisible: dataItem.valid && loadState.dataItem.value === 1
		}

		ListText {
			id: loadState

			text: loadQuantityItem.text
			dataItem.uid: root.bindPrefix + "/Load/State"
			preferredVisible: dataItem.valid && !loadQuantityItem.visible
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
			preferredVisible: highTemperatureAlarm.valid
							  || shortCircuitAlarm.valid
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
			preferredVisible: linkNetworkStatus.valid
			onClicked: {
				Global.pageManager.pushPage("/pages/solar/PageSolarParallelOperation.qml",
						{ "title": text, "bindPrefix": root.bindPrefix })
			}

			VeQuickItem {
				id: linkNetworkStatus
				uid: root.bindPrefix + "/Link/NetworkStatus"
			}
		}
	}

	Component {
		id: alarmStatusComponent

		Page {
			GradientListView {
				model: [
					//% "High temperature alarm"
					{ display: qsTrId("charger_alarms_high_temperature_alarm"), path: highTemperatureAlarm.uid },
					//% "Short circuit alarm"
					{ display: qsTrId("charger_alarms_short_circuit_alarm"), path: shortCircuitAlarm.uid },
				]
				delegate: ListAlarm {
					text: modelData.display
					dataItem.uid: modelData.path
					preferredVisible: dataItem.valid
				}
			}
		}
	}
}

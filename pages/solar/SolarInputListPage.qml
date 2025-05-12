/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	// A list of all solar inputs. For solarcharger, multi and inverter services, each tracker is
	// an individual entry in the list. For PV inverters, each inverter is an entry in the list,
	// since PV inverters do not have multiple trackers.
	GradientListView {
		model: SolarInputModel {
			id: solarInputModel
		}
		delegate: ListQuantityGroupNavigation {
			id: solarInputDelegate

			required property int index
			required property string serviceUid
			required property string name
			required property real todaysYield
			required property real energy
			required property real power
			required property real voltage
			required property real current
			readonly property string serviceType: BackendConnection.serviceTypeFromUid(serviceUid)

			text: name
			tableMode: true
			quantityModel: QuantityObjectModel {
				QuantityObject { object: solarInputDelegate; key: solarInputDelegate.serviceType === "pvinverter" ? "energy" : "todaysYield"; unit: VenusOS.Units_Energy_KiloWattHour }
				QuantityObject { object: solarInputDelegate; key: "voltage"; unit: VenusOS.Units_Volt_DC }
				QuantityObject { object: solarInputDelegate; key: "current"; unit: VenusOS.Units_Amp }
				QuantityObject { object: solarInputDelegate; key: "power"; unit: VenusOS.Units_Watt }
			}

			onClicked: {
				if (serviceType === "pvinverter") {
					const pvInverter = Global.pvInverters.model.deviceAt(Global.pvInverters.model.indexOf(serviceUid))
					Global.pageManager.pushPage("/pages/solar/PvInverterPage.qml", { pvInverter: pvInverter })
				} else {
					const solarDevice = Global.solarDevices.model.deviceAt(Global.solarDevices.model.indexOf(serviceUid))
					Global.pageManager.pushPage("/pages/solar/SolarDevicePage.qml", { solarDevice: solarDevice })
				}
			}
		}

		section.property: "group"
		section.delegate: QuantityGroupListHeader {
			required property string section

			firstColumnText: section === "pvinverter" ? CommonWords.pv_inverter : ""
			quantityTitleModel: [
				{ text: section === "pvinverter" ? CommonWords.energy : CommonWords.yield_today, unit: VenusOS.Units_Energy_KiloWattHour },
				{ text: CommonWords.voltage, unit: section === "pvinverter" ? VenusOS.Units_Volt_AC : VenusOS.Units_Volt_DC },
				{ text: CommonWords.current_amps, unit: VenusOS.Units_Amp },
				{ text: CommonWords.power_watts, unit: VenusOS.Units_Watt },
			]
		}
	}

	// Extract solar data from all known solar devices (solarcharger/multi/inverter services), and
	// inject it into solarInputModel.
	Instantiator {
		model: Global.solarDevices.model
		delegate: Instantiator {
			id: solarDeviceDelegate

			required property var device

			readonly property Instantiator trackerObjects: Instantiator {
				model: solarDeviceDelegate.device.trackerCount
				delegate: SolarTracker {
					required property int index
					readonly property real todaysYield: {
						const historyToday = device.trackerCount > 1
								? device.dailyTrackerHistory(0, index)
								: device.dailyHistory(0)
						return historyToday?.yieldKwh ?? NaN
					}
					readonly property string formattedName: Global.solarDevices.formatTrackerName(
							name, index, device.trackerCount, device.name, VenusOS.TrackerName_WithDevicePrefix)
					property bool initialized

					function addToModel() {
						const values = {
							group: "generic",
							name: formattedName,
							todaysYield: todaysYield,
							power: power,
							current: current,
							voltage: voltage
						}
						solarInputModel.addInput(device.serviceUid, values, trackerIndex)
					}

					function removeFromModel() {
						const modelIndex = solarInputModel.indexOf(solarDeviceDelegate.device.serviceUid, index)
						if (modelIndex >= 0) {
							solarInputModel.removeAt(modelIndex)
						}
					}

					function updateModel() {
						if (initialized) {
							removeFromModel()
							if (enabled) {
								addToModel()
							}
						}
					}

					device: solarDeviceDelegate.device
					trackerIndex: index

					onTodaysYieldChanged: solarInputModel.setInputValue(device.serviceUid, SolarInputModel.TodaysYieldRole, todaysYield, trackerIndex)
					onPowerChanged: solarInputModel.setInputValue(device.serviceUid, SolarInputModel.PowerRole, power, trackerIndex)
					onCurrentChanged: solarInputModel.setInputValue(device.serviceUid, SolarInputModel.CurrentRole, current, trackerIndex)
					onVoltageChanged: solarInputModel.setInputValue(device.serviceUid, SolarInputModel.VoltageRole, voltage, trackerIndex)

					onFormattedNameChanged: updateModel()
					onEnabledChanged: updateModel()
				}

				onObjectAdded: (index, object) => {
					if (object.enabled) {
						object.addToModel()
					}
					object.initialized = true
				}
				onObjectRemoved: (index, object) => {
					object.removeFromModel()
				}
			}
		}
	}

	// Extract solar data from all known PV inverters, and inject it into solarInputModel.
	Instantiator {
		model: Global.pvInverters.model
		delegate: QtObject {
			required property var device
			readonly property string name: device.name
			readonly property real energy: device.energy
			readonly property real power: device.power
			readonly property real current: device.current
			readonly property real voltage: device.voltage

			onEnergyChanged: solarInputModel.setInputValue(device.serviceUid, SolarInputModel.EnergyRole, energy)
			onPowerChanged: solarInputModel.setInputValue(device.serviceUid, SolarInputModel.PowerRole, power)
			onCurrentChanged: solarInputModel.setInputValue(device.serviceUid, SolarInputModel.CurrentRole, current)
			onVoltageChanged: solarInputModel.setInputValue(device.serviceUid, SolarInputModel.VoltageRole, voltage)

			onNameChanged: {
				const values = {
					group: "pvinverter",
					name: name,
					energy: energy,
					power: power,
					current: current,
					voltage: voltage
				}
				solarInputModel.addInput(device.serviceUid, values)
			}
		}

		onObjectRemoved: (index, object) => {
			solarInputModel.removeAt(solarInputModel.indexOf(object.device.serviceUid))
		}
	}
}

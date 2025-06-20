/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	Configures various system and settings according to available services and their values.
*/
Item {
	id: root

	function setSettingsValue(path, value) {
		MockManager.setValue("com.victronenergy.settings" + path, value)
	}
	function settingsValue(path) {
		return MockManager.value("com.victronenergy.settings" + path)
	}

	function setSystemValue(path, value) {
		MockManager.setValue("com.victronenergy.system" + path, value)
	}
	function systemValue(path) {
		return MockManager.value("com.victronenergy.system" + path)
	}

	// Set /SystemState/State to the state of the inverter/charger with the lowest instance.
	// This isn't necessarily correct, but it will do for mock mode.
	VeQuickItem {
		uid: Global.inverterChargers.firstObject
			 ? Global.inverterChargers.firstObject.serviceUid + "/State"
			 : ""
		onValueChanged: root.setSystemValue("/SystemState/State", value ?? VenusOS.System_State_Off)
	}


	//--- Set up AC/DC load ---

	VeQItemSortTableModel {
		id: inverterChargerModel
		dynamicSortFilter: true
		filterRole: VeQItemTableModel.UniqueIdRole
		filterFlags: VeQItemSortTableModel.FilterOffline
		filterRegExp: "^mock/com\.victronenergy\.(multi|vebus|inverter)\."
		model: Global.dataServiceModel
	}

	// Set /Ac/Consumption, /Ac/ConsumptionOnOutput and /Ac/ConsumptionOnInput values.
	Instantiator {
		id: acOutObjects

		function updateTotals() {
			// Set /Ac/Consumption to the totals from /Ac/Out of inverter/charger services. This
			// is a simple way to get some numbers we can see in mock mode.
			let maxPhaseIndex = 0
			for (let phaseIndex = 0; phaseIndex < 3; ++phaseIndex) {
				let phaseTotalPower = NaN
				let phaseTotalCurrent = NaN
				maxPhaseIndex = Math.max(maxPhaseIndex, phaseIndex)
				for (let objectIndex = 0; objectIndex < count; ++objectIndex) {
					const acConn = objectAt(objectIndex)
					if (!acConn) {
						continue
					}
					phaseTotalPower = Units.sumRealNumbers(phaseTotalPower, acConn["powerL" + (phaseIndex + 1)].value)
					phaseTotalCurrent = Units.sumRealNumbers(phaseTotalCurrent, acConn["_currentL" + (phaseIndex + 1)].value)
				}

				// Not sure of the best way to mock input vs output consumption. For now, set
				// ConsumptionOnOutput to 2/3 of the total, and ConsumptionOnInput to 1/3.
				if (!isNaN(phaseTotalPower)) {
					root.setSystemValue("/Ac/Consumption/L%1/Power".arg(phaseIndex + 1), phaseTotalPower)
					root.setSystemValue("/Ac/ConsumptionOnOutput/L%1/Power".arg(phaseIndex + 1), phaseTotalPower * (2/3))
					root.setSystemValue("/Ac/ConsumptionOnInput/L%1/Power".arg(phaseIndex + 1), phaseTotalPower * (1/3))
				}
				if (!isNaN(phaseTotalCurrent)) {
					root.setSystemValue("/Ac/Consumption/L%1/Current".arg(phaseIndex + 1), phaseTotalCurrent)
					root.setSystemValue("/Ac/ConsumptionOnOutput/L%1/Current".arg(phaseIndex + 1), phaseTotalCurrent * (2/3))
					root.setSystemValue("/Ac/ConsumptionOnInput/L%1/Current".arg(phaseIndex + 1), phaseTotalCurrent * (1/3))
				}
			}
			root.setSystemValue("/Ac/Consumption/NumberOfPhases", maxPhaseIndex + 1)
			root.setSystemValue("/Ac/ConsumptionOnOutput/NumberOfPhases", maxPhaseIndex + 1)
			root.setSystemValue("/Ac/ConsumptionOnInput/NumberOfPhases", maxPhaseIndex + 1)
		}

		model: inverterChargerModel
		delegate: ObjectAcConnection {
			required property string uid

			bindPrefix: uid + "/Ac/Out"
			powerKey: "P"
			currentKey: "I"
			onCurrentChanged: Qt.callLater(acOutObjects.updateTotals)
			onPowerChanged: Qt.callLater(acOutObjects.updateTotals)
		}
	}

	// Set /Dc/System/Power. Not sure how to mock this, so hard code it to AC-load * 2, if HasDcSystem=true.
	Connections {
		target: Global.system.load.ac
		enabled: hasDcSystem.value === 1
		function onPowerChanged() {
			root.setSystemValue("/Dc/System/Power", Global.system.load.ac.power * 2)
		}
	}
	VeQuickItem {
		id: hasDcSystem
		uid: Global.systemSettings.serviceUid + "/Settings/SystemSetup/HasDcSystem"
	}

	//--- Set up Inverter/chargers ---

	// Set /Dc/InverterCharger/Power to the total power of inverter/chargers on the system.
	Instantiator {
		id: inverterChargerObjects
		function updateTotal() {
			let totalPower = NaN
			for (let i = 0; i < count; ++i) {
				totalPower = Units.sumRealNumbers(totalPower, objectAt(i)?.power ?? 0)
			}
			root.setSystemValue("/Dc/InverterCharger/Power", totalPower)
		}

		model: AggregateDeviceModel {
			sourceModels: [
				Global.inverterChargers.veBusDevices,
				Global.inverterChargers.acSystemDevices,
				Global.inverterChargers.inverterDevices,
				Global.inverterChargers.chargerDevices,
			]
		}
		delegate: VeQuickItem {
			required property Device device
			uid: device.serviceUid + "/Dc/0/Power"
			onValueChanged: Qt.callLater(inverterChargerObjects.updateTotal)
		}
	}

	// Set /VebusService to name of the first vebus service found on the system.
	Connections {
		target: Global.inverterChargers.veBusDevices
		function onFirstObjectChanged() {
			const device = Global.inverterChargers.veBusDevices.firstObject
			if (device) {
				// Write uid like "com.victronenergy.vebus.tty0", without "mock/" prefix
				const uid = device.serviceUid.substring(BackendConnection.uidPrefix().length + 1)
				root.setSystemValue("/VebusService", uid)
				root.setSystemValue("/VebusInstance", device.deviceInstance)
			} else {
				root.setSystemValue("/VebusService", "")
				root.setSystemValue("/VebusService", undefined)
			}
		}
	}

	//--- Set up PV data ---

	// Set /Ac/PvOnOutput to the total PV power and current.
	function _updatePvTotals() {
		let phaseIndex
		if (pvInverters.count) {
			let phaseCount = 0
			let phasePowers = []
			let phaseCurrents = []
			for (let i = 0; i < pvInverters.count; ++i) {
				const inverter = pvInverters.objectAt(i)
				if (inverter) {
					phaseCount = Math.max(phaseCount, inverter.phases.count)
					for (phaseIndex = 0; phaseIndex < inverter.phases.count; ++phaseIndex) {
						const phase = inverter.phases.get(phaseIndex)
						phasePowers[phaseIndex] = Units.sumRealNumbers(phasePowers[phaseIndex], phase.power)
						phaseCurrents[phaseIndex] = Units.sumRealNumbers(phaseCurrents[phaseIndex], phase.current)
					}
				}
			}
			// Could set the values on any of PvOnGrid/PvOnGenset/PvOnOutput
			root.setSystemValue("/Ac/PvOnOutput/NumberOfPhases", phaseCount)
			for (phaseIndex = 0; phaseIndex < phaseCount; ++phaseIndex) {
				root.setSystemValue("/Ac/PvOnOutput/L%1/Power".arg(phaseIndex + 1), phasePowers[phaseIndex])
				root.setSystemValue("/Ac/PvOnOutput/L%1/Current".arg(phaseIndex + 1), phaseCurrents[phaseIndex])
			}
			// Reset any other phase values from previous configurations.
			for (phaseIndex = phaseCount; phaseIndex < 3; ++phaseIndex) {
				root.setSystemValue("/Ac/PvOnOutput/L%1/Power".arg(phaseIndex + 1), phasePowers[phaseIndex])
				root.setSystemValue("/Ac/PvOnOutput/L%1/Current".arg(phaseIndex + 1), phaseCurrents[phaseIndex])
			}
		} else {
			root.setSystemValue("/Ac/PvOnOutput/NumberOfPhases", undefined)
			for (phaseIndex = 0; phaseIndex < 3; ++phaseIndex) {
				root.setSystemValue("/Ac/PvOnOutput/L%1/Power".arg(phaseIndex + 1), undefined)
				root.setSystemValue("/Ac/PvOnOutput/L%1/Current".arg(phaseIndex + 1), undefined)
			}
		}

		let dcPower = NaN
		if (solarDevices.model.count) {
			for (let i = 0; i < solarDevices.model.count; ++i) {
				const charger = solarDevices.model.deviceAt(i)
				if (charger) {
					dcPower = Units.sumRealNumbers(dcPower, charger.power)
				}
			}
		}
		root.setSystemValue("/Dc/Pv/Power", dcPower)
		root.setSystemValue("/Dc/Pv/Current", NaN)
	}

	Instantiator {
		id: solarDevices
		model: Global.solarInputs.devices
		delegate: QtObject {
			readonly property real power: modelData.power
			onPowerChanged: Qt.callLater(root._updatePvTotals)
		}
		onCountChanged: Qt.callLater(root._updatePvTotals)
	}

	Instantiator {
		id: pvInverters
		model: Global.solarInputs.pvInverterDevices
		delegate: QtObject {
			readonly property real power: modelData.power
			readonly property var phases: modelData.phases
			onPowerChanged: Qt.callLater(root._updatePvTotals)
		}
		onCountChanged: Qt.callLater(root._updatePvTotals)
	}

	//--- Set up batteries ---

	MockSetupBatteries {}

	//--- Set up temperature services ---

	MockSetupTemperature {}

	//--- Set up /Settings/Devices ---

	MockSetupDevices {}

	//--- Set up Brief gauge ranges ---

	Loader {
		active: gaugeAutoMax.value === 1
		sourceComponent: MockSetupGaugeAutoRange {}

		VeQuickItem {
			id: gaugeAutoMax
			uid: Global.systemSettings.serviceUid + "/Settings/Gui/Gauges/AutoMax"
		}
	}
}

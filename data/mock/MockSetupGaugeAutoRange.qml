/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	Sets the user-preferred gauge ranges values for the Brief page.
*/
Item {
	id: root

	function setGaugesValue(path, value) {
		MockManager.setValue("com.victronenergy.settings/Settings/Gui/Gauges" + path, value)
	}
	function gaugesValue(path) {
		return MockManager.value("com.victronenergy.settings/Settings/Gui/Gauges" + path)
	}

	// Min/max AC-in range: set to the lowest and highest-seen AC-in values.
	Instantiator {
		model: 2
		delegate: QtObject {
			id: phaseDelegate
			required property int index

			readonly property Instantiator phaseObjects: Instantiator {
				function updateMinMaxCurrent() {
					for (let i = 0; i < count; ++i) {
						const phase = objectAt(i)
						if (phase) {
							if (isNaN(phase.current)) {
								return
							}
							const minCurrentPath = `/Ac/In/${phaseDelegate.index}/Current/Min`
							const minCurrent = root.gaugesValue(minCurrentPath)
							root.setGaugesValue(minCurrentPath, isNaN(minCurrent) ? phase.current : Math.min(minCurrent, phase.current))

							const maxCurrentPath = `/Ac/In/${phaseDelegate.index}/Current/Max`
							const maxCurrent = root.gaugesValue(maxCurrentPath)
							root.setGaugesValue(maxCurrentPath, isNaN(maxCurrent) ? phase.current : Math.max(maxCurrent, phase.current))
						}
					}
				}

				model: index === 0 ? Global.acInputs.input1?.phases : Global.acInputs.input2?.phases
				delegate: QtObject {
					required property real current
					onCurrentChanged: Qt.callLater(phaseObjects.updateMinMaxCurrent)
				}
			}
		}
	}

	// Min/max AC-out range: set to the highest-seen AC-out value.
	Instantiator {
		id: consumptionObjects

		function updateRange() {
			let maxCurrent = NaN
			for (let i = 0; i < count; ++i) {
				const obj = objectAt(i)
				if (!isNaN(obj.value)) {
					maxCurrent = isNaN(maxCurrent) ? obj.value : Math.max(maxCurrent, obj.value)
				}
				root.setGaugesValue("/Ac/AcIn1/Consumption/Current/Max", maxCurrent ?? 0)
				root.setGaugesValue("/Ac/AcIn2/Consumption/Current/Max", maxCurrent ?? 0)
				root.setGaugesValue("/Ac/NoAcIn/Consumption/Current/Max", maxCurrent ?? 0)
			}
		}

		model: 3
		delegate: VeQuickItem {
			required property int index
			uid: `${Global.system.serviceUid}/Ac/Consumption/L${index + 1}/Current`
			onValueChanged: Qt.callLater(consumptionObjects.updateRange)
		}
	}

	// Max DC-in power: set to double the total DC-in power.
	Instantiator {
		id: dcInputObjects

		function updateMaxPower() {
			let totalPower = 0
			for (let i = 0; i < count; ++i) {
				const power = objectAt(i)?.value ?? 0
				totalPower += power
			}
			root.setGaugesValue("/Dc/Input/Power/Max", totalPower * 2)
		}

		model: VeQItemSortTableModel {
			dynamicSortFilter: true
			filterRole: VeQItemTableModel.UniqueIdRole
			filterRegExp: "^mock/com\.victronenergy\.(alternator|fuelcell|dcsource|dcgenset)\."
			model: Global.dataServiceModel
		}
		delegate: VeQuickItem {
			id: inputDelegate
			uid: model.uid + "/Dc/0/Power"
			onValueChanged: Qt.callLater(dcInputObjects.updateMaxPower)
		}
	}

	// System DC power: set to double the total DC power.
	VeQuickItem {
		uid: Global.system.serviceUid + "/Dc/System/Power"
		onValueChanged: {
			const maxPower = root.gaugesValue("/Dc/System/Power/Max")
			const newMax = isNaN(maxPower) ? value : Math.max(maxPower, value)
			root.setGaugesValue("/Dc/System/Power/Max", newMax * 2)
		}
	}

	// Max PV power: set to double the total PV power.
	VeQuickItem {
		uid: Global.system.serviceUid + "/Dc/Pv/Power"
		onValueChanged: {
			const maxPower = root.gaugesValue("/Pv/Power/Max")
			const newMax = isNaN(maxPower) ? value : Math.max(maxPower, value)
			root.setGaugesValue("/Pv/Power/Max", newMax * 2)
		}
	}
}

/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Item {
	id: root

	function setSystemValue(path, value) {
		MockManager.setValue("com.victronenergy.system" + path, value)
	}
	function systemValue(path) {
		return MockManager.value("com.victronenergy.system" + path)
	}

	function setGaugesValue(path, value) {
		MockManager.setValue(Global.systemSettings.serviceUid + "/Settings/Gui/Gauges" + path, value)
	}
	function gaugesValue(path) {
		return MockManager.value(Global.systemSettings.serviceUid + "/Settings/Gui/Gauges" + path)
	}

	VeQuickItem {
		id: gaugesAutoMax
		uid: Global.systemSettings.serviceUid + "/Settings/Gui/Gauges/AutoMax"
	}

	// DC inputs: set the max DC-in power for the Brief/Overview gauge ranges.
	Instantiator {
		id: dcInputObjects

		function updateMaxPower() {
			let totalPower = 0
			for (let i = 0; i < count; ++i) {
				const power = objectAt(i)?.value ?? 0
				totalPower += power
			}
			root.setGaugesValue("/Dc/Input/Power/Max", Math.max(totalPower, root.gaugesValue("/Dc/Input/Power/Max") || 0))
		}

		active: gaugesAutoMax.value === 1
		model: VeQItemSortTableModel {
			dynamicSortFilter: true
			filterRole: VeQItemTableModel.UniqueIdRole
			filterRegExp: "^mock/com\.victronenergy\.(alternator|fuelcell|dcsource|dcgenset)\."
			model: Global.dataServiceModel
		}
		delegate: VeQuickItem {
			id: inputDelegate
			uid: model.uid + "/Dc/0/Power"
		}
		onObjectAdded: (index, dcInput) => {
			Qt.callLater(dcInputObjects.updateMaxPower)
		}
	}

	// DC Loads: set /Dc/System/Power to the total power of DC loads on the system.
	// Also set the max Brief/Overview gauge value for this, if required.
	Instantiator {
		id: dcLoads

		function updateTotals() {
			let totalPower = 0
			for (let i = 0; i < count; ++i) {
				totalPower += objectAt(i)?.power?.value ?? 0
			}
			root.setSystemValue("/Dc/System/Power", totalPower)

			if (gaugesAutoMax.value === 1) {
				root.setGaugesValue("/Dc/System/Power/Max",
						Math.max(totalPower, root.gaugesValue("/Dc/System/Power/Max") || 0))
			}
		}

		model: Global.allDevicesModel.combinedDcLoadDevices
		delegate: QtObject {
			id: dcLoad

			required property Device device
			readonly property VeQuickItem power: VeQuickItem {
				uid: dcLoad.device.serviceUid + "/Dc/0/Power"
				onValueChanged: Qt.callLater(dcLoads.updateTotals)
			}
		}
	}
	VeQuickItem {
		id: hasDcSystem
		uid: Global.systemSettings.serviceUid + "/Settings/SystemSetup/HasDcSystem"
	}

	// Animate DC meters.
	Instantiator {
		model: ServiceModel {
			serviceTypes: [
				"alternator",
				"battery",
				"solarcharger",
				"dcdc",
				"dcload",
				"dcsource",
				"dcsystem",
				"fuelcell",
				"vebus",
			]
		}
		delegate: Item {
			id: dcMeter

			required property string uid

			// Animate all common properties. Any properties which are not present on a particular
			// service will be ignored.
			MockDataRangeAnimator {
				id: socAnimator
				maximumValue: 100
				stepSize: 8
				VeQuickItem { uid: dcMeter.uid + "/Soc" }
			}
			MockDataRandomizer {
				followSignOf: socAnimator.actualStepSizes[0] ?? NaN
				VeQuickItem { uid: dcMeter.uid + "/Dc/0/Power" }
				VeQuickItem { uid: dcMeter.uid + "/Dc/0/Current" }
			}
			MockDataRandomizer {
				VeQuickItem { uid: dcMeter.uid + "/Dc/0/Voltage" }
				VeQuickItem { uid: dcMeter.uid + "/Dc/0/Temperature" }
				VeQuickItem { uid: dcMeter.uid + "/Dc/In/P" }
				VeQuickItem { uid: dcMeter.uid + "/Dc/In/V" }
				VeQuickItem { uid: dcMeter.uid + "/Dc/In/I" }
			}
		}
	}
}

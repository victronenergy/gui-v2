/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string qwacsPvInverterPrefix: "com.victronenergy.pvinverter.qwacs_di1"
	property string sensorsPvInverterPrefix: "com.victronenergy.pvinverter.vebusacsensor_output"
	property string vebusPrefix: Global.system.veBus.serviceUid

	function powerDiff(a, b) {
		if (!a.valid || !b.valid)
			return "--"
		return (a.value - b.value).toFixed(0) + "W"
	}

	function apparentPower(V, I) {
		if (!V.valid || !I.valid)
			return "--"
		return (V.value * I.value).toFixed(0) + "VA"
	}

	function groupItemWidth(group) {
		const columnCount = 7
		return (group.availableWidth - (group.content.spacing * (columnCount - 1))) / columnCount
	}

	QtObject {
		id: sensorPvInverter

		property DataPoint powerL1: DataPoint { source: sensorsPvInverterPrefix + "/Ac/L1/Power" }
		property DataPoint powerL2: DataPoint { source: sensorsPvInverterPrefix + "/Ac/L2/Power" }
		property DataPoint powerL3: DataPoint { source: sensorsPvInverterPrefix + "/Ac/L3/Power" }
	}

	QtObject {
		id: qwacsPvInverter

		property DataPoint powerL1: DataPoint { source: qwacsPvInverterPrefix + "/Ac/L1/Power" }
		property DataPoint powerL2: DataPoint { source: qwacsPvInverterPrefix + "/Ac/L2/Power" }
		property DataPoint powerL3: DataPoint { source: qwacsPvInverterPrefix + "/Ac/L3/Power" }
		property DataPoint currentL1: DataPoint { source: qwacsPvInverterPrefix + "/Ac/L1/Current" }
		property DataPoint currentL2: DataPoint { source: qwacsPvInverterPrefix + "/Ac/L2/Current" }
		property DataPoint currentL3: DataPoint { source: qwacsPvInverterPrefix + "/Ac/L3/Current" }
		property DataPoint voltageL1: DataPoint { source: qwacsPvInverterPrefix + "/Ac/L1/Voltage" }
		property DataPoint voltageL2: DataPoint { source: qwacsPvInverterPrefix + "/Ac/L2/Voltage" }
		property DataPoint voltageL3: DataPoint { source: qwacsPvInverterPrefix + "/Ac/L3/Voltage" }
		property string apparentL1: apparentPower(currentL1, voltageL1)
		property string apparentL2: apparentPower(currentL2, voltageL2)
		property string apparentL3: apparentPower(currentL3, voltageL3)
	}

	QtObject {
		id: acOut

		property DataPoint powerL1: DataPoint { source: vebusPrefix + "/Ac/Out/L1/P" }
		property DataPoint powerL2: DataPoint { source: vebusPrefix + "/Ac/Out/L2/P" }
		property DataPoint powerL3: DataPoint { source: vebusPrefix + "/Ac/Out/L3/P" }
		property DataPoint apparentL1: DataPoint { source: vebusPrefix + "/Ac/Out/L1/S" }
		property DataPoint apparentL2: DataPoint { source: vebusPrefix + "/Ac/Out/L2/S" }
		property DataPoint apparentL3: DataPoint { source: vebusPrefix + "/Ac/Out/L3/S" }
	}

	GradientListView {
		// This page has no useful data on MQTT. This can be resolved later on if the MQTT
		// equivalents can be identified for the com.victronenergy.pvinverter.qwacs_di1 and
		// com.victronenergy.pvinverter.vebusacsensor_output uids, which are currently hardcoded
		// in a D-Bus format.
		model: BackendConnection.type === BackendConnection.MqttSource ? invalidModel : validModel

		ObjectModel {
			id: invalidModel

			ListLabel {
				text: "This page is not supported via MQTT. View this on the device instead."
			}
		}

		ObjectModel {
			id: validModel

			ListTextGroup {
				id: groupP

				itemWidth: root.groupItemWidth(groupP)
				text: "P"
				textModel: [ "AC Out", "AC Out", "Qwacs", "Qwacs", "Sensors", "Diff" ]
			}

			ListTextGroup {
				id: groupL1

				text: "L1"
				itemWidth: root.groupItemWidth(groupL1)
				textModel: [
					acOut.powerL1.value || "--",
					acOut.apparentL1.value || "--",
					qwacsPvInverter.powerL1.value || "--",
					qwacsPvInverter.apparentL1.value || "--",
					sensorPvInverter.powerL1.value || "--",
					powerDiff(sensorPvInverter.powerL1, qwacsPvInverter.powerL1),
				]
			}

			ListTextGroup {
				id: groupL2

				text: "L2"
				itemWidth: root.groupItemWidth(groupL2)
				textModel: [
					acOut.powerL2.value || "--",
					acOut.apparentL2.value || "--",
					qwacsPvInverter.powerL2.value || "--",
					qwacsPvInverter.apparentL2.value || "--",
					sensorPvInverter.powerL2.value || "--",
					powerDiff(sensorPvInverter.powerL2, qwacsPvInverter.powerL2),
				]
			}

			ListTextGroup {
				id: groupL3

				text: "L3"
				itemWidth: root.groupItemWidth(groupL3)
				textModel: [
					acOut.powerL3.value || "--",
					acOut.apparentL3.value || "--",
					qwacsPvInverter.powerL3.value || "--",
					qwacsPvInverter.apparentL3.value || "--",
					sensorPvInverter.powerL3.value || "--",
					powerDiff(sensorPvInverter.powerL3, qwacsPvInverter.powerL3),
				]
			}
		}
	}
}

/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string qwacsPvInverterPrefix: "%1/com.victronenergy.pvinverter.qwacs_di1".arg(BackendConnection.uidPrefix())
	property string sensorsPvInverterPrefix: "%1/com.victronenergy.pvinverter.vebusacsensor_output".arg(BackendConnection.uidPrefix())
	property string vebusPrefix: Global.system.veBus.serviceUid

	function powerDiff(a, b) {
		return a.valid && !b.valid ? a.value - b.value : NaN
	}

	function apparentPower(voltage, current) {
		return voltage.valid && !current.valid ? voltage.value * current.value : NaN
	}

	QtObject {
		id: sensorPvInverter

		property VeQuickItem powerL1: VeQuickItem { uid: sensorsPvInverterPrefix + "/Ac/L1/Power" }
		property VeQuickItem powerL2: VeQuickItem { uid: sensorsPvInverterPrefix + "/Ac/L2/Power" }
		property VeQuickItem powerL3: VeQuickItem { uid: sensorsPvInverterPrefix + "/Ac/L3/Power" }
	}

	QtObject {
		id: qwacsPvInverter

		property VeQuickItem powerL1: VeQuickItem { uid: qwacsPvInverterPrefix + "/Ac/L1/Power" }
		property VeQuickItem powerL2: VeQuickItem { uid: qwacsPvInverterPrefix + "/Ac/L2/Power" }
		property VeQuickItem powerL3: VeQuickItem { uid: qwacsPvInverterPrefix + "/Ac/L3/Power" }
		property VeQuickItem currentL1: VeQuickItem { uid: qwacsPvInverterPrefix + "/Ac/L1/Current" }
		property VeQuickItem currentL2: VeQuickItem { uid: qwacsPvInverterPrefix + "/Ac/L2/Current" }
		property VeQuickItem currentL3: VeQuickItem { uid: qwacsPvInverterPrefix + "/Ac/L3/Current" }
		property VeQuickItem voltageL1: VeQuickItem { uid: qwacsPvInverterPrefix + "/Ac/L1/Voltage" }
		property VeQuickItem voltageL2: VeQuickItem { uid: qwacsPvInverterPrefix + "/Ac/L2/Voltage" }
		property VeQuickItem voltageL3: VeQuickItem { uid: qwacsPvInverterPrefix + "/Ac/L3/Voltage" }
		property real apparentL1: apparentPower(currentL1, voltageL1)
		property real apparentL2: apparentPower(currentL2, voltageL2)
		property real apparentL3: apparentPower(currentL3, voltageL3)
	}

	QtObject {
		id: acOut

		property VeQuickItem powerL1: VeQuickItem { uid: vebusPrefix + "/Ac/Out/L1/P" }
		property VeQuickItem powerL2: VeQuickItem { uid: vebusPrefix + "/Ac/Out/L2/P" }
		property VeQuickItem powerL3: VeQuickItem { uid: vebusPrefix + "/Ac/Out/L3/P" }
		property VeQuickItem apparentL1: VeQuickItem { uid: vebusPrefix + "/Ac/Out/L1/S" }
		property VeQuickItem apparentL2: VeQuickItem { uid: vebusPrefix + "/Ac/Out/L2/S" }
		property VeQuickItem apparentL3: VeQuickItem { uid: vebusPrefix + "/Ac/Out/L3/S" }
	}

	QtObject {
		id: diffs
		readonly property real powerL1: root.powerDiff(sensorPvInverter.powerL1, qwacsPvInverter.powerL1)
		readonly property real powerL2: root.powerDiff(sensorPvInverter.powerL2, qwacsPvInverter.powerL2)
		readonly property real powerL3: root.powerDiff(sensorPvInverter.powerL3, qwacsPvInverter.powerL3)
	}

	GradientListView {
		// This page has no useful data on MQTT. This can be resolved later on if the MQTT
		// equivalents can be identified for the com.victronenergy.pvinverter.qwacs_di1 and
		// com.victronenergy.pvinverter.vebusacsensor_output uids, which are currently hardcoded
		// in a D-Bus format.
		model: BackendConnection.type === BackendConnection.MqttSource ? invalidModel : validModel

		VisibleItemModel {
			id: invalidModel

			PrimaryListLabel {
				text: "This page is not supported via MQTT. View this on the device instead."
			}
		}

		VisibleItemModel {
			id: validModel

			QuantityTable {
				id: quantityTable

				width: parent?.width ?? 0
				model: 3
				columnSpacing: Theme.geometry_quantityTable_horizontalSpacing_small
				equalWidthColumns: true

				header: QuantityTable.TableHeader {
					headerText: "Name"
					model: [
						{ text: "AC Out", unit: VenusOS.Units_Watt },
						{ text: "AC Out", unit: VenusOS.Units_VoltAmpere },
						{ text: "Qwacs", unit: VenusOS.Units_Watt },
						{ text: "Qwacs", unit: VenusOS.Units_VoltAmpere },
						{ text: "Sensors", unit: VenusOS.Units_Watt },
						{ text: "Diff", unit: VenusOS.Units_Watt },
					]
				}
				delegate: QuantityTable.TableRow {
					id: tableRow
					headerText: `L${index + 1}`
					model: QuantityObjectModel {
						id: rowModel
						readonly property string phaseName: `L${tableRow.index + 1}`

						QuantityObject { object: acOut; key: `power${rowModel.phaseName}`; unit: VenusOS.Units_Watt }
						QuantityObject { object: acOut; key: `apparent${rowModel.phaseName}`; unit: VenusOS.Units_VoltAmpere }
						QuantityObject { object: qwacsPvInverter; key: `power${rowModel.phaseName}`; unit: VenusOS.Units_Watt }
						QuantityObject { object: qwacsPvInverter; key: `apparent${rowModel.phaseName}`; unit: VenusOS.Units_VoltAmpere }
						QuantityObject { object: sensorPvInverter; key: `power${rowModel.phaseName}`; unit: VenusOS.Units_Watt }
						QuantityObject { object: diffs; key: `power${rowModel.phaseName}`; unit: VenusOS.Units_Watt }
					}
				}
			}
		}
	}
}

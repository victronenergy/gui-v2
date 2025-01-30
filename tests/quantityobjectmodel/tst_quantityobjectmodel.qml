/*
 * Copyright (C) 2025 Victron Energy B.V.
 * See LICENSE.txt for license information.
*/

import QtTest
import QtQuick
import Victron.VenusOS
import QtQuick.Window

TestCase {
	id: root
	name: "QuantityObjectModelTest"
	when: windowShown

	component ListDelegate : Rectangle {
		width: 800
		height: 20
		border.width: 1

		Text { text: parent.objectName }
	}

	Window {
		width: 800
		height: 600
		visible: true

		Rectangle {
			anchors.fill: parent
			color: "yellow"

			ListView {
				id: viewA
				anchors.fill: parent
				model: QuantityObjectModel {
					id: quantityObjectModel

					QuantityObject { id: quantityObjectA1; object: sourceObjectA1 }   // use default key, which is "value"
					QuantityObject { id: quantityObjectA2; object: sourceObjectA2; key: "power" }
					QuantityObject { id: quantityObjectA3; object: sourceObjectA2; key: "current" }
					QuantityObject { id: quantityObjectA4; object: sourceObjectA2; key: "voltage" }
				}
				delegate: ListDelegate {
					required property int index
					required property QuantityObject quantityObject
					readonly property real numberValue: quantityObject.numberValue

					objectName: `viewADelegate ${index}`
				}

				QtObject {
					id: sourceObjectA1
					property real value: 1.23
				}

				QtObject {
					id: sourceObjectA2
					property real power: 4.56
					property real voltage: NaN
					property real current: 7.89
				}
			}
		}
	}

	function test_objects() {
		compare(viewA.model.objects.length, 4)
		compare(viewA.model.objects[0], quantityObjectA1)
		compare(viewA.model.objects[1], quantityObjectA2)
		compare(viewA.model.objects[2], quantityObjectA3)
		compare(viewA.model.objects[3], quantityObjectA4)
	}

	function test_filter_data() {
		return [
			// If no filter is applied, then all four quantities are visible, regardless of voltage value.
			{ filterType: QuantityObjectModel.NoFilter, voltage: NaN, modelCount: 4 },
			{ filterType: QuantityObjectModel.NoFilter, voltage: 987.654, modelCount: 4 },

			// If HasValue filter is set, and voltage=NaN, that value should be filtered out of the
			// QuantityObjectModel and should not be visible in the view.
			{ filterType: QuantityObjectModel.HasValue, voltage: NaN, modelCount: 3 },
			{ filterType: QuantityObjectModel.HasValue, voltage: 987.654, modelCount: 4 },
		]
	}

	function test_filter(data) {
		viewA.model.filterType = data.filterType
		sourceObjectA2.voltage = data.voltage
		viewA.forceLayout()

		const expectVoltage = data.modelCount > 3

		compare(viewA.count, data.modelCount)
		compare(viewA.model.count, data.modelCount)
		compare(viewA.model.objects.length, 4)

		compare(viewA.itemAtIndex(0).quantityObject, quantityObjectA1)
		compare(viewA.itemAtIndex(1).quantityObject, quantityObjectA2)
		compare(viewA.itemAtIndex(2).quantityObject, quantityObjectA3)
		if (expectVoltage) {
			compare(viewA.itemAtIndex(3).quantityObject, quantityObjectA4)
		}

		compare(viewA.itemAtIndex(0).numberValue, 1.23)
		compare(viewA.itemAtIndex(1).numberValue, 4.56)
		compare(viewA.itemAtIndex(2).numberValue, 7.89)
		if (expectVoltage) {
			compare(viewA.itemAtIndex(3).numberValue, data.voltage)
		}

		compare(viewA.itemAtIndex(0).index, 0)
		compare(viewA.itemAtIndex(1).index, 1)
		compare(viewA.itemAtIndex(2).index, 2)
		if (expectVoltage) {
			compare(viewA.itemAtIndex(3).index, 3)
		}
	}
}

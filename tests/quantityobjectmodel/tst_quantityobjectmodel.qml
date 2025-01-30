/*
 * Copyright (C) 2024 Victron Energy B.V.
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
					QuantityObject { id: quantityObjectA3; object: sourceObjectA2; key: "voltage"; objectName: key }
					QuantityObject { id: quantityObjectA4; object: sourceObjectA2; key: "current"; objectName: key }
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

	function test_values() {
		// Overall there are four objects in the model's "objects" list.
		compare(viewA.model.objects.length, 4)
		compare(viewA.model.objects[0], quantityObjectA1)
		compare(viewA.model.objects[1], quantityObjectA2)
		compare(viewA.model.objects[2], quantityObjectA3)
		compare(viewA.model.objects[3], quantityObjectA4)

		// Since voltage=NaN, that value should be filtered out of the QuantityObjectModel and
		// should not be visible in the view.
		compare(viewA.count, 3)
		compare(viewA.model.count, 3)

		compare(viewA.itemAtIndex(0).quantityObject, quantityObjectA1)
		compare(viewA.itemAtIndex(1).quantityObject, quantityObjectA2)
		compare(viewA.itemAtIndex(2).quantityObject, quantityObjectA4)

		compare(viewA.itemAtIndex(0).numberValue, 1.23)
		compare(viewA.itemAtIndex(1).numberValue, 4.56)
		compare(viewA.itemAtIndex(2).numberValue, 7.89)

		compare(viewA.itemAtIndex(0).index, 0)
		compare(viewA.itemAtIndex(1).index, 1)
		compare(viewA.itemAtIndex(2).index, 2)
	}

	function test_objectHasValueChange() {
		// If voltage is set to a valid value, it should appear in the model and view.
		sourceObjectA2.voltage = 987.654
		compare(viewA.model.objects.length, 4)
		viewA.forceLayout()
		compare(viewA.count, 4)
		compare(viewA.model.count, 4)

		compare(viewA.itemAtIndex(0).numberValue, 1.23)
		compare(viewA.itemAtIndex(1).numberValue, 4.56)
		compare(viewA.itemAtIndex(2).numberValue, 987.654)
		compare(viewA.itemAtIndex(3).numberValue, 7.89)

		compare(viewA.itemAtIndex(0).index, 0)
		compare(viewA.itemAtIndex(1).index, 1)
		compare(viewA.itemAtIndex(2).index, 2)
		compare(viewA.itemAtIndex(3).index, 3)

		// Reset the test value.
		sourceObjectA2.voltage = NaN
		viewA.forceLayout()
	}
}

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
	name: "AllowedItemModelTest"
	when: windowShown

	component ListDelegate : ListItem {
		text: objectName
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
				model: AllowedItemModel {
					ListDelegate {
						id: itemA1
						objectName: "itemA1"
					}
					ListDelegate {
						id: itemA2
						objectName: "itemA2"
					}
					ListDelegate {
						id: itemA3
						objectName: "itemA3"
					}
				}
			}

			ListView {
				id: viewB
				anchors.fill: parent
				model: AllowedItemModel {
					ListDelegate {
						id: itemB1
						property bool shouldBeAllowed
						objectName: "itemB1"
						allowed: shouldBeAllowed
					}
					ListDelegate {
						id: itemB2
						objectName: "itemB2"
					}
					ListDelegate {
						id: itemB3
						objectName: "itemB3"
					}
					ListDelegate {
						id: itemB4
						objectName: "itemB4"
						allowed: false
					}
					ListDelegate {
						id: itemB5
						objectName: "itemB5"
					}
				}
			}

			ListView {
				id: viewWithQObjects
				anchors.fill: parent
				model: AllowedItemModel {
					QtObject { id: viewWithQObjects_object1 }
					ListDelegate { id: viewWithQObjects_object2 }
				}
			}

			ListView {
				id: viewWithNestedItems
				anchors.fill: parent
				model: AllowedItemModel {
					Column {
						id: viewWithNestedItems_item1
						width: parent ? parent.width : 0
						ListDelegate {}
						ListDelegate {}
					}
					ListDelegate { id: viewWithNestedItems_item2 }
				}
			}
		}
	}

	function test_allItemsAllowed() {
		const allowedItemModel = viewA.model
		const allItemsList = viewA.model.sourceModel

		compare(allItemsList.length, 3)
		compare(allItemsList[0], itemA1)
		compare(allItemsList[1], itemA2)
		compare(allItemsList[2], itemA3)

		compare(allowedItemModel.count, 3)
		compare(viewA.count, 3)
		compare(allowedItemModel.get(0), itemA1)
		compare(allowedItemModel.get(1), itemA2)
		compare(allowedItemModel.get(2), itemA3)
	}

	function test_someItemsAllowed() {
		const allowedItemModel = viewB.model
		const allItemsList = viewB.model.sourceModel

		compare(allItemsList.length, 5)
		compare(allItemsList[0], itemB1)
		compare(allItemsList[1], itemB2)
		compare(allItemsList[2], itemB3)
		compare(allItemsList[3], itemB4)
		compare(allItemsList[4], itemB5)

		// The two non-allowed items should be filtered out
		compare(allowedItemModel.count, 3)
		compare(viewB.count, 3)
		compare(allowedItemModel.get(0), itemB2)
		compare(allowedItemModel.get(1), itemB3)
		compare(allowedItemModel.get(2), itemB5)
		verify(!allowedItemModel.get(3))
		verify(!allowedItemModel.get(4))

		// Test that the model is updated if an item becomes allowed by forcing allowed=true.
		itemB4.allowed = true
		compare(allowedItemModel.count, 4)
		compare(viewB.count, 4)
		compare(allowedItemModel.get(0), itemB2)
		compare(allowedItemModel.get(1), itemB3)
		compare(allowedItemModel.get(2), itemB4)
		compare(allowedItemModel.get(3), itemB5)

		// Test that the model is updated if an item becomes allowed by updating a binding.
		itemB1.shouldBeAllowed = true
		compare(allowedItemModel.count, 5)
		compare(viewB.count, 5)
		compare(allowedItemModel.get(0), itemB1)
		compare(allowedItemModel.get(1), itemB2)
		compare(allowedItemModel.get(2), itemB3)
		compare(allowedItemModel.get(3), itemB4)
		compare(allowedItemModel.get(4), itemB5)
	}

	function test_itemsVisibilityChanges() {
		const allowedItemModel = viewA.model
		const allItemsList = viewA.model.sourceModel

		// Hide all items
		compare(allItemsList.length, 3)
		compare(allowedItemModel.count, 3)
		for (let i = 0; i < 3; ++i) {
			allItemsList[i].allowed = false
		}
		compare(allItemsList.length, 3)
		compare(allowedItemModel.count, 0)
		compare(viewA.count, 0)

		// Make the 2nd source item allowed, so it becomes the 1st item in the AllowedItemModel.
		allItemsList[1].allowed = true
		compare(allowedItemModel.count, 1)
		compare(viewA.count, 1)
		compare(allowedItemModel.get(0), itemA2)

		// Make the 1st source item allowed, so it becomes the 1st item in the AllowedItemModel.
		allItemsList[0].allowed = true
		compare(allowedItemModel.count, 2)
		compare(viewA.count, 2)
		compare(allowedItemModel.get(0), itemA1)
		compare(allowedItemModel.get(1), itemA2)

		// Make the 1st source item inallowed again
		allItemsList[0].allowed = false
		compare(allowedItemModel.count, 1)
		compare(viewA.count, 1)
		compare(allowedItemModel.get(0), itemA2)

		// Make the 3rd item allowed, so it becomes the 2nd item in the AllowedItemModel.
		allItemsList[2].allowed = true
		compare(allowedItemModel.count, 2)
		compare(viewA.count, 2)
		compare(allowedItemModel.get(0), itemA2)
		compare(allowedItemModel.get(1), itemA3)

		// Make the 1st item allowed again
		allItemsList[0].allowed = true
		compare(allowedItemModel.count, 3)
		compare(viewA.count, 3)
		compare(allowedItemModel.get(0), itemA1)
		compare(allowedItemModel.get(1), itemA2)
		compare(allowedItemModel.get(2), itemA3)
	}

	function test_viewWithQObjects() {
		// The sourceModel has both a QtObject and an Item
		compare(viewWithQObjects.model.sourceModel.length, 2)
		compare(viewWithQObjects.model.sourceModel[0], viewWithQObjects_object1)
		compare(viewWithQObjects.model.sourceModel[1], viewWithQObjects_object2)

		// The QtObject is filtered out of the view and the model.
		compare(viewWithQObjects.model.count, 1)
		compare(viewWithQObjects.model.get(0), viewWithQObjects_object2)
		compare(viewWithQObjects.count, 1)
	}

	function test_viewWithNestedItems() {
		compare(viewWithNestedItems.model.sourceModel.length, 2)
		compare(viewWithNestedItems.model.sourceModel[0], viewWithNestedItems_item1)
		compare(viewWithNestedItems.model.sourceModel[1], viewWithNestedItems_item2)

		// The Column should not be filtered out.
		compare(viewWithNestedItems.model.count, 2)
		compare(viewWithNestedItems.model.get(0), viewWithNestedItems_item1)
		compare(viewWithNestedItems.model.get(1), viewWithNestedItems_item2)
		compare(viewWithNestedItems.count, 2)
	}
}

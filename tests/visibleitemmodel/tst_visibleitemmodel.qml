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
	name: "visibleItemModelTest"
	when: windowShown

	component ListDelegate : Rectangle {
		// Mimic the preferredVisible + effectiveVisible provided by List Item
		property bool preferredVisible: true
		readonly property bool effectiveVisible: preferredVisible

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
				model: VisibleItemModel {
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
				model: VisibleItemModel {
					ListDelegate {
						id: itemB1
						property bool shouldBeVisible
						objectName: "itemB1"
						preferredVisible: shouldBeVisible
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
						preferredVisible: false
					}
					ListDelegate {
						id: itemB5
						objectName: "itemB5"
					}
				}
			}

			ListView {
				id: viewWithNestedItems
				anchors.fill: parent
				model: VisibleItemModel {
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

	function test_allItemsVisible() {
		const visibleItemModel = viewA.model
		const allItemsList = viewA.model.sourceModel

		compare(allItemsList.length, 3)
		compare(allItemsList[0], itemA1)
		compare(allItemsList[1], itemA2)
		compare(allItemsList[2], itemA3)

		compare(visibleItemModel.count, 3)
		compare(viewA.count, 3)
		compare(visibleItemModel.get(0), itemA1)
		compare(visibleItemModel.get(1), itemA2)
		compare(visibleItemModel.get(2), itemA3)
	}

	function test_someItemsVisible() {
		const visibleItemModel = viewB.model
		const allItemsList = viewB.model.sourceModel

		compare(allItemsList.length, 5)
		compare(allItemsList[0], itemB1)
		compare(allItemsList[1], itemB2)
		compare(allItemsList[2], itemB3)
		compare(allItemsList[3], itemB4)
		compare(allItemsList[4], itemB5)

		// The two non-visible items should be filtered out
		compare(visibleItemModel.count, 3)
		compare(viewB.count, 3)
		compare(visibleItemModel.get(0), itemB2)
		compare(visibleItemModel.get(1), itemB3)
		compare(visibleItemModel.get(2), itemB5)
		verify(!visibleItemModel.get(3))
		verify(!visibleItemModel.get(4))

		// Test that the model is updated if an item becomes visible by forcing preferredVisible=true.
		itemB4.preferredVisible = true
		compare(visibleItemModel.count, 4)
		compare(viewB.count, 4)
		compare(visibleItemModel.get(0), itemB2)
		compare(visibleItemModel.get(1), itemB3)
		compare(visibleItemModel.get(2), itemB4)
		compare(visibleItemModel.get(3), itemB5)

		// Test that the model is updated if an item becomes visible by updating a binding.
		itemB1.shouldBeVisible = true
		compare(visibleItemModel.count, 5)
		compare(viewB.count, 5)
		compare(visibleItemModel.get(0), itemB1)
		compare(visibleItemModel.get(1), itemB2)
		compare(visibleItemModel.get(2), itemB3)
		compare(visibleItemModel.get(3), itemB4)
		compare(visibleItemModel.get(4), itemB5)
	}

	function test_itemsVisibilityChanges() {
		const visibleItemModel = viewA.model
		const allItemsList = viewA.model.sourceModel

		// Hide all items
		compare(allItemsList.length, 3)
		compare(visibleItemModel.count, 3)
		for (let i = 0; i < 3; ++i) {
			allItemsList[i].preferredVisible = false
		}
		compare(allItemsList.length, 3)
		compare(visibleItemModel.count, 0)
		compare(viewA.count, 0)

		// Make the 2nd source item visible, so it becomes the 1st item in the visibleItemModel.
		allItemsList[1].preferredVisible = true
		compare(visibleItemModel.count, 1)
		compare(viewA.count, 1)
		compare(visibleItemModel.get(0), itemA2)

		// Make the 1st source item visible, so it becomes the 1st item in the visibleItemModel.
		allItemsList[0].preferredVisible = true
		compare(visibleItemModel.count, 2)
		compare(viewA.count, 2)
		compare(visibleItemModel.get(0), itemA1)
		compare(visibleItemModel.get(1), itemA2)

		// Make the 1st source item visible again
		allItemsList[0].preferredVisible = false
		compare(visibleItemModel.count, 1)
		compare(viewA.count, 1)
		compare(visibleItemModel.get(0), itemA2)

		// Make the 3rd item visible, so it becomes the 2nd item in the visibleItemModel.
		allItemsList[2].preferredVisible = true
		compare(visibleItemModel.count, 2)
		compare(viewA.count, 2)
		compare(visibleItemModel.get(0), itemA2)
		compare(visibleItemModel.get(1), itemA3)

		// Make the 1st item visible again
		allItemsList[0].preferredVisible = true
		compare(visibleItemModel.count, 3)
		compare(viewA.count, 3)
		compare(visibleItemModel.get(0), itemA1)
		compare(visibleItemModel.get(1), itemA2)
		compare(visibleItemModel.get(2), itemA3)
	}

	function test_viewWithNestedItems() {
		compare(viewWithNestedItems.model.sourceModel.length, 2)
		compare(viewWithNestedItems.model.sourceModel[0], viewWithNestedItems_item1)
		compare(viewWithNestedItems.model.sourceModel[1], viewWithNestedItems_item2)

		// The Column should not be filtered out, as it does not have a preferredVisible property.
		compare(viewWithNestedItems.model.count, 2)
		compare(viewWithNestedItems.model.get(0), viewWithNestedItems_item1)
		compare(viewWithNestedItems.model.get(1), viewWithNestedItems_item2)
		compare(viewWithNestedItems.count, 2)
	}
}

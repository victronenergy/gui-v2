/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import QtTest

TestCase {
	name: "FastUtilsTest"

	Page {
		id: page

		Item {
			id: nestedItem

			Instantiator {
				id: nestedInstantiator
				model: 0
				delegate: QtObject {}
			}
		}
	}

	QtObject {
		id: orphan
	}

	Component {
		id: incubatedPage

		Item {
			property alias repeater: innerRepeater

			Repeater {
				id: innerRepeater

				model: 8
				// Repeater releases a non-Item delegate. That release during
				// async incubation is the objectRef assert, so this must be an Item.
				delegate: Item {
					required property int index
					width: 1
					height: 1
				}
			}
		}
	}

	Loader {
		id: asyncLoader

		asynchronous: true
		active: false
		sourceComponent: incubatedPage
	}

	function test_containingPage_fromNestedInstantiator() {
		compare(FastUtils.containingPage(nestedInstantiator), page)
	}

	function test_containingPage_fromNestedItem() {
		compare(FastUtils.containingPage(nestedItem), page)
	}

	function test_containingPage_fromPage() {
		compare(FastUtils.containingPage(page), page)
	}

	function test_containingPage_unrelatedObject() {
		compare(FastUtils.containingPage(orphan), null)
	}

	function test_containingPage_null() {
		compare(FastUtils.containingPage(null), null)
	}

	function test_drainIncubators_null() {
		FastUtils.drainIncubators(null)
	}

	function test_drainIncubators_pageWithoutIncubators() {
		compare(FastUtils.drainIncubators(page), true)
	}

	function test_drainIncubators_completesLoadingLoaderBeforeSetModel() {
		// Adopt the window incubation controller before the load starts.
		compare(FastUtils.drainIncubators(asyncLoader), true)
		asyncLoader.active = true
		// rebuildUi() hits this same Loading-and-null-item state.
		compare(asyncLoader.status, Loader.Loading)
		verify(asyncLoader.item === null)
		compare(FastUtils.drainIncubators(asyncLoader), true)
		compare(asyncLoader.status, Loader.Ready)
		verify(asyncLoader.item !== null)
		// count is the model size, not proof that delegates finished.
		compare(asyncLoader.item.repeater.count, 8)
		verify(asyncLoader.item.repeater.itemAt(0) !== null)
		verify(asyncLoader.item.repeater.itemAt(7) !== null)
		asyncLoader.item.repeater.model = 3
		compare(asyncLoader.item.repeater.count, 3)
		verify(asyncLoader.item.repeater.itemAt(0) !== null)
		verify(asyncLoader.item.repeater.itemAt(2) !== null)
		asyncLoader.active = false
	}

	function cleanup() {
		asyncLoader.active = false
	}
}

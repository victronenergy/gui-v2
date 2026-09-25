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
		FastUtils.drainIncubators(page)
	}
}

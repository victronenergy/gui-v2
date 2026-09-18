/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtTest
import Victron.VenusOS

TestCase {
	id: root
	name: "QuantityCaption"
	when: windowShown
	width: 800
	height: 600
	visible: true
	property int originalScreenSize

	function initTestCase() {
		originalScreenSize = Theme.screenSize
	}

	function cleanup() {
		Theme.screenSize = originalScreenSize
	}

	Component {
		id: captionComponent
		TwoLabelQuantityRowLayout {
			width: 600
			primaryText: "Voltage"
			model: QuantityObjectModel {
				QuantityObject { unit: VenusOS.Units_Volt_DC; defaultValue: 12.3 }
			}
		}
	}

	function test_captionLifecycle_data() {
		return [
			{ tag: "five-inch", screenSize: Theme.FiveInch },
			{ tag: "seven-inch", screenSize: Theme.SevenInch },
			{ tag: "portrait", screenSize: Theme.Portrait },
		]
	}

	function test_captionLifecycle(data) {
		Theme.screenSize = data.screenSize
		const item = createTemporaryObject(captionComponent, root)
		verify(item)
		compare(item.captionLabel, null)
		compare(item.children.length, 2)
		item.captionText = "Caption"
		verify(item.captionLabel)
		compare(item.captionLabel.text, "Caption")
		item.captionText = "Changed caption"
		compare(item.captionLabel.text, "Changed caption")
		item.width = 300
		compare(item.captionLabel.width, 300)
		const previousCaption = item.captionLabel
		item.captionText = ""
		compare(item.captionLabel, null)
		compare(previousCaption.visible, false)
		item.captionText = "Recreated caption"
		verify(item.captionLabel)
		wait(0)
		compare(item.captionLabel.text, "Recreated caption")
		compare(item.children.length, 3)
	}

	function test_initialCaption() {
		const item = createTemporaryObject(captionComponent, root, { captionText: "Initial caption" })
		verify(item)
		verify(item.captionLabel)
		compare(item.captionLabel.text, "Initial caption")
		compare(item.children.length, 3)
	}
}

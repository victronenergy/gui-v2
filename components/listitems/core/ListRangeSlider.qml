/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListItem {
	id: root

	readonly property alias firstDataItem: firstDataItem
	readonly property alias secondDataItem: secondDataItem

	readonly property bool dataValid: firstDataItem.valid && secondDataItem.valid
	readonly property alias slider: slider

	// Optional functions that convert to/from the VeQuickItem values.
	property var toSourceValue: undefined
	property var fromSourceValue: undefined

	interactive: (firstDataItem.uid === "" || firstDataItem.valid) &&
				 (secondDataItem.uid === "" || secondDataItem.valid)

	rightPadding: 0
	content.children: [
		SettingsRangeSlider {
			id: slider

			enabled: root.clickable
			width: Theme.geometry_listItem_slider_width
			first.value: {
				const v = isNaN(firstDataItem.value) ? 0 : firstDataItem.value
				return root.fromSourceValue !== undefined ? root.fromSourceValue(v) : v
			}
			second.value: {
				const v = isNaN(secondDataItem.value) ? 0 : secondDataItem.value
				return root.fromSourceValue !== undefined ? root.fromSourceValue(v) : v
			}
			from: {
				const v = firstDataItem.min || 0
				return root.fromSourceValue !== undefined ? root.fromSourceValue(v) : v
			}
			to: {
				const v = secondDataItem.max || 100
				return root.fromSourceValue !== undefined ? root.fromSourceValue(v) : v
			}

			Connections {
				target: slider.first
				function onPressedChanged() {
					// Update data value when mouse is released, to avoid spamming data changes.
					if (!slider.first.pressed && firstDataItem.uid.length > 0) {
						const v = root.toSourceValue !== undefined ? root.toSourceValue(slider.first.value) : slider.first.value
						firstDataItem.setValue(v)
					}
				}
			}

			Connections {
				target: slider.second
				function onPressedChanged() {
					// Update data value when mouse is released, to avoid spamming data changes.
					if (!slider.second.pressed && secondDataItem.uid.length > 0) {
						const v = root.toSourceValue !== undefined ? root.toSourceValue(slider.second.value) : slider.second.value
						secondDataItem.setValue(v)
					}
				}
			}
		}
	]

	// clicked() signal is emitted when Key_Space is pressed.
	onClicked: slider.focus = true

	Keys.onPressed: (event) => {
		switch (event.key) {
		case Qt.Key_Escape:
		case Qt.Key_Return:
		case Qt.Key_Enter:
			slider.focus = false
			break
		}
	}
	Keys.enabled: Global.keyNavigationEnabled

	VeQuickItem {
		id: firstDataItem
	}

	VeQuickItem {
		id: secondDataItem
	}
}

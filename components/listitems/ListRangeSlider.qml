/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListItem {
	id: root

	property alias firstDataSource: firstDataPoint.source
	readonly property alias firstDataValue: firstDataPoint.value
	readonly property alias firstDataValid: firstDataPoint.valid
	readonly property alias firstDataSeen: firstDataPoint.seen
	property alias firstDataInvalidate: firstDataPoint.invalidate
	function setFirstDataValue(v) { firstDataPoint.setValue(v) }

	property alias secondDataSource: secondDataPoint.source
	readonly property alias secondDataValue: secondDataPoint.value
	readonly property alias secondDataValid: secondDataPoint.valid
	readonly property alias secondDataSeen: secondDataPoint.seen
	property alias secondDataInvalidate: secondDataPoint.invalidate
	function setSecondDataValue(v) { secondDataPoint.setValue(v) }

	readonly property bool dataValid: firstDataValid && secondDataValid
	readonly property alias slider: slider

	// Optional functions that convert to/from the DataPoint values.
	property var toSourceValue: undefined
	property var fromSourceValue: undefined

	enabled: userHasWriteAccess
			 && (firstDataSource === "" || firstDataValid)
			 && (secondDataSource === "" || secondDataValid)

	content.anchors.rightMargin: 0
	content.children: [
		SettingsRangeSlider {
			id: slider

			width: Theme.geometry.listItem.slider.width
			first.value: {
				const v = isNaN(firstDataPoint.value) ? 0 : firstDataPoint.value
				return root.fromSourceValue !== undefined ? root.fromSourceValue(v) : v
			}
			second.value: {
				const v = isNaN(secondDataPoint.value) ? 0 : secondDataPoint.value
				return root.fromSourceValue !== undefined ? root.fromSourceValue(v) : v
			}
			from: {
				const v = firstDataPoint.min || 0
				return root.fromSourceValue !== undefined ? root.fromSourceValue(v) : v
			}
			to: {
				const v = secondDataPoint.max || 0
				return root.fromSourceValue !== undefined ? root.fromSourceValue(v) : v
			}

			Connections {
				target: slider.first
				function onPressedChanged() {
					// Update data value when mouse is released, to avoid spamming data changes.
					if (!slider.first.pressed && firstDataPoint.source.length > 0) {
						const v = root.toSourceValue !== undefined ? root.toSourceValue(slider.first.value) : slider.first.value
						firstDataPoint.setValue(v)
					}
				}
			}

			Connections {
				target: slider.second
				function onPressedChanged() {
					// Update data value when mouse is released, to avoid spamming data changes.
					if (!slider.second.pressed && secondDataPoint.source.length > 0) {
						const v = root.toSourceValue !== undefined ? root.toSourceValue(slider.second.value) : slider.second.value
						secondDataPoint.setValue(v)
					}
				}
			}
		}
	]

	DataPoint {
		id: firstDataPoint

		hasMin: valid
		hasMax: valid
	}

	DataPoint {
		id: secondDataPoint

		hasMin: valid
		hasMax: valid
	}
}

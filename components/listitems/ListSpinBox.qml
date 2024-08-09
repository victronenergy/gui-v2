/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListButton {
	id: root

	readonly property alias dataItem: dataItem
	property alias value: rangeModel.value
	property string suffix
	property int decimals
	property int from: !isNaN(dataItem.min) ? dataItem.min : 0
	property int to: !isNaN(dataItem.max) ? dataItem.max : Global.int32Max / Math.pow(10, decimals) // qml int is a signed 32 bit value
	property real stepSize: 1
	property var presets: []

	property var _numberSelector

	signal maxValueReached()
	signal minValueReached()
	signal selectorAccepted(newValue: var)

	button.text: value === undefined ? "--" : Units.formatNumber(value, decimals) + root.suffix
	enabled: dataItem.uid === "" || dataItem.isValid

	onClicked: Global.dialogLayer.open(numberSelectorComponent, {value: value})

	RangeModel {
		id: rangeModel
		minimumValue: root.from
		maximumValue: root.to
		value: dataItem.isValid ? dataItem.value : 0
	}

	Component {
		id: numberSelectorComponent

		NumberSelectorDialog {
			title: root.text
			suffix: root.suffix
			decimals: root.decimals
			from: root.from
			to: root.to
			stepSize: root.stepSize
			presets: root.presets

			onAccepted: {
				if (dataItem.uid.length > 0) {
					dataItem.setValue(value)
				} else {
					root.value = value
				}
				root.selectorAccepted(value)
			}
			onMinValueReached: root.minValueReached()
			onMaxValueReached: root.maxValueReached()
		}
	}

	VeQuickItem {
		id: dataItem
	}
}

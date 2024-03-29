/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListButton {
	id: root

	readonly property alias dataItem: dataItem
	property real value: !dataItem.isValid ? 0 : dataItem.value
	property string suffix
	property int decimals
	property int from: !isNaN(dataItem.min) ? dataItem.min : 0
	property int to: !isNaN(dataItem.max) ? dataItem.max : 1000
	property real stepSize: 1
	property var presets: []

	property var _numberSelector

	signal maxValueReached()
	signal minValueReached()
	signal selectorAccepted(newValue: var)

	button.text: value === undefined ? "--" : value.toFixed(decimals) + root.suffix
	enabled: dataItem.uid === "" || dataItem.isValid

	onClicked: Global.dialogLayer.open(numberSelectorComponent, {value: value})

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

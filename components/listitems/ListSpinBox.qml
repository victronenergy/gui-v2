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
	// Number.MAX_SAFE_INTEGER === 9,007,199,254,740,991, which is less than C++ 64 bit max int 9,223,372,036,854,775,807, so should be safe to use for 'SpinBox.to'
	property int to: !isNaN(dataItem.max) ? dataItem.max : Number.MAX_SAFE_INTEGER
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

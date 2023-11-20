/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import "/components/Utils.js" as Utils

ListButton {
	id: root

	property alias dataSource: dataPoint.source
	readonly property alias dataValue: dataPoint.value
	readonly property alias dataValid: dataPoint.valid
	readonly property alias dataSeen: dataPoint.seen
	property alias dataInvalidate: dataPoint.invalidate
	function setDataValue(v) { dataPoint.setValue(v) }

	property real value: !dataValid ? 0 : dataValue
	property string suffix
	property int decimals
	property int from: !isNaN(dataPoint.min) ? dataPoint.min : 0
	property int to: !isNaN(dataPoint.max) ? dataPoint.max : 1000
	property real stepSize: 1
	property var presets: []

	property var _numberSelector

	signal maxValueReached()
	signal minValueReached()
	signal selectorAccepted(newValue: var)

	button.text: value === undefined ? "--" : Utils.toFloat(value, decimals) + root.suffix
	enabled: dataSource === "" || dataValid

	onClicked: {
		if (!_numberSelector) {
			_numberSelector = numberSelectorComponent.createObject(Global.dialogLayer)
		}
		_numberSelector.value = value
		_numberSelector.open()
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
				if (dataSource.length > 0) {
					dataPoint.setValue(value)
				} else {
					root.value = value
				}
				root.selectorAccepted(value)
			}
			onMinValueReached: root.minValueReached()
			onMaxValueReached: root.maxValueReached()
		}
	}

	DataPoint {
		id: dataPoint
	}
}

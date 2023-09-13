/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import Utils

ListButton {
	id: root

	property alias dataSource: dataPoint.source
	readonly property alias dataValue: dataPoint.value
	readonly property alias dataValid: dataPoint.valid
	function setDataValue(v) { dataPoint.setValue(v) }

	property real value: !dataValid ? 0 : dataValue
	property string suffix
	property int decimals
	property int from: dataPoint.hasMin ? dataPoint.min || 0 : 0
	property int to: dataPoint.hasMax ? dataPoint.max || 1000 : 1000
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
		hasMin: true
		hasMax: true
	}
}

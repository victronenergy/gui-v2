/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "/components/Utils.js" as Utils

SettingsListButton {
	id: root

	property alias source: dataPoint.source
	property alias dataPoint: dataPoint

	property real value: dataPoint.value === undefined ? 0 : dataPoint.value
	property string suffix
	property int decimals
	property int from: dataPoint.hasMin ? dataPoint.min || 0 : 0
	property int to: dataPoint.hasMax ? dataPoint.max || 100 : 100
	property real stepSize: 1

	property var _numberSelector

	button.text: value === undefined ? "--" : Utils.toFloat(value, decimals) + root.suffix

	onClicked: {
		if (!_numberSelector) {
			_numberSelector = numberSelectorComponent.createObject(root)
		}
		_numberSelector.value = value
		_numberSelector.open()
	}

	Component {
		id: numberSelectorComponent

		NumberSelectorDialog {
			parent: Global.dialogManager
			title: root.text
			suffix: root.suffix
			decimals: root.decimals
			from: root.from
			to: root.to
			stepSize: root.stepSize

			onAccepted: {
				if (source.length > 0) {
					dataPoint.setValue(value)
				} else {
					root.value = value
				}
			}
		}
	}

	DataPoint {
		id: dataPoint
		hasMin: true
		hasMax: true
	}
}

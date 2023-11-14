/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Slider {
	id: root

	property alias dataSource: dataPoint.source
	readonly property alias dataValue: dataPoint.value
	readonly property alias dataValid: dataPoint.valid
	readonly property alias dataSeen: dataPoint.seen
	property alias dataInvalidate: dataPoint.invalidate
	function setDataValue(v) { dataPoint.setValue(v) }

	property real _emittedValue

	signal valueChanged(value: real)

	implicitWidth: parent ? parent.width : 0
	implicitHeight: Theme.geometry.listItem.height
	live: false
	from: dataPoint.min !== undefined ? dataPoint.min : 0
	to: dataPoint.max !== undefined ? dataPoint.max : 1
	stepSize: (to-from) / Theme.geometry.listItem.slider.stepDivsion
	value: to > from && dataValid ? dataValue : 0
	enabled: dataSource === "" || dataValid

	onPressedChanged: {
		if (root.value !== root._emittedValue) {
			root._emittedValue = root.value
			root.valueChanged(root.value)
		}
	}

	onValueChanged: function(value) {
		if (dataSource.length > 0) {
			dataPoint.setValue(value)
		}
	}

	leftPadding: Theme.geometry.listItem.content.horizontalMargin
		+ Theme.geometry.listItem.slider.button.size
		+ Theme.geometry.listItem.slider.spacing
	rightPadding: Theme.geometry.listItem.content.horizontalMargin
		+ Theme.geometry.listItem.slider.button.size
		+ Theme.geometry.listItem.slider.spacing

	Button {
		id: minusButton
		anchors {
			verticalCenter: parent.verticalCenter
			left: parent.left
			leftMargin: Theme.geometry.listItem.content.horizontalMargin
		}
		icon.width: Theme.geometry.listItem.slider.button.size
		icon.height: Theme.geometry.listItem.slider.button.size
		icon.source: "/images/icon_minus.svg"
		backgroundColor: "transparent"

		onClicked: {
			if (root.value > root.from) {
				root.decrease()
				root._emittedValue = root.value
				root.valueChanged(root.value)
			}
		}
	}

	Button {
		anchors {
			verticalCenter: parent.verticalCenter
			right: parent.right
			rightMargin: Theme.geometry.listItem.content.horizontalMargin
		}
		icon.width: Theme.geometry.listItem.slider.button.size
		icon.height: Theme.geometry.listItem.slider.button.size
		icon.source: "/images/icon_plus.svg"
		backgroundColor: "transparent"

		onClicked: {
			if (root.value < root.to) {
				root.increase()
				root._emittedValue = root.value
				root.valueChanged(root.value)
			}
		}
	}

	DataPoint {
		id: dataPoint

		hasMin: true
		hasMax: true
	}
}

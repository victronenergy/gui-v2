/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil

Slider {
	id: root

	readonly property alias dataItem: dataItem

	property real _emittedValue

	signal valueChanged(value: real)

	implicitWidth: parent ? parent.width : 0
	implicitHeight: Theme.geometry_listItem_height
	live: false
	from: dataItem.min !== undefined ? dataItem.min : 0
	to: dataItem.max !== undefined ? dataItem.max : 1
	stepSize: (to-from) / Theme.geometry_listItem_slider_stepDivsion
	value: to > from && dataItem.isValid ? dataItem.value : 0
	enabled: dataItem.uid === "" || dataItem.isValid

	onPressedChanged: {
		if (root.value !== root._emittedValue) {
			root._emittedValue = root.value
			root.valueChanged(root.value)
		}
	}

	onValueChanged: function(value) {
		if (dataItem.uid.length > 0) {
			dataItem.setValue(value)
		}
	}

	leftPadding: Theme.geometry_listItem_content_horizontalMargin
		+ Theme.geometry_listItem_slider_button_size
		+ Theme.geometry_listItem_slider_spacing
	rightPadding: Theme.geometry_listItem_content_horizontalMargin
		+ Theme.geometry_listItem_slider_button_size
		+ Theme.geometry_listItem_slider_spacing

	Button {
		id: minusButton
		anchors {
			verticalCenter: parent.verticalCenter
			left: parent.left
			leftMargin: Theme.geometry_listItem_content_horizontalMargin
		}
		icon.width: Theme.geometry_listItem_slider_button_size
		icon.height: Theme.geometry_listItem_slider_button_size
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
			rightMargin: Theme.geometry_listItem_content_horizontalMargin
		}
		icon.width: Theme.geometry_listItem_slider_button_size
		icon.height: Theme.geometry_listItem_slider_button_size
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

	VeQuickItem {
		id: dataItem
	}
}

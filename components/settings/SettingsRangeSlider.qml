/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

RangeSlider {
	id: root

	property int decimals
	property string suffix
	property real labelWidth: Theme.geometry.settings.battery.rangeSlider.labelWidth

	readonly property string _labelPlaceholderText: "" + to.toFixed(decimals) + suffix

	implicitWidth: parent ? parent.width : 0
	implicitHeight: Theme.geometry.listItem.height
	stepSize: (to-from) / Theme.geometry.listItem.slider.stepDivsion

	leftPadding: Theme.geometry.listItem.content.horizontalMargin
		+ labelWidth
		+ Theme.geometry.listItem.slider.spacing
	rightPadding: Theme.geometry.listItem.content.horizontalMargin
		+ labelWidth
		+ Theme.geometry.listItem.slider.spacing

	Label {
		anchors {
			verticalCenter: parent.verticalCenter
			left: parent.left
			leftMargin: Theme.geometry.listItem.content.horizontalMargin
		}
		width: root.labelWidth
		text: root.first.value.toFixed(root.decimals) + root.suffix
		horizontalAlignment: Text.AlignRight
		font.pixelSize: Theme.font.size.body2
		color: Theme.color.font.secondary
	}

	Label {
		anchors {
			verticalCenter: parent.verticalCenter
			right: parent.right
			rightMargin: Theme.geometry.listItem.content.horizontalMargin
		}
		width: root.labelWidth
		text: root.second.value.toFixed(root.decimals) + root.suffix
		font.pixelSize: Theme.font.size.body2
		color: Theme.color.font.secondary
	}
}

/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Templates as T
import QtQuick.Controls.impl as CP
import Victron.VenusOS

T.RangeSlider {
	id: root

	property color firstColor: "transparent"
	property color secondColor: "transparent"

	background: Rectangle {
		anchors {
			left: parent.left
			leftMargin: root.leftPadding
			top: parent.top
			topMargin: root.topPadding + root.availableHeight / 2 - height / 2
		}
		implicitWidth: 4 * Theme.geometry.switch.indicator.width
		implicitHeight: Theme.geometry.slider.groove.height
		width: root.availableWidth
		height: Theme.geometry.slider.groove.height
		radius: Theme.geometry.slider.groove.radius
		color: Theme.color.darkOk

		Rectangle {
			x: root.first.visualPosition * parent.width
			width: root.second.visualPosition * parent.width - x
			height: Theme.geometry.slider.groove.height
			color: Theme.color.ok
			radius: Theme.geometry.slider.groove.radius
		}
	}

	first.handle: ColorImage {
		anchors {
			left: parent.left
			leftMargin: root.leftPadding + root.first.visualPosition * (root.availableWidth - width)
			top: parent.top
			topMargin: root.topPadding + root.availableHeight / 2 - height / 2
		}
		width: Theme.geometry.switch.indicator.width
		height: Theme.geometry.switch.indicator.width
		source: "qrc:/images/switch_indicator.png"
		color: root.firstColor
	}

	second.handle: ColorImage {
		anchors {
			left: parent.left
			leftMargin: root.leftPadding + root.second.visualPosition * (root.availableWidth - width)
			top: parent.top
			topMargin: root.topPadding + root.availableHeight / 2 - height / 2
		}
		width: Theme.geometry.switch.indicator.width
		height: Theme.geometry.switch.indicator.width
		source: "qrc:/images/switch_indicator.png"
		color: root.secondColor
	}
}

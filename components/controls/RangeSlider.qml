/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls as C
import QtQuick.Controls.impl as CP
import Victron.VenusOS

C.RangeSlider {
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
		implicitWidth: 4 * Theme.geometry_switch_indicator_width
		implicitHeight: Theme.geometry_slider_groove_height
		width: root.availableWidth
		height: Theme.geometry_slider_groove_height
		radius: Theme.geometry_slider_groove_radius
		color: Theme.color_darkOk

		Rectangle {
			x: root.first.visualPosition * parent.width
			width: root.second.visualPosition * parent.width - x
			height: Theme.geometry_slider_groove_height
			color: Theme.color_ok
			radius: Theme.geometry_slider_groove_radius
		}
	}

	first.handle: CP.ColorImage {
		anchors {
			left: parent.left
			leftMargin: root.leftPadding + root.first.visualPosition * (root.availableWidth - width)
			top: parent.top
			topMargin: root.topPadding + root.availableHeight / 2 - height / 2
		}
		width: Theme.geometry_switch_indicator_width
		height: Theme.geometry_switch_indicator_width
		source: "qrc:/images/switch_indicator.png"
		color: root.firstColor
	}

	second.handle: CP.ColorImage {
		anchors {
			left: parent.left
			leftMargin: root.leftPadding + root.second.visualPosition * (root.availableWidth - width)
			top: parent.top
			topMargin: root.topPadding + root.availableHeight / 2 - height / 2
		}
		width: Theme.geometry_switch_indicator_width
		height: Theme.geometry_switch_indicator_width
		source: "qrc:/images/switch_indicator.png"
		color: root.secondColor
	}
}

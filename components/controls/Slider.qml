/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Controls as C
import QtQuick.Controls.impl as CP
import Victron.VenusOS

C.Slider {
	id: root

	property alias grooveColor: backgroundRect.color
	property alias highlightColor: highlightRect.color
	property alias showHandle: handleImg.visible

	implicitHeight: Math.max(background.implicitHeight, handle.implicitHeight)

	background: Rectangle {
		id: backgroundRect

		anchors {
			left: parent.left
			leftMargin: parent.leftPadding
			right: parent.right
			rightMargin: parent.rightPadding
			verticalCenter: parent.verticalCenter
		}

		implicitWidth: 4*Theme.geometry.switch.indicator.width // suitably small.
		implicitHeight: Theme.geometry.slider.groove.height
		width: root.availableWidth
		height: Theme.geometry.slider.groove.height
		radius: Theme.geometry.slider.groove.radius
		color: Theme.color.darkOk

		Rectangle {
			id: highlightRect

			width: root.visualPosition * parent.width
			height: Theme.geometry.slider.groove.height
			color: Theme.color.ok
			radius: Theme.geometry.slider.groove.radius
		}
	}

	handle: Image {
		id: handleImg

		x: root.leftPadding + root.visualPosition * (root.availableWidth - width)
		y: root.topPadding + root.availableHeight / 2 - height / 2 + Theme.geometry.switch.indicator.shadowOffset
		width: Theme.geometry.switch.indicator.width
		height: Theme.geometry.switch.indicator.width
		source: "qrc:/images/switch_indicator.png"
	}
}

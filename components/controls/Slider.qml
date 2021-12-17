/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Controls as C
import QtQuick.Controls.impl as CP
import Victron.VenusOS

C.Slider {
	id: root

	implicitHeight: Math.max(background.implicitHeight, handle.implicitHeight)
	background: Rectangle {
		anchors {
			top: parent.top
			topMargin: parent.height/3
			bottom: parent.bottom
			bottomMargin: parent.height/3
			left: parent.left
			leftMargin: parent.leftPadding
			right: parent.right
			rightMargin: parent.rightPadding
		}

		implicitWidth: 4*Theme.geometry.slider.handle.width // suitably small.
		implicitHeight: Theme.geometry.slider.groove.height
		width: root.availableWidth
		height: implicitHeight
		radius: Theme.geometry.slider.groove.radius
		color: Theme.color.slider.groove.background

		Rectangle {
			width: root.visualPosition * parent.width
			height: parent.height
			color: Theme.color.slider.background
			radius: Theme.geometry.slider.groove.radius
		}
	}

	handle: Rectangle {
		x: root.leftPadding + root.visualPosition * (root.availableWidth - width)
		y: root.topPadding + root.availableHeight / 2 - height / 2
		height: parent.height
		width: height
		implicitWidth: Theme.geometry.slider.handle.width
		implicitHeight: implicitWidth
		radius: implicitWidth/2
		color: Theme.color.font.primary
	}
}

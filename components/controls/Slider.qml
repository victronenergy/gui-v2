/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Controls as C
import QtQuick.Controls.impl as CP
import Victron.VenusOS

C.Slider {
	id: root

	property color grooveColor: Theme.color.slider.groove.background
	property color highlightColor: Theme.color.slider.background
	property color indicatorColor: Theme.color.font.primary
	property int grooveVerticalPadding: height / 3
	property bool showHandle: true

	implicitHeight: Math.max(background.implicitHeight, handle.implicitHeight)
	background: Rectangle {
		anchors {
			top: parent.top
			topMargin: root.grooveVerticalPadding
			bottom: parent.bottom
			bottomMargin: root.grooveVerticalPadding
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
		color: grooveColor

		Rectangle {
			width: root.visualPosition * parent.width
			height: parent.height
			color: highlightColor
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
		color: indicatorColor
		visible: root.showHandle
	}
}

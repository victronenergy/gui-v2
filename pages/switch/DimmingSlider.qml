/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Templates as T
import QtQuick.Controls as C
import QtQuick.Controls.impl as CP
import Victron.VenusOS
import QtQuick.Effects as Effects

T.Slider {
	id: root

	property alias grooveColor: backgroundRect.color
	property alias highlightColor: highlightRect.color
	property alias radius: backgroundRect.radius
	property alias showHandle: sliderHandle.visible
	property bool animationEnabled
	property bool buttonClickedEnabled: false
	signal buttonClicked ()

	implicitHeight: Math.max(implicitBackgroundHeight, implicitHandleHeight)
	MouseArea {
		id: mouseArea
		anchors.fill: parent
		onClicked:  (mouse)=> {
			if (buttonClickedEnabled) root.buttonClicked()
		}
		onPressed: (mouse)=> {
			if (buttonClickedEnabled) mouse.accepted = (mouseX < sliderHandle.x) || (mouseX > (sliderHandle.x + sliderHandle.width))
		}
	}

	background: Rectangle {
		id: backgroundRect

		anchors {
			left: parent.left
			leftMargin: parent.leftPadding
			right: parent.right
			rightMargin: parent.rightPadding
			topMargin: parent.topPadding
			bottomMargin: parent.bottomPadding
			verticalCenter: parent.verticalCenter
		}

		width: root.availableWidth
		height: root.height
		radius: Theme.geometry_slider_groove_radius
		color: Theme.color_darkOk

		Rectangle {
			id: maskRect
			layer.enabled: true
			visible: false
			width: backgroundRect.width
			height: backgroundRect.height
			radius: backgroundRect.radius
			color: "black" // opacity mask, not visible.
		}

		Item {
			id: sourceItem
			visible: false
			width: parent.width
			height: parent.height

			Rectangle {
				id: highlightRect

				width: parent.width
				height: parent.height
				color: Theme.color_ok
				x: nextX
				readonly property real nextX: root.mirrored ? (backgroundRect.width - width*root.visualPosition)
					: (-backgroundRect.width + width*root.visualPosition)

				onNextXChanged: {
					if (!anim.running && root.animationEnabled) {
						anim.from = highlightRect.x
						// do a little dance to break any x binding...
						highlightRect.x = 0
						highlightRect.x = anim.from
						anim.to = highlightRect.nextX
						anim.start()
					}
				}

				XAnimator {
					id: anim
					target: highlightRect
					easing.type: Easing.InOutQuad
					duration: Theme.animation_briefPage_sidePanel_sliderValueChange_duration
				}
			}
		}

		Effects.MultiEffect {
			visible: true
			anchors.fill: parent
			maskEnabled: true
			maskSource: maskRect
			source: sourceItem
		}

	}

	handle: Rectangle {
		id: sliderHandle
		parent: sourceItem
		x: root.visible ? root.leftPadding + root.visualPosition * (root.availableWidth - width) : 0
		y: 0
		color: highlightRect.color
		width: 25
		height: root.height
		Text{
			x: parent.width / 2
			y: (parent.height - height) / 2
			color: "lightgrey"
			font.pixelSize: 30
			text:"..."
			rotation : 90
		}

	}
}

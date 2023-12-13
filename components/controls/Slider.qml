/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Templates as T
import QtQuick.Templates as C
import QtQuick.Controls.impl as CP
import Victron.VenusOS
import QtQuick.Effects as Effects

T.Slider {
	id: root

	property alias grooveColor: backgroundRect.color
	property alias highlightColor: highlightRect.color
	property alias showHandle: handleImg.visible
	property bool animationEnabled

	implicitHeight: Math.max(implicitBackgroundHeight, implicitHandleHeight)

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
				radius: backgroundRect.radius
				color: Theme.color.ok
				x: nextX

				// don't use a behavior on x
				// otherwise there can be a "jump" we receive receive two value updates in close succession.
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
					duration: Theme.animation.briefPage.sidePanel.sliderValueChange.duration
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

	handle: Image {
		id: handleImg

		x: visible ? root.leftPadding + root.visualPosition * (root.availableWidth - width) : 0
		y: visible ? root.topPadding + root.availableHeight / 2 - height / 2 + Theme.geometry.switch.indicator.shadowOffset : 0
		width: Theme.geometry.switch.indicator.width
		height: Theme.geometry.switch.indicator.width
		source: "qrc:/images/switch_indicator.png"
	}
}

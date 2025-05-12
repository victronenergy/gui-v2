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
	property alias showHandle: handleImg.visible
	property bool animationEnabled
	property Item maskSource: sourceItem

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

		implicitWidth: 4*Theme.geometry_switch_indicator_width // suitably small.
		implicitHeight: Theme.geometry_slider_groove_height
		width: root.availableWidth
		height: Theme.geometry_slider_groove_height
		radius: Theme.geometry_slider_groove_radius
		color: root.enabled ? Theme.color_darkOk : Theme.color_background_disabled

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
				color: root.enabled ? Theme.color_ok : Theme.color_switch_groove_disabled
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

	handle: Image {
		id: handleImg

		x: visible ? root.leftPadding + root.visualPosition * (root.availableWidth - width) : 0
		y: visible ? root.topPadding + root.availableHeight / 2 - height / 2 + Theme.geometry_switch_indicator_shadowOffset : 0
		width: Theme.geometry_switch_indicator_width
		height: Theme.geometry_switch_indicator_width
		source: "qrc:/images/switch_indicator.png"

		SliderHandleHighlight {
			handle: parent
			visible: Global.keyNavigationEnabled && root.activeFocus
		}
	}
}

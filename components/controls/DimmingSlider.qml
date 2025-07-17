/*
** Copyright (C) 2025 Victron Energy B.V.
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

	property color highlightColor: root.enabled ? Theme.color_ok : Theme.color_switch_groove_disabled
	property bool animationEnabled
	property Item maskSource: sourceItem

	signal clicked

	implicitHeight: Theme.geometry_dimmingSlider_height
	leftPadding: Theme.geometry_dimmingSlider_leftPadding

	background: Rectangle {
		width: root.availableWidth + root.leftPadding
		height: parent.height
		radius: Theme.geometry_slider_groove_radius
		color: root.enabled ? Theme.color_darkOk : Theme.color_background_disabled

		Rectangle {
			id: maskRect
			layer.enabled: true
			visible: false
			width: parent.width
			height: parent.height
			radius: parent.radius
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
				color: root.highlightColor
				x: nextX

				// don't use a behavior on x
				// otherwise there can be a "jump" we receive receive two value updates in close succession.
				readonly property real nextX: root.leftPadding +
						(-background.width + (width - root.leftPadding)*root.visualPosition)

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
		parent: root.maskSource
		width: 3*Theme.geometry_dimmingSlider_handle_width
		height: root.background.height
		x: root.visible ? root.leftPadding + root.visualPosition * (root.availableWidth - width) : 0
		color: root.highlightColor

		Rectangle {
			anchors.centerIn: parent
			width: Theme.geometry_dimmingSlider_handle_width
			height: parent.height - Theme.geometry_dimmingSlider_handle_vertical_padding*2
			color: Theme.color_white
			radius: Theme.geometry_dimmingSlider_handle_width/2
			opacity: handleHighlight.visible ? 0.3 : 1
		}
	}

	Label {
		anchors.left: parent.left
		anchors.leftMargin: Theme.geometry_dimmingSlider_label_leftMargin
		anchors.verticalCenter: parent.verticalCenter
		text: CommonWords.onOrOff(dimmingState.expectedValue)
		font.pixelSize: Theme.font_size_body2
		color: Theme.color_white
	}

	Rectangle {
		x: Theme.geometry_dimmingSlider_leftPadding - width
		anchors.verticalCenter: parent.verticalCenter
		width: Theme.geometry_dimmingSlider_seperator_width
		height: parent.height - Theme.geometry_dimmingSlider_seperator_vertical_padding*2
		radius: Theme.geometry_dimmingSlider_seperator_width/2
		color: Theme.color_white
		opacity: 0.6
	}

	// Declare this highlight outside the handle, else it is not shown due to the handle's mask source.
	SliderHandleHighlight {
		id: handleHighlight
		x: root.handle.x + root.handle.width/2 - (width / 2)
		y: (parent.height / 2) - (height / 2)
		width: root.handle.height - (2 * Theme.geometry_switch_groove_border_width)
		height: Theme.geometry_switch_groove_border_width
		visible: Global.keyNavigationEnabled && root.activeFocus
	}

	Rectangle {
		anchors.fill: parent
		color: "transparent"
		border.width: Theme.geometry_button_border_width
		border.color: Theme.color_ok
		radius: Theme.geometry_button_radius
	}

	MouseArea {
		anchors.fill: parent
		onClicked: {
			root.clicked()
		}
		onPressed: (mouse) => {
			mouse.accepted = (mouseX < root.leftPadding)
		}
	}
}

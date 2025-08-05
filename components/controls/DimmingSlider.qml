/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Templates as T
import Victron.VenusOS
import QtQuick.Effects as Effects

T.Slider {
	id: root

	property color highlightColor: root.enabled ? Theme.color_ok : Theme.color_switch_groove_disabled
	property bool animationEnabled
	property int state

	signal clicked

	implicitHeight: Theme.geometry_dimmingSlider_height

	// The Slider padding area is used to display the dimming slider state and provide
	// click handling for the control as well as the inherited slider behaviour.
	leftPadding: Math.ceil(textMetrics.tightBoundingRect.x + textMetrics.tightBoundingRect.width)
			+ (Theme.geometry_dimmingSlider_text_padding * 2)

	background: Rectangle {
		width: parent.width
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
						(-background.width + (width - root.leftPadding) * root.visualPosition)

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

		Rectangle {
			anchors.fill: parent
			color: "transparent"
			border.width: Theme.geometry_button_border_width
			border.color: root.enabled ? Theme.color_ok : Theme.color_gray4
			radius: Theme.geometry_button_radius
		}

		Label {
			id: stateLabel
			anchors.verticalCenter: parent.verticalCenter
			width: textMetrics.width + (Theme.geometry_dimmingSlider_text_padding * 2)

			text: root.state === 1 ? CommonWords.on : CommonWords.off
			horizontalAlignment: Text.AlignHCenter
			verticalAlignment: Text.AlignVCenter
			font.pixelSize: Theme.font_size_body1
			color: root.enabled ? Theme.color_button_down_text : Theme.color_gray6
		}

		Rectangle {
			anchors.right: stateLabel.right
			anchors.verticalCenter: parent.verticalCenter
			width: Theme.geometry_dimmingSlider_separator_width
			height: parent.height - (Theme.geometry_dimmingSlider_decorator_vertical_padding * 2)
			radius: Theme.geometry_dimmingSlider_separator_width / 2
			color: root.enabled ? Theme.color_slider_separator : Theme.color_background_disabled
		}

		SliderHandleHighlight {
			x: root.handle.x + (root.handle.width / 2) - (width / 2)
			y: (parent.height / 2) - (height / 2)
			width: root.handle.height - (Theme.geometry_dimmingSlider_decorator_vertical_padding * 2)
			height: Theme.geometry_dimmingSlider_indicator_width
			visible: Global.keyNavigationEnabled && root.activeFocus
		}
	}

	handle: Rectangle {
		parent: sourceItem
		width: Theme.geometry_dimmingSlider_handle_width
		height: root.background.height
		x: root.visible ? root.leftPadding + root.visualPosition * (root.availableWidth - width) : 0
		color: root.highlightColor

		Rectangle {
			anchors.centerIn: parent
			width: Theme.geometry_dimmingSlider_indicator_width
			height: parent.height - (Theme.geometry_dimmingSlider_decorator_vertical_padding * 2)
			color: Theme.color_white
			radius: (Theme.geometry_dimmingSlider_handle_width / 2)
		}
	}

	MouseArea {
		anchors {
			left: parent.left
			top: parent.top
			bottom: parent.bottom
		}
		width: root.leftPadding
		onClicked: root.clicked()
	}

	TextMetrics {
		id: textMetrics
		font.pixelSize: Theme.font_size_body1
		text: (CommonWords.on.length > CommonWords.off.length) ? CommonWords.on : CommonWords.off
	}
}

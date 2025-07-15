/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Templates as T
import QtQuick.Controls
import QtQuick.Shapes
import Victron.VenusOS
import QtQuick.Effects as Effects

T.Slider {
	id: root

	implicitHeight: Theme.geometry_dimmingSlider_height

	property int currentSliderDots: ((to - from) / stepSize) * Theme.geometry_temperatureSlider_dot_size * 2 > availableWidth
									? Math.floor(availableWidth / (4 * 2)) + 1 : ((to - from) / stepSize) + 1

	background: Rectangle {
		id: backgroundBorderRect

		gradient: Gradient {
			orientation: Qt.Horizontal
			GradientStop { position: 0.0; color: root.enabled ? Theme.color_temperatureslider_gradient_min_border : Theme.color_gray3 }
			GradientStop { position: 1.0; color: root.enabled ? Theme.color_temperatureslider_gradient_max_border : Theme.color_gray3 }
		}

		anchors {
			left: parent.left
			right: parent.right
			verticalCenter: parent.verticalCenter
		}

		implicitWidth: 4*Theme.geometry_switch_indicator_width // suitably small.
		height: root.height
		radius: Theme.geometry_slider_groove_radius

		Rectangle {
				id: backgroundRect
				anchors.fill: parent
				anchors.margins: Theme.geometry_button_border_width
				radius: Theme.geometry_slider_groove_radius - anchors.margins

				gradient: Gradient {
					orientation: Qt.Horizontal
					GradientStop { position: 0.0; color: root.enabled ? Theme.color_temperatureslider_gradient_min : Theme.color_background_disabled }
					GradientStop { position: 0.5; color: root.enabled ? Theme.color_temperatureslider_gradient_mid : Theme.color_background_disabled }
					GradientStop { position: 1.0; color: root.enabled ? Theme.color_temperatureslider_gradient_max : Theme.color_background_disabled  }
				}
		}

		Label {
			anchors.left: parent.left
			anchors.verticalCenter: parent.verticalCenter
			width: root.leftPadding
			text: CommonWords.min
			horizontalAlignment: Text.AlignHCenter
			font.pixelSize: Theme.font_size_body1
			color: root.enabled ? Theme.color_white : Theme.color_font_disabled
		}

		Label {
			anchors.right: parent.right
			anchors.verticalCenter: parent.verticalCenter
			width: root.rightPadding
			text: CommonWords.max
			horizontalAlignment: Text.AlignHCenter
			font.pixelSize: Theme.font_size_body1
			color: root.enabled ? Theme.color_white : Theme.color_font_disabled
		}
	}

	handle: Rectangle {
		id: handleItem
		x: root.visible ? root.leftPadding + root.visualPosition * (root.availableWidth - width) : 0
		y: root.height/2 - height/2
		width: Theme.geometry_temperatureSlider_indicator_size
		height: root.background.height - 6 * 2 // Padding
		radius: width / 2
		color: root.enabled ? Theme.color_white : Theme.color_font_disabled

		SliderHandleHighlight {
			id: handleHighlight
			x: parent.width / 2 - width / 2
			y: (parent.height / 2) - (height / 2)
			width: root.handle.height
			height: Theme.geometry_switch_groove_border_width * 2
			visible: Global.keyNavigationEnabled && root.activeFocus
		}
	}

	contentItem: Item {
		Repeater {
			model: currentSliderDots
			Dot {
				x: modelData * (root.availableWidth - width)/(currentSliderDots - 1)
				y: parent.height/2 - height/2
			}
		}
	}

	component Dot: Rectangle {
			width: Theme.geometry_temperatureSlider_dot_size
			height: Theme.geometry_temperatureSlider_dot_size
			radius: Theme.geometry_temperatureSlider_dot_size / 2
			color: root.enabled ? Theme.color_white : Theme.color_font_disabled
	}

	onPressedChanged: pressed && !Global.keyNavigationEnabled ? popup.open() : popup.close()

	Popup {
		id: popup
		x: handle.x + (handle.width / 2) - (width / 2)
		y: handle.y - height - 20 //Padding
		width: 80
		height: 60
		modal: true
		focus: true
		closePolicy: Popup.CloseOnReleaseOutside

		Overlay.modal: Rectangle {
			anchors.fill: parent
			color: "#00000000"  // transparent or no dimming
		}

		contentItem: Rectangle {
			anchors.fill: parent
			color: Theme.color_blue
			radius: 10

			Label {
				anchors.centerIn: parent
				font.pixelSize: Theme.font_size_h1
				text: root.value.toFixed(0) + "°"
				color: Theme.color_white
			}

			Shape {
				ShapePath {
					strokeWidth: 1
					strokeColor: Theme.color_blue
					fillColor: Theme.color_blue

					startX: popup.width/2; startY: popup.height

					PathLine {x: popup.width/2 - 15; y: popup.height}
					PathLine {x: popup.width/2; y: popup.height + 15}
					PathLine {x: popup.width/2 + 15; y: popup.height}
					PathLine {x: popup.width/2; y: popup.height}
				}
			}
		}
	}
}

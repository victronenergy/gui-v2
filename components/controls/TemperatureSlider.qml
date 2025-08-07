/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Templates as T
import QtQuick.Controls
import QtQuick.Controls.impl as CP
import QtQuick.Shapes
import Victron.VenusOS
import QtQuick.Effects as Effects

T.Slider {
	id: root

	// Determine the number of dots with padding will fit into the available space (Add one for the maximal dot)
	readonly property real dotWithPadding: Theme.geometry_temperatureSlider_dot_size + Theme.geometry_temperatureSlider_dot_padding
	readonly property int dotCount: Math.min(Math.floor(availableWidth / dotWithPadding) + 1, ((to - from) / stepSize) + 1)

	implicitHeight: Theme.geometry_dimmingSlider_height
	leftPadding: textMetricsMin.width + (Theme.geometry_temperatureSlider_text_horizontal_padding * 2)
	rightPadding: textMetricsMax.width + (Theme.geometry_temperatureSlider_text_horizontal_padding * 2)

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
			color: root.enabled ? Theme.color_button_down_text : Theme.color_font_disabled
		}

		Label {
			anchors.right: parent.right
			anchors.verticalCenter: parent.verticalCenter
			width: root.rightPadding
			text: CommonWords.max
			horizontalAlignment: Text.AlignHCenter
			font.pixelSize: Theme.font_size_body1
			color: root.enabled ? Theme.color_button_down_text : Theme.color_font_disabled
		}
	}

	handle: Rectangle {
		id: handleItem
		x: root.visible ? root.leftPadding + root.visualPosition * (root.availableWidth - width) : 0
		y: (root.height / 2) - (height / 2)
		width: Theme.geometry_temperatureSlider_indicator_size
		height: root.background.height - Theme.geometry_temperatureSlider_decorator_vertical_padding*2
		radius: width / 2
		color: root.enabled ? Theme.color_white : Theme.color_font_disabled

		SliderHandleHighlight {
			id: handleHighlight
			x: (parent.width / 2) - (width / 2)
			y: (parent.height / 2) - (height / 2)
			width: root.handle.height
			height: Theme.geometry_switch_groove_border_width * 2
			visible: Global.keyNavigationEnabled && root.activeFocus
		}

		XAnimator {
			id: anim
			target: parent
			easing.type: Easing.InOutQuad
			duration: Theme.animation_briefPage_sidePanel_sliderValueChange_duration
		}
	}

	contentItem: Item {
		Repeater {
			model: dotCount
			CP.ColorImage {
				x: modelData * (root.availableWidth - width)/(dotCount - 1)
				anchors.verticalCenter: parent.verticalCenter
				width: Theme.geometry_temperatureSlider_dot_size
				height: Theme.geometry_temperatureSlider_dot_size
				source: "qrc:/images/dot.svg"
				color: root.enabled ? Theme.color_white : Theme.color_font_disabled
			}
		}
	}

	onPressedChanged: pressed && !Global.keyNavigationEnabled ? popup.open() : popup.close()

	Popup {
		id: popup

		property string _popupText: Units.convert(root.value, VenusOS.Units_Temperature_Celsius, Global.systemSettings.temperatureUnit) + "\u00b0"

		x: handle.x + (handle.width / 2) - (width / 2)
		y: handle.y - height - Theme.geometry_temperatureSlider_popup_padding
		width: Math.max(Theme.geometry_temperatureSlider_popup_width, popupTextMetrics.width)
		height: Theme.geometry_temperatureSlider_popup_height
		closePolicy: Popup.CloseOnReleaseOutside

		background: Rectangle {
			color: Theme.color_blue
			radius: Theme.geometry_temperatureSlider_popup_radius

			CP.ColorImage {
				anchors {
					top: parent.bottom
					topMargin: -1 // overlap that prevents artifacts and it just looks better
					horizontalCenter: parent.horizontalCenter
				}
				source: "qrc:/images/spinbox_arrow_up.svg"
				color: Theme.color_blue
				rotation: 180
			}
		}

		contentItem: Label {
			horizontalAlignment: Text.AlignHCenter
			verticalAlignment: Text.AlignVCenter
			font.pixelSize: Theme.font_size_h2
			text: popup._popupText
			color: Theme.color_button_down_text
		}

		TextMetrics {
			id: popupTextMetrics
			font.pixelSize: Theme.font_size_h2
			text: popup._popupText
		}
	}

	TextMetrics {
		id: textMetricsMax
		font.pixelSize: Theme.font_size_body1
		text: CommonWords.max
	}
	TextMetrics {
		id: textMetricsMin
		font.pixelSize: Theme.font_size_body1
		text: CommonWords.min
	}
}

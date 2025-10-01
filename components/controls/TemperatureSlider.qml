/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Effects as Effects
import QtQuick.Controls.impl as CP
import Victron.VenusOS

SwitchableOutputSlider {
	id: root

	property string measurementText

	// Determine the number of dots with padding will fit into the available space (Add one for the maximal dot)
	readonly property real dotWithPadding: Theme.geometry_temperatureSlider_dot_size + Theme.geometry_temperatureSlider_dot_padding
	readonly property int dotCount: Math.min(Math.floor(availableWidth / dotWithPadding) + 1, ((to - from) / stepSize) + 1)

	leftPadding: leftPaddingText.implicitWidth
	rightPadding: rightPaddingText.implicitWidth
	indicatorBackgroundWidth: 0 // align handle exactly with the start/end dots
	fromDisplayValue: (v) => { return Units.convert(v, Global.systemSettings.temperatureUnit, VenusOS.Units_Temperature_Celsius) }
	toDisplayValue: (v) => { return Units.convert(v, VenusOS.Units_Temperature_Celsius, Global.systemSettings.temperatureUnit) }

	background: Rectangle {
		radius: Theme.geometry_slider_groove_radius

		// the background is the border with an additional rectangle for fill
		gradient: Gradient {
			orientation: Qt.Horizontal
			GradientStop { position: 0.0; color: root.enabled ? Theme.color_temperatureslider_gradient_min_border : Theme.color_gray3 }
			GradientStop { position: 1.0; color: root.enabled ? Theme.color_temperatureslider_gradient_max_border : Theme.color_gray3 }
		}

		Rectangle {
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

	// Ideally the popup is shown when pressed=true, but on device that causes the popup to be shown
	// on the first press when the handle has not yet moved to the touch position, as the device
	// drag threshold has not been reached. So, show the popup when the slider indicator has moved,
	// rather than when it is pressed.
	onMoved: {
		popupLoader.active = true
		popupLoader.item.open()
	}
	onPressedChanged: {
		if (!pressed && !!popupLoader.item) {
			popupLoader.item.close()
		}
	}

	Loader {
		id: popupLoader

		active: false
		sourceComponent: Popup {
			id: popup

			x: handle.x + (handle.width / 2) - (width / 2)
			y: -height + Theme.geometry_button_border_width
			leftPadding: Theme.geometry_temperatureSlider_popup_padding
			rightPadding: Theme.geometry_temperatureSlider_popup_padding
			topPadding: 0
			bottomPadding: 0
			closePolicy: Popup.CloseOnReleaseOutside

			background: Rectangle {
				color: Theme.color_blue
				radius: Theme.geometry_temperatureSlider_popup_radius
				layer.enabled: true
				layer.effect: Effects.MultiEffect {
					shadowEnabled: true
					shadowHorizontalOffset: Theme.geometry_temperatureSlider_popup_shadow_horizontalOffset
					shadowVerticalOffset: Theme.geometry_temperatureSlider_popup_shadow_verticalOffset
					blurMax: 24
				}

				CP.ColorImage {
					id: popupArrow
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
				id: popupLabel
				rightPadding: measurementLabel.visible
						// Add padding on either side of the separator, and on the right edge
						? measurementLabel.width + (2 * Theme.geometry_temperatureSlider_popup_padding)
						: 0
				horizontalAlignment: Text.AlignHCenter
				verticalAlignment: Text.AlignVCenter
				font.pixelSize: Theme.font_size_h2
				text: root.value.toFixed(root.stepSizeDecimalCount) + Units.degreesSymbol
				color: Theme.color_button_down_text

				SeparatorBar {
					id: popupSeparator
					anchors {
						verticalCenter: parent.verticalCenter
						right: measurementLabel.left
						rightMargin: Theme.geometry_temperatureSlider_popup_padding
					}
					height: popupLabel.implicitHeight - (2 * Theme.geometry_temperatureSlider_popup_padding)
					visible: root.measurementText.length > 0
					color: Theme.color_gray7
				}

				Label {
					id: measurementLabel
					anchors {
						verticalCenter: parent.verticalCenter
						verticalCenterOffset: -(measurementCaptionLabel.height / 2)
						right: parent.right
					}
					width: Math.max(measurementCaptionLabel.implicitWidth, implicitWidth)
					visible: root.measurementText.length > 0
					horizontalAlignment: Text.AlignHCenter
					color: Theme.color_gray7
					text: root.measurementText
					font.pixelSize: Theme.font_size_body2

					Label {
						id: measurementCaptionLabel
						anchors.top: parent.bottom
						//: The current temperature measurement
						//% "Current"
						text: qsTrId("temperature_slider_current")
						font.pixelSize: Theme.font_size_tiny
						width: parent.width
						horizontalAlignment: Text.AlignHCenter
						color: Theme.color_gray7
					}
				}
			}
		}
	}

	Connections {
		target: Global.systemSettings
		function onTemperatureUnitChanged() {
			// Force the value to match the updated system temperature unit.
			value = toDisplayValue(root.switchableOutput.dimming)
		}
	}

	component MinMaxLabel : Label {
		anchors.verticalCenter: parent.verticalCenter
		leftPadding: Theme.geometry_temperatureSlider_text_horizontal_padding
		rightPadding: Theme.geometry_temperatureSlider_text_horizontal_padding
		color: root.enabled ? Theme.color_button_down_text : Theme.color_font_disabled
	}

	MinMaxLabel {
		id: leftPaddingText
		anchors.left: parent.left
		text: root.mirrored ? CommonWords.max : CommonWords.min
	}

	MinMaxLabel {
		id: rightPaddingText
		anchors.right: parent.right
		text: root.mirrored ? CommonWords.min : CommonWords.max
	}
}

/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Rectangle {
	id: root

	required property ColorDimmerData colorDimmerData
	required property int outputType

	implicitWidth: 316
	implicitHeight: 260
	border.width: 1
	color: "transparent"

	component ColorDataSlider : Row {
		required property string name
		required property real maximumValue
		property alias value: colorSettingSlider.value
		property alias slider: colorSettingSlider
		signal sliderMoved()

		spacing: 8

		Label {
			anchors.verticalCenter: parent.verticalCenter
			width: parent.width * .2
			text: name
		}
		Slider {
			id: colorSettingSlider
			width: parent.width * .6
			to: maximumValue
			onMoved: sliderMoved()
		}
		Label {
			anchors.verticalCenter: parent.verticalCenter
			width: parent.width * .2
			text: colorSettingSlider.value.toFixed(2)
		}
	}

	Rectangle {
		width: 40
		height: 40
		anchors.right: parent.right
		color: root.colorDimmerData.color
	}

	Column {
		anchors.centerIn: parent
		x: 8
		width: parent.width - (2 * x)
		spacing: 8

		// Hue: for RGB/RGB+W sliders.
		ColorDataSlider {
			width: parent.width
			name: "H"
			visible: root.outputType !== VenusOS.SwitchableOutput_Type_ColorDimmerCct
			maximumValue: 1
			value: root.colorDimmerData.color.hsvHue
			onSliderMoved: {
				// Save the selected hue.
				root.colorDimmerData.color.hsvHue = value
				root.colorDimmerData.save()
			}
		}

		// Saturation: for RGB/RGB+W sliders.
		ColorDataSlider {
			width: parent.width
			visible: root.outputType !== VenusOS.SwitchableOutput_Type_ColorDimmerCct
			name: "S"
			maximumValue: 1.0
			value: root.colorDimmerData.color.hsvSaturation
			onSliderMoved: {
				// Save the selected saturation.
				root.colorDimmerData.color.hsvSaturation = value
				root.colorDimmerData.save()
			}
		}

		// Brightness: for all sliders.
		ColorDataSlider {
			id: brightnessSlider
			width: parent.width
			name: "V"
			maximumValue: 1.0
			value: root.colorDimmerData.color.hsvValue
			onSliderMoved: {
				// Save the selected brightness.
				root.colorDimmerData.color.hsvValue = value
				root.colorDimmerData.save()
			}
		}

		// White: for RGB+W sliders only.
		ColorDataSlider {
			width: parent.width
			name: "White"
			visible: root.outputType === VenusOS.SwitchableOutput_Type_ColorDimmerRgbW
			maximumValue: 100
			value: root.colorDimmerData.white
			onSliderMoved: {
				// TODO: does this modify the overall colour in any way? I don't think so, but not sure.
				root.colorDimmerData.white = value
				root.colorDimmerData.save()
			}
		}

		// Color temperature: for CCT sliders only.
		ColorDataSlider {
			function findColorBetween(color1, color2, pos) {
				const r = color1.r + ((color2.r - color1.r) * pos)
				const g = color1.g + ((color2.g - color1.g) * pos)
				const b = color1.b + ((color2.b - color1.b) * pos)
				return Qt.rgba(r, g, b, 1.0)
			}

			width: parent.width
			name: "C.T."
			visible: root.outputType === VenusOS.SwitchableOutput_Type_ColorDimmerCct
			maximumValue: 6500
			value: root.colorDimmerData.colorTemperature
			onSliderMoved: {
				// Find the colour that is selected along the gradient bar.
				let selectedColor
				if (slider.visualPosition < 0.5) {
					selectedColor = findColorBetween(cctStartColor.color, cctMidColor.color, slider.visualPosition * 2)
				} else {
					selectedColor = findColorBetween(cctMidColor.color, cctEndColor.color, (slider.visualPosition - 0.5) * 2)
				}

				// Update the color dimmer data, by combining the colour with the selected
				// brightness value.
				root.colorDimmerData.color = Qt.hsva(selectedColor.hsvHue, selectedColor.hsvSaturation, brightnessSlider.slider.visualPosition, 1.0)
				root.colorDimmerData.colorTemperature = value
				root.colorDimmerData.save()
			}
		}

		// CCT gradient bar.
		Rectangle {
			visible: root.outputType === VenusOS.SwitchableOutput_Type_ColorDimmerCct
			x: (parent.width * 0.2) + parent.spacing
			width: parent.width * 0.6
			height: 40
			border.width: 1
			gradient: Gradient {
				orientation: Gradient.Horizontal
				GradientStop {
					id: cctStartColor
					position: 0
					color: Theme.color_orange
				}
				GradientStop {
					id: cctMidColor
					position: 0.5
					color: Theme.color_white
				}
				GradientStop {
					id: cctEndColor
					position: 1
					color: Theme.color_blue
				}
			}
		}

		Label {
			anchors.horizontalCenter: parent.horizontalCenter
			text: "H=%1, S=%2, V=%3"
					.arg(colorDimmerData.color.hsvHue.toFixed(1))
					.arg(colorDimmerData.color.hsvSaturation.toFixed(1))
					.arg(colorDimmerData.color.hsvValue.toFixed(1))
		}
	}

	Label {
		id: rawDataLabel
		anchors.bottom: parent.bottom

		VeQuickItem {
			uid: root.colorDimmerData.dataUid
			onValueChanged: {
				let s = ""
				if (value) {
					s = "H=%1, S=%2, V=%3, \nW=%4, CT=%5"
						.arg(value[0].toFixed(1))
						.arg(value[1].toFixed(1))
						.arg(value[2].toFixed(1))
						.arg(value[3].toFixed(1))
						.arg(value[4].toFixed(1))
				}
				rawDataLabel.text = "Saved as: " + s
			}
		}
	}
}

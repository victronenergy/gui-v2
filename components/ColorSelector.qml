/*
<<<<<<< HEAD
** Copyright (C) 2025 Victron Energy B.V.
=======
** Copyright (C) 2023 Victron Energy B.V.
>>>>>>> d117de04 (WIP: UI Controls: light source colorwheel selector)
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import QtQuick.Effects
import QtQuick.Shapes
import QtQuick.Templates as T
import Victron.VenusOS

Rectangle {
	id: root

	required property ColorDimmerData colorDimmerData
	required property SwitchableOutput switchableOutput
	required property int outputType

	readonly property real _colorWheelWidth: 208
	readonly property real _colorWheelHeight: 208
	readonly property real _colorWheelRingWidth: 32
	readonly property real _colorWheelCentreWidth: 107
	readonly property real _colorWheelCentreBorder: 23

	readonly property real _sliderWidth: 62
	readonly property real _sliderHeight: 208
	readonly property real _sliderRadius: 141
	readonly property real _strokeWidth: 30
	readonly property real _halfStrokeWidth: _strokeWidth/2
	readonly property real _sliderBorderWidth: 2

	readonly property real _haloWheelDiameter: 30
	readonly property real _haloSliderDiameter: 24

	property ConicalGradient _colorGradient: ConicalGradient {
		angle: 33.0 // slightly shift starting angle colour
		centerX: colorWheel.width/2
		centerY: colorWheel.width/2
		GradientStop { position: 0.0; color: Qt.hsva(0.0, 1.0, 1.0, 1.0) }
		GradientStop { position: 0.166; color: Qt.hsva(0.166, 1.0, 1.0, 1.0) }
		GradientStop { position: 0.333; color: Qt.hsva(0.333, 1.0, 1.0, 1.0) }
		GradientStop { position: 0.5; color: Qt.hsva(0.5, 1.0, 1.0, 1.0) }
		GradientStop { position: 0.666; color: Qt.hsva(.666, 1.0, 1.0, 1.0) }
		GradientStop { position: 0.866; color: Qt.hsva(0.866, 1.0, 1.0, 1.0) }
		GradientStop { position: 1.0; color: Qt.hsva(1.0, 1.0, 1.0, 1.0) }
	}

	property LinearGradient _temperatureGradient: LinearGradient {
		x1: 0
		y1: colorWheel.height/2
		x2: colorWheel.width
		y2: colorWheel.height/2
		GradientStop { position: 0.0; color: Theme.color_orange }
		GradientStop { position: 0.5; color: Theme.color_white }
		GradientStop { position: 1.0; color: Theme.color_blue }
	}

	function findColorBetween(color1, color2, pos) {
		const r = color1.r + ((color2.r - color1.r) * pos)
		const g = color1.g + ((color2.g - color1.g) * pos)
		const b = color1.b + ((color2.b - color1.b) * pos)
		return Qt.rgba(r, g, b, 1.0)
	}

	function angleToColor(angle, offset, saturation) {
		let offsetAngle = (angle + offset) % 360
		if (root.outputType === VenusOS.SwitchableOutput_Type_ColorDimmerCct) {
			// Find the colour that is selected on the temperature gradient bar.
			let selectedColor
			if (offsetAngle < 180) {
				selectedColor = findColorBetween(Theme.color_orange, Theme.color_white, offsetAngle/360 * 2)
			} else {
				selectedColor = findColorBetween(Theme.color_white, Theme.color_blue, (offsetAngle/360 - 0.5) * 2)
			}
			return Qt.hsva(selectedColor.hsvHue, selectedColor.hsvSaturation, leftSlider.value, 1.0)
		}
		return Qt.hsva(offsetAngle/360, saturation, 1.0, 1.0)
	}

	implicitWidth: 316
	implicitHeight: 272
	color: "transparent"

	T.Slider {
		id: leftSlider

		x: 0
		anchors.verticalCenter: colorWheel.verticalCenter
		width: root._sliderWidth
		height: root._sliderHeight
		value: root.switchableOutput.dimming
		orientation: Qt.Vertical
		topPadding: root._halfStrokeWidth
		bottomPadding: root._halfStrokeWidth

		onMoved: {
			// Save the selected brightness.
			// root.switchableOutput.setDimming(value)
			root.colorDimmerData.color.hsvValue = value
			root.colorDimmerData.save()
		}

		handle: Halo {
			x: root._sliderRadius + (root._strokeWidth - height)/1.5 + Math.cos((leftSliderHighlight.startAngle + leftSliderHighlight.sweepAngle) * (Math.PI / 180)) * root._sliderRadius
			y: leftSlider.availableHeight/2 + (root._strokeWidth - width)/2 + Math.sin((leftSliderHighlight.startAngle + leftSliderHighlight.sweepAngle) * (Math.PI / 180)) * root._sliderRadius
			width: root._haloSliderDiameter
		}

		DropShadow {
			source: leftSlider.handle
			anchors.fill: leftSlider.handle
		}

		background: Shape {
			ShapePath {
				id: borderPath
				strokeColor: Theme.color_blue
				strokeWidth: root._strokeWidth
				fillColor: "transparent"
				capStyle: ShapePath.RoundCap
				joinStyle: ShapePath.RoundJoin

				startX: leftSlider.width - root._halfStrokeWidth
				startY: leftSlider.height - root._halfStrokeWidth

				PathArc {
					radiusX: root._sliderRadius
					radiusY: root._sliderRadius
					x: leftSlider.width - root._halfStrokeWidth
					y: root._halfStrokeWidth
					direction: PathArc.Clockwise
				}
			}
			ShapePath {
				id: backgroundPath
				strokeColor: Theme.color_darkOk
				strokeWidth: root._strokeWidth - root._sliderBorderWidth * 2
				fillColor: "transparent"
				capStyle: ShapePath.RoundCap
				joinStyle: ShapePath.RoundJoin
				startX: leftSlider.width - root._halfStrokeWidth
				startY: leftSlider.height - root._halfStrokeWidth

				PathArc {
					radiusX: root._sliderRadius
					radiusY: root._sliderRadius
					x: leftSlider.width - root._halfStrokeWidth
					y: root._halfStrokeWidth
					direction: PathArc.Clockwise
				}
			}
			CP.ColorImage {
				id: icon
				x: leftSlider.width - root._halfStrokeWidth - width/2
				y: root._halfStrokeWidth - height/2

				source: "qrc:/images/sunny.svg"
				color: Theme.color_font_primary
			}

		}

		contentItem: Shape {
			ShapePath {
				id: highlightPath
				strokeColor: Theme.color_blue
				strokeWidth: root._strokeWidth - root._sliderBorderWidth
				fillColor: "transparent"
				capStyle: ShapePath.RoundCap
				joinStyle: ShapePath.RoundJoin
				startX: leftSlider.width - root._halfStrokeWidth
				startY: leftSlider.height - root._strokeWidth

				PathAngleArc {
					id: leftSliderHighlight
					centerX : colorWheel.x + colorWheel.width/2
					centerY : leftSlider.y + leftSlider.height/2 - root._halfStrokeWidth
					moveToStart : true
					radiusX : root._sliderRadius
					radiusY : root._sliderRadius
					startAngle : 180 - 39     // origin is 3pm, move to 9 oclock minus slider angle
					sweepAngle : leftSlider.position === 0 ? .01 : 78 * leftSlider.position
				}
			}
		}

		// MultiEffect {
		// 	source: leftSlider.handle
		// 	anchors.fill: leftSlider.handle
		// }
	}

	T.Slider {
		id: rightSlider

		property real strokeAngle: 45

		x: colorWheel.x + colorWheel.width - 9
		anchors.verticalCenter: colorWheel.verticalCenter
		value: root.colorDimmerData.color.hsvSaturation
		width: root._sliderWidth
		height: root._sliderHeight
		orientation: Qt.Vertical
		topPadding: root._halfStrokeWidth
		bottomPadding: root._halfStrokeWidth
		visible: root.outputType !== VenusOS.SwitchableOutput_Type_ColorDimmerCct

		onMoved: {
			// Save the selected saturation.
			root.colorDimmerData.color.hsvSaturation = value
			root.colorDimmerData.save()
		}

		handle: Halo {
			x: Math.cos((Math.asin(.5 - rightSlider.position) * rightSlider.availableHeight)/root._sliderRadius) * root._sliderRadius - colorWheel.width/2 - (root._strokeWidth - width)/2 - 1
			y: (rightSlider.availableHeight) * (1 - rightSlider.position) + (root._strokeWidth - height)/2
			width: root._haloSliderDiameter
		}

		DropShadow {
			source: rightSlider.handle
			anchors.fill: rightSlider.handle
		}

		contentItem: Shape {
			ShapePath {
				id: rightSliderBackgroundPath
				strokeColor: "transparent"
				strokeWidth: 1
				capStyle: ShapePath.RoundCap
				joinStyle: ShapePath.RoundJoin
				startX: root._halfStrokeWidth + Math.sin(rightSlider.strokeAngle) * root._halfStrokeWidth
				startY: rightSlider.availableHeight + Math.cos(rightSlider.strokeAngle) * root._halfStrokeWidth

				fillGradient: ConicalGradient {
					// fill a semicircle with a conical gradient of the currently
					// selection hue to provide a saturation slider background
					angle: -90
					centerX: 0
					centerY: rightSlider.height/2
					GradientStop { position: 0.0; color: root.colorDimmerData.color.lighter(4) }
					GradientStop { position: .5; color: root.colorDimmerData.color }
				}

				// draw four arcs, two main arcs which are the sides of the slider
				// and two caps that connect each longer arc, visibly similar to the
				// attribute ShapePath.RoundCap
				PathArc {
					radiusX: root._sliderRadius + root._halfStrokeWidth
					radiusY: root._sliderRadius + root._halfStrokeWidth
					x: root._halfStrokeWidth + Math.sin(rightSlider.strokeAngle) * root._halfStrokeWidth
					y: - Math.cos(rightSlider.strokeAngle) * root._halfStrokeWidth
					direction: PathArc.Counterclockwise
				}
				PathArc {
					radiusX: root._halfStrokeWidth
					radiusY: root._halfStrokeWidth
					x: root._halfStrokeWidth - Math.sin(rightSlider.strokeAngle) * root._halfStrokeWidth
					y: + Math.cos(rightSlider.strokeAngle) * root._halfStrokeWidth
					direction: PathArc.Counterclockwise
				}
				PathArc {
					radiusX: root._sliderRadius - root._halfStrokeWidth
					radiusY: root._sliderRadius - root._halfStrokeWidth
					x: root._halfStrokeWidth - Math.sin(rightSlider.strokeAngle) * root._halfStrokeWidth
					y: rightSlider.availableHeight - Math.cos(rightSlider.strokeAngle) * root._halfStrokeWidth
					direction: PathArc.Clockwise
				}
				PathArc {
					radiusX: root._halfStrokeWidth
					radiusY: root._halfStrokeWidth
					x: root._halfStrokeWidth + Math.sin(rightSlider.strokeAngle) * root._halfStrokeWidth
					y: rightSlider.availableHeight + Math.cos(rightSlider.strokeAngle) * root._halfStrokeWidth
					direction: PathArc.Counterclockwise
				}
			}
		}
	}

	T.Slider {
		id: lowerSlider

		y: colorWheel.y + colorWheel.height + 3 // Additional pixel padding
		anchors.horizontalCenter: colorWheel.horizontalCenter
		to: 100
		value: root.colorDimmerData.white
		width: 172
		height: 49
		orientation: Qt.Horizontal
		leftPadding: root._halfStrokeWidth
		rightPadding: root._halfStrokeWidth
		visible: root.outputType === VenusOS.SwitchableOutput_Type_ColorDimmerRgbW

		onMoved: {
			// TODO: does this modify the overall colour in any way? I don't think so, but not sure.
			root.colorDimmerData.white = value
			root.colorDimmerData.save()
		}

		handle: Halo {
			x: (lowerSlider.availableWidth) * (lowerSlider.position) + (root._strokeWidth - width)/2
			y: Math.cos((Math.asin(.5 - lowerSlider.position) * lowerSlider.availableWidth)/root._sliderRadius) * root._sliderRadius - colorWheel.width/2 - 3 - (root._strokeWidth - height)/2 - 9
			color: Theme.color_blue
			width: root._haloSliderDiameter
		}

		DropShadow {
			source: lowerSlider.handle
			anchors.fill: lowerSlider.handle
		}

		background: CP.ColorImage {
			id: lowerSliderBackground
			source: Theme.colorScheme === Theme.Light ? "qrc:/images/slider_background_light.svg" : "qrc:/images/slider_background_dark.svg"
			color: Theme.colorScheme === Theme.Light ? "black" : "white"
		}
	}

	Shape {
		id: colorWheel
		x: leftSlider.width - 9 // small overlap for sliders and color wheel
		y: 0
		width: root._colorWheelWidth
		height: root._colorWheelHeight

		ShapePath {
			id: colorGradientShape
			strokeWidth: 1
			strokeColor: "transparent"
			fillGradient: root.outputType === VenusOS.SwitchableOutput_Type_ColorDimmerCct ? _temperatureGradient : _colorGradient
			startX: colorWheel.width/2
			startY: 0
			PathArc {
				// Note that a single PathArc cannot be used to specify a circle.
				// Instead, you can use two PathArc elements, each specifying
				// half of the circle.
				x: colorWheel.width/2-.01; y: 0
				radiusX: colorWheel.width/2; radiusY: colorWheel.width/2
				useLargeArc: true
			}
		}

		Halo {
			id: indicator
			x: (parent.width - width)/2
			y: colorSelector._haloWheelDiameter * 0.1
			width: root._colorWheelRingWidth

			transform: Rotation {
				angle: mousearea.angle
				origin.x: indicator.width/2
				origin.y: colorWheel.height/2 - indicator.y
			}
		}

		Rectangle {
			anchors.centerIn: colorWheel
			width: root._colorWheelCentreWidth + root._colorWheelCentreBorder
			height: root._colorWheelCentreWidth + root._colorWheelCentreBorder
			radius: width/2

			color: root.outputType === VenusOS.SwitchableOutput_Type_ColorDimmerCct
				   ? root.angleToColor(360 - mousearea.angle, 0, rightSlider.value)
				   : root.angleToColor(360 - mousearea.angle, 90 - _colorGradient.angle, rightSlider.value)
			border.width: root._colorWheelCentreBorder
			border.color: Theme.color_background_secondary

			onColorChanged: {
				// Save the selected hue.
				root.colorDimmerData.color.hsvHue = color.hsvHue //  mousearea.angle/360
				root.colorDimmerData.save()
			}
		}
		// #51A6FF #FFFFF

		MouseArea {
			id: mousearea
			anchors.fill: parent
			property real angle: Math.round((Math.atan2(width/2 - mouseX, mouseY - height/2) / 6.2831 + 0.5) * 360)
//			property real radius: Math.sqrt(Math.pow(width/2 - mouseX, 2) + Math.pow(mouseY - height/2, 2))
		}

		DropShadow {
			source: indicator
			anchors.fill: indicator
			transform: Rotation {
				angle: mousearea.angle
				origin.x: indicator.width/2
				origin.y: colorWheel.height/2 - indicator.y
			}
		}
	}

	// Column {
	// 	anchors.centerIn: parent
	// 	x: 8
	// 	width: parent.width - (2 * x)
	// 	spacing: 8

	// 	// Color temperature: for CCT sliders only.
	// 	ColorDataSlider {
	// 		function findColorBetween(color1, color2, pos) {
	// 			const r = color1.r + ((color2.r - color1.r) * pos)
	// 			const g = color1.g + ((color2.g - color1.g) * pos)
	// 			const b = color1.b + ((color2.b - color1.b) * pos)
	// 			return Qt.rgba(r, g, b, 1.0)
	// 		}

	// 		width: parent.width
	// 		name: "C.T."
	// 		visible: root.colorDimmerData.type === VenusOS.SwitchableOutput_Type_ColorDimmerCct
	// 		maximumValue: 6500
	// 		value: root.colorDimmerData.colorTemperature
	// 		onSliderMoved: {
	// 			// Find the colour that is selected along the gradient bar.
	// 			let selectedColor
	// 			if (slider.visualPosition < 0.5) {
	// 				selectedColor = findColorBetween(cctStartColor.color, cctMidColor.color, slider.visualPosition * 2)
	// 			} else {
	// 				selectedColor = findColorBetween(cctMidColor.color, cctEndColor.color, (slider.visualPosition - 0.5) * 2)
	// 			}

	// 			// Update the color dimmer data, by combining the colour with the selected
	// 			// brightness value.
	// 			root.colorDimmerData.color = Qt.hsva(selectedColor.hsvHue, selectedColor.hsvSaturation, brightnessSlider.slider.visualPosition, 1.0)
	// 			root.colorDimmerData.colorTemperature = value
	// 			root.colorDimmerData.save()
	// 		}
	// 	}

	// 	// CCT gradient bar.
	// 	Rectangle {
	// 		visible: root.colorDimmerData.type === VenusOS.SwitchableOutput_Type_ColorDimmerCct
	// 		x: (parent.width * 0.2) + parent.spacing
	// 		width: parent.width * 0.6
	// 		height: 40
	// 		border.width: 1
	// 		gradient: Gradient {
	// 			orientation: Gradient.Horizontal
	// 			GradientStop {
	// 				id: cctStartColor
	// 				position: 0
	// 				color: Theme.color_orange
	// 			}
	// 			GradientStop {
	// 				id: cctMidColor
	// 				position: 0.5
	// 				color: Theme.color_white
	// 			}
	// 			GradientStop {
	// 				id: cctEndColor
	// 				position: 1
	// 				color: Theme.color_blue
	// 			}
	// 		}
	// 	}

	// 	Label {
	// 		anchors.horizontalCenter: parent.horizontalCenter
	// 		text: "H=%1, S=%2, V=%3"
	// 				.arg(colorDimmerData.color.hsvHue.toFixed(1))
	// 				.arg(colorDimmerData.color.hsvSaturation.toFixed(1))
	// 				.arg(colorDimmerData.color.hsvValue.toFixed(1))
	// 	}
	// }


	component Halo : Rectangle {
		height: width
		radius: width/2
		color: "transparent"
		border.width: 4
		border.color: "white"
	}

	component DropShadow : MultiEffect {
		shadowBlur: 1.0
		shadowEnabled: true
		shadowColor: "black"
		shadowVerticalOffset: 2
		shadowHorizontalOffset: 0
	}

	// Antialiasing without requiring multisample framebuffers.
	layer.enabled: !BackendConnection.msaaEnabled
	layer.smooth: true
	layer.textureSize: Qt.size(root.width*2, root.height*2)

	// Label {
	// 	id: rawDataLabel
	// 	anchors.top: parent.bottom

	// 	VeQuickItem {
	// 		uid: root.colorDimmerData.dataUid
	// 		onValueChanged: {
	// 			let s = ""
	// 			if (value) {
	// 				s = "H=%1, S=%2, V=%3, \nW=%4, CT=%5, Angle=%6"
	// 					.arg(value[0].toFixed(1))
	// 					.arg(value[1].toFixed(1))
	// 					.arg(value[2].toFixed(1))
	// 					.arg(value[3].toFixed(1))
	// 					.arg(value[4].toFixed(1))
	// 					.arg(mousearea.angle)
	// 			}
	// 			rawDataLabel.text = "Saved as: " + s
	// 		}
	// 	}
	// }
}

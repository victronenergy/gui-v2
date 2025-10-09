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
	required property int outputType

	property real availableWidth

	property real ringWidth: 32

	readonly property real _sliderRadius: 141
	readonly property real _strokeWidth: 30
	readonly property real _halfStrokeWidth: colorSelector._strokeWidth/2
	readonly property real _haloWheelDiameter: 30
	readonly property real _haloSliderDiameter: 24

	property ConicalGradient _colorGradient: ConicalGradient {
		angle: 0.0
		centerX: colorWheel.width/2
		centerY: colorWheel.width/2
		GradientStop { position: 0.0; color: Qt.hsva(0.25, 1.0, 1.0, 1.0) }
		GradientStop { position: 0.166; color: Qt.hsva(0.083, 1.0, 1.0, 1.0) }
		GradientStop { position: 0.333; color: Qt.hsva(0.916, 1.0, 1.0, 1.0) }
		GradientStop { position: 0.5; color: Qt.hsva(0.75, 1.0, 1.0, 1.0) }
		GradientStop { position: 0.666; color: Qt.hsva(.616, 1.0, 1.0, 1.0) }
		GradientStop { position: 0.866; color: Qt.hsva(0.456, 1.0, 1.0, 1.0) }
		GradientStop { position: 1.0; color: Qt.hsva(0.25, 1.0, 1.0, 1.0) }
	}

	property ConicalGradient _temperatureGradient: ConicalGradient {
		angle: 0.0
		centerX: colorWheel.width/2
		centerY: colorWheel.width/2
		GradientStop { position: 0.0; color: Theme.color_white }
		GradientStop { position: 0.25; color: Theme.color_blue }
		GradientStop { position: 0.5; color: Theme.color_white  }
		GradientStop { position: 0.75; color: Theme.color_orange }
		GradientStop { position: 1.0; color: Theme.color_white }
	}


	implicitWidth: 316
	implicitHeight: 272
//	border.width: 1
	color: "transparent"
	T.Slider {
		id: leftSlider

		x: 0
		y: 0
		width: 62
		height: 208
		value: 0.5
		orientation: Qt.Vertical
		topPadding: root._halfStrokeWidth
		bottomPadding: root._halfStrokeWidth

		onMoved: {
			// Save the selected brightness.
			root.colorDimmerData.color.hsvValue = value
			root.colorDimmerData.save()
		}

		handle: Halo {
			x: leftSlider.x + root._sliderRadius + (root._strokeWidth - height)/1.5 + Math.cos((leftSliderHighlight.startAngle + leftSliderHighlight.sweepAngle) * (Math.PI / 180)) * root._sliderRadius
			y: leftSlider.y + leftSlider.availableHeight/2 + (root._strokeWidth - width)/2 + Math.sin((leftSliderHighlight.startAngle + leftSliderHighlight.sweepAngle) * (Math.PI / 180)) * root._sliderRadius
			width: root._haloSliderDiameter
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
				strokeWidth: root._strokeWidth - 4 //Theme.border_width
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
				strokeWidth: 30 - 2
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
					startAngle : 180 - 39     // 9 oclock minus slider angle
					sweepAngle : leftSlider.position === 0 ? .01 : 78 * leftSlider.position
				}
			}
		}

		MultiEffect {
			source: leftSlider.handle
			anchors.fill: leftSlider.handle
		}
	}

	T.Slider {
		id: rightSlider

		property real strokeWidth: 30
		property real strokeAngle: 45
		property real _halfStrokeWidth: strokeWidth/2

		x: colorWheel.x + colorWheel.width - 9
		y: 0
		value: 0.75
		width: 62
		height: 208
		orientation: Qt.Vertical
		topInset: 0
		bottomInset: 0
		topPadding: _halfStrokeWidth
		bottomPadding: _halfStrokeWidth
		visible: root.outputType !== VenusOS.SwitchableOutput_Type_ColorDimmerCct

		onMoved: {
			// Save the selected saturation.
			root.colorDimmerData.color.hsvSaturation = value
			root.colorDimmerData.save()
		}

		handle: Halo {
			//x: rightSlider.y + (colorSelector._sliderRadius - Math.sqrt(colorSelector._sliderRadius^2 - (((rightSlider.availableHeight) * (1 - rightSlider.position))-rightSlider.availableHeight/2)^2))
			x: rightSlider.x + (root._sliderRadius - Math.sqrt(Math.pow(root._sliderRadius, 2) - Math.pow((100 + (rightSlider.availableHeight) * (.5 - rightSlider.position)), 2)))
			y: (rightSlider.availableHeight) * (1 - rightSlider.position) + (lowerSlider.strokeWidth - height)/2
			width: root._haloSliderDiameter
		}

		contentItem: Shape {

			ShapePath {
				id: rightSliderBackgroundPath
				strokeColor: "transparent"
				strokeWidth: 1
				capStyle: ShapePath.RoundCap
				joinStyle: ShapePath.RoundJoin
				startX: rightSlider._halfStrokeWidth + Math.sin(rightSlider.strokeAngle)*rightSlider._halfStrokeWidth
				startY: rightSlider.availableHeight + Math.cos(rightSlider.strokeAngle)*rightSlider._halfStrokeWidth

				fillGradient: ConicalGradient {
					angle: -90 // 0 degrees is 3pm
					centerX: -root._sliderRadius + rightSlider._halfStrokeWidth
					centerY: rightSlider.height/2
					GradientStop { position: 0.1; color: Qt.hsva(mousearea.angle, 0.0, 1.0, 1.0) }
					GradientStop { position: .4; color: Qt.hsva(mousearea.angle, 1.0, 1.0, 1.0) }
				}

				PathArc {
					radiusX: root._sliderRadius + rightSlider._halfStrokeWidth
					radiusY: root._sliderRadius + rightSlider._halfStrokeWidth
					x: rightSlider._halfStrokeWidth + Math.sin(rightSlider.strokeAngle)*rightSlider._halfStrokeWidth
					y: - Math.cos(rightSlider.strokeAngle)*rightSlider._halfStrokeWidth
					direction: PathArc.Counterclockwise
				}
				PathArc {
					radiusX: rightSlider._halfStrokeWidth
					radiusY: rightSlider._halfStrokeWidth
					x: rightSlider._halfStrokeWidth - Math.sin(rightSlider.strokeAngle)*rightSlider._halfStrokeWidth
					y: + Math.cos(rightSlider.strokeAngle)*rightSlider._halfStrokeWidth
					direction: PathArc.Counterclockwise
				}
				PathArc {
					radiusX: root._sliderRadius - rightSlider._halfStrokeWidth
					radiusY: root._sliderRadius - rightSlider._halfStrokeWidth
					x: rightSlider._halfStrokeWidth - Math.sin(rightSlider.strokeAngle)*rightSlider._halfStrokeWidth
					y: rightSlider.availableHeight - Math.cos(rightSlider.strokeAngle)*rightSlider._halfStrokeWidth
					direction: PathArc.Clockwise
				}
				PathArc {
					radiusX: rightSlider._halfStrokeWidth
					radiusY: rightSlider._halfStrokeWidth
					x: rightSlider._halfStrokeWidth + Math.sin(rightSlider.strokeAngle)*rightSlider._halfStrokeWidth
					y: rightSlider.availableHeight + Math.cos(rightSlider.strokeAngle)*rightSlider._halfStrokeWidth
					direction: PathArc.Counterclockwise
				}
			}
		}

		DropShadow {
			source: rightSlider.handle
			anchors.fill: rightSlider.handle
		}
	}

	T.Slider {
		id: lowerSlider

		property real strokeWidth: 30
		//			property real strokeAngle: 50
		property real _halfStrokeWidth: strokeWidth/2

		y: colorWheel.y + colorWheel.height + 3 // Additional pixel padding
		anchors.horizontalCenter: colorWheel.horizontalCenter
		value: 0.1
		width: 172
		height: 49
		orientation: Qt.Horizontal
		leftPadding: _halfStrokeWidth
		rightPadding: _halfStrokeWidth
		visible: root.outputType === VenusOS.SwitchableOutput_Type_ColorDimmerRgbW

		onMoved: {
			// TODO: does this modify the overall colour in any way? I don't think so, but not sure.
			root.colorDimmerData.white = value
			root.colorDimmerData.save()
		}

		handle: Halo {
			x: (lowerSlider.availableWidth) * (lowerSlider.position) + (lowerSlider.strokeWidth - width)/2
			y: rightSlider.y + (141 - Math.sqrt(144^2 - (x-lowerSlider.availableWidth/2)^2))
			color: Theme.color_blue
			width: root._haloSliderDiameter
		}

		background: CP.ColorImage {
			id: lowerSliderBackground
			source: Theme.colorScheme === Theme.Light ? "qrc:/images/slider_background_light.svg" : "qrc:/images/slider_background_dark.svg"
			color: Theme.colorScheme === Theme.Light ? "black" : "white"
		}

		DropShadow {
			source: lowerSlider.handle
			anchors.fill: lowerSlider.handle
		}
	}

	Shape {
		id: colorWheel
		x: 50//leftSlider.width - 9 // inset for color wheel
		y: 0
		width: 208
		height: 208

		ShapePath {
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
			width: colorSelector.ringWidth

			transform: Rotation {
				angle: mousearea.angle * 360
				origin.x: indicator.width/2
				origin.y: colorWheel.height/2 - indicator.y
			}
		}

		Rectangle {
			anchors.centerIn: colorWheel
			width: 130
			height: 130
			radius: width/2

			color: Qt.hsva(mousearea.angle, rightSlider.value, 1.0, 1.0)
			border.width: 23
			border.color: Theme.color_background_secondary
		}

		MouseArea {
			id: mousearea
			anchors.fill: parent
			property real angle: Math.atan2(width/2 - mouseX, mouseY - height/2) / 6.2831 + 0.5

			onAngleChanged: {
				// Save the selected hue.
				root.colorDimmerData.color.hsvHue = mousearea.angle
				root.colorDimmerData.save()
			}
		}

		DropShadow {
			source: indicator
			anchors.fill: indicator
			transform: Rotation {
				angle: mousearea.angle * 360
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

	Label {
		id: rawDataLabel
		anchors.top: parent.bottom

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

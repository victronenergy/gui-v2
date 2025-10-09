/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import QtQuick.Effects
import QtQuick.Shapes
import QtQuick.Templates as T
import Victron.VenusOS

Item {
	id: root

	required property ColorDimmerData colorDimmerData
	required property int outputType

	readonly property real _halfStrokeWidth: Theme.geometry_colorWheel_slider_strokeWidth/2

	readonly property real _temperatureCool: 6500
	readonly property real _temperatureWarm: 2000

	Component.onCompleted: resetHue()

	function resetHue() {
		mousearea.angle = ((720 - (root.colorDimmerData.color.hsvHue * 360)) + (90 - colorGradient.angle)) % 360
	}

	function findColorBetween(color1, color2, pos) {
		const r = color1.r + ((color2.r - color1.r) * pos)
		const g = color1.g + ((color2.g - color1.g) * pos)
		const b = color1.b + ((color2.b - color1.b) * pos)
		return Qt.rgba(r, g, b, 1.0)
	}

	function angleToColor(angle, offset, saturation) {
		// Find the colour that is selected on the hue gradient wheel.
		let offsetAngle = (angle + offset) % 360
		return Qt.hsva(offsetAngle/360, saturation, 1.0, 1.0)
	}

	function angleToTemperature(angle) {
		console.log("angle" + angle)
		if (angle < 90) {
			return (angle/180 + 0.5) * (root._temperatureCool - root._temperatureWarm) + root._temperatureWarm
		} else if (angle < 180) {
			return ((180 - angle)/180 + 0.5) * (root._temperatureCool - root._temperatureWarm) + root._temperatureWarm
		} else if (angle < 270) {
			return ((270 - angle)/180) * (root._temperatureCool - root._temperatureWarm) + root._temperatureWarm
		} else {
			return (((angle - 270))/180) * (root._temperatureCool - root._temperatureWarm) + root._temperatureWarm
		}
	}

	function angleToTemperatureColor(angle) {
		let selectedColor
		let value = angle/360
		if (value < .5) {
			selectedColor = findColorBetween(Theme.color_temperature_cool, Theme.color_white, Math.abs(value - .25) * 4)
		} else {
			selectedColor = findColorBetween(Theme.color_temperature_warm, Theme.color_white, Math.abs(value - .75) * 4)
		}
		return Qt.hsva(selectedColor.hsvHue, selectedColor.hsvSaturation, 1.0, 1.0)
	}

	implicitWidth: 316
	implicitHeight: 272

	T.Slider {
		id: leftSlider

		x: 0
		anchors.verticalCenter: colorWheel.verticalCenter
		width: Theme.geometry_colorWheel_slider_width
		height: Theme.geometry_colorWheel_slider_height
		value: root.colorDimmerData.color.hsvValue
		orientation: Qt.Vertical
		topPadding: root._halfStrokeWidth
		bottomPadding: root._halfStrokeWidth

		onMoved: {
			// Save the selected brightness.
			root.colorDimmerData.color.hsvValue = value
			root.colorDimmerData.save()
		}

		handle: Halo {
			x: Theme.geometry_colorWheel_slider_arc_radius + (Theme.geometry_colorWheel_slider_strokeWidth - height)/1.5 + Math.cos((leftSliderHighlight.startAngle + leftSliderHighlight.sweepAngle) * (Math.PI / 180)) * Theme.geometry_colorWheel_slider_arc_radius
			y: leftSlider.availableHeight/2 + (Theme.geometry_colorWheel_slider_strokeWidth - width)/2 + Math.sin((leftSliderHighlight.startAngle + leftSliderHighlight.sweepAngle) * (Math.PI / 180)) * Theme.geometry_colorWheel_slider_arc_radius
			width: Theme.geometry_colorWheel_slider_halo_diameter
		}

		DropShadow {
			source: leftSlider.handle
			anchors.fill: leftSlider.handle
		}

		background: Shape {
			ShapePath {
				id: borderPath
				strokeColor: Theme.color_blue
				strokeWidth: Theme.geometry_colorWheel_slider_strokeWidth
				fillColor: "transparent"
				capStyle: ShapePath.RoundCap
				joinStyle: ShapePath.RoundJoin

				startX: leftSlider.width - root._halfStrokeWidth
				startY: leftSlider.height - root._halfStrokeWidth

				PathArc {
					radiusX: Theme.geometry_colorWheel_slider_arc_radius
					radiusY: Theme.geometry_colorWheel_slider_arc_radius
					x: leftSlider.width - root._halfStrokeWidth
					y: root._halfStrokeWidth
					direction: PathArc.Clockwise
				}
			}
			ShapePath {
				id: backgroundPath
				strokeColor: Theme.color_darkOk
				strokeWidth: Theme.geometry_colorWheel_slider_strokeWidth - Theme.geometry_colorWheel_slider_borderWidth * 2
				fillColor: "transparent"
				capStyle: ShapePath.RoundCap
				joinStyle: ShapePath.RoundJoin
				startX: leftSlider.width - root._halfStrokeWidth
				startY: leftSlider.height - root._halfStrokeWidth

				PathArc {
					radiusX: Theme.geometry_colorWheel_slider_arc_radius
					radiusY: Theme.geometry_colorWheel_slider_arc_radius
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
				strokeWidth: Theme.geometry_colorWheel_slider_strokeWidth - Theme.geometry_colorWheel_slider_borderWidth // margin so highlight falls within the border
				fillColor: "transparent"
				capStyle: ShapePath.RoundCap
				joinStyle: ShapePath.RoundJoin
				startX: leftSlider.width - root._halfStrokeWidth
				startY: leftSlider.height - root._halfStrokeWidth

				PathAngleArc {
					id: leftSliderHighlight
					centerX : leftSlider.width - Theme.geometry_colorWheel_component_overlap + colorWheel.width/2   // slider overlaps selector by 9 pixels
					centerY : leftSlider.height/2 - root._halfStrokeWidth
					moveToStart : true
					radiusX : Theme.geometry_colorWheel_slider_arc_radius
					radiusY : Theme.geometry_colorWheel_slider_arc_radius
					startAngle : 180 - 39     // origin is 3pm, move to 9 oclock minus slider angle
					sweepAngle : leftSlider.position === 0 ? .01 : 78 * leftSlider.position
				}
			}
		}
	}

	T.Slider {
		id: rightSlider

		property real strokeAngle: 45

		x: colorWheel.x + colorWheel.width - Theme.geometry_colorWheel_component_overlap
		anchors.verticalCenter: colorWheel.verticalCenter
		width: Theme.geometry_colorWheel_slider_width
		height: Theme.geometry_colorWheel_slider_height
		value: root.colorDimmerData.color.hsvSaturation
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
			x: Math.cos((Math.asin(.5 - rightSlider.position) * rightSlider.availableHeight)/Theme.geometry_colorWheel_slider_arc_radius) * Theme.geometry_colorWheel_slider_arc_radius - colorWheel.width/2 - (Theme.geometry_colorWheel_slider_strokeWidth - width)/2 - 1
			y: (rightSlider.availableHeight) * (1 - rightSlider.position) + (Theme.geometry_colorWheel_slider_strokeWidth - height)/2
			width: Theme.geometry_colorWheel_slider_halo_diameter
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
					GradientStop { position: 0.0; color: root.angleToColor(360 - mousearea.angle, 90 - colorGradient.angle, 0.2) }
					GradientStop { position: .5; color: root.angleToColor(360 - mousearea.angle, 90 - colorGradient.angle, 1.0) }
				}

				// Draw four arcs, two main arcs which are the sides of the slider
				// and two caps that connect each longer arc, visibly similar to the
				// attribute ShapePath.RoundCap
				PathArc {
					radiusX: Theme.geometry_colorWheel_slider_arc_radius + root._halfStrokeWidth
					radiusY: Theme.geometry_colorWheel_slider_arc_radius + root._halfStrokeWidth
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
					radiusX: Theme.geometry_colorWheel_slider_arc_radius - root._halfStrokeWidth
					radiusY: Theme.geometry_colorWheel_slider_arc_radius - root._halfStrokeWidth
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

		y: colorWheel.y + colorWheel.height + Theme.geometry_colorWheel_lowerSlider_padding
		anchors.horizontalCenter: colorWheel.horizontalCenter
		to: 100
		value: root.colorDimmerData.white
		width: Theme.geometry_colorWheel_lowerSlider_width
		height: Theme.geometry_colorWheel_lowerSlider_height
		orientation: Qt.Horizontal
		leftPadding: root._halfStrokeWidth
		rightPadding: root._halfStrokeWidth
		visible: root.outputType === VenusOS.SwitchableOutput_Type_ColorDimmerRgbW

		onMoved: {
			// Save the selected white channel.
			root.colorDimmerData.white = value
			root.colorDimmerData.save()
		}

		handle: Halo {
			x: (lowerSlider.availableWidth) * (lowerSlider.position) + (Theme.geometry_colorWheel_slider_strokeWidth - width)/2
			y: Math.cos((Math.asin(.5 - lowerSlider.position) * lowerSlider.availableWidth)/Theme.geometry_colorWheel_slider_arc_radius) * Theme.geometry_colorWheel_slider_arc_radius - colorWheel.width/2 - (Theme.geometry_colorWheel_slider_strokeWidth - height)/2 - height/2
			color: Theme.color_blue
			width: Theme.geometry_colorWheel_slider_halo_diameter
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
		x: leftSlider.width - Theme.geometry_colorWheel_component_overlap // small overlap for sliders and color wheel
		y: 0
		width: Theme.geometry_colorWheel_selector_width
		height: Theme.geometry_colorWheel_selector_height

		ShapePath {
			id: colorGradientShape
			strokeWidth: 1
			strokeColor: "transparent"
			fillGradient: root.outputType === VenusOS.SwitchableOutput_Type_ColorDimmerCct ? temperatureGradient : colorGradient
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
			y: (Theme.geometry_colorWheel_selector_ring_width - Theme.geometry_colorWheel_selector_halo_diameter)/2
			width: Theme.geometry_colorWheel_selector_halo_diameter

			transform: Rotation {
				angle: mousearea.angle
				origin.x: indicator.width/2
				origin.y: colorWheel.height/2 - indicator.y
			}
		}

		// Centre color swatch of the color wheel, shows currently selected color
		Rectangle {
			anchors.centerIn: colorWheel
			width: Theme.geometry_colorWheel_selector_centre_diameter + Theme.geometry_colorWheel_selector_centre_borderWidth
			height: Theme.geometry_colorWheel_selector_centre_diameter + Theme.geometry_colorWheel_selector_centre_borderWidth
			radius: width/2

			color: root.outputType === VenusOS.SwitchableOutput_Type_ColorDimmerCct
					? root.angleToTemperatureColor(mousearea.angle)
					: root.angleToColor(360 - mousearea.angle, 90 - colorGradient.angle, rightSlider.value)
			border.width: Theme.geometry_colorWheel_selector_centre_borderWidth
			border.color: Theme.color_background_secondary

			onColorChanged: {
				// Save the selected hue.
				root.colorDimmerData.color.hsvHue = color.hsvHue
				root.colorDimmerData.save()
			}
		}

		MouseArea {
			id: mousearea
			anchors.fill: parent

			// set the initial angle from color data
			property real angle: (((360 - (root.colorDimmerData.color.hsvHue * 360)) + 360) + (90 - colorGradient.angle)) % 360

			function updateAngleAndColor() {
				// Determine if the position lies within a disc that represents the color selector.
				// The angle is set that corresponds to the angle of the point measured from the 12 oclock position
				if (Math.sqrt(Math.pow(width/2 - mouseX, 2) + Math.pow(mouseY - height/2, 2)) > (Theme.geometry_colorWheel_selector_centre_diameter/2 + Theme.geometry_colorWheel_selector_centre_borderWidth/2) &&
						Math.sqrt(Math.pow(width/2 - mouseX, 2) + Math.pow(mouseY - height/2, 2)) < Theme.geometry_colorWheel_selector_width/2) {
					angle = Math.round((Math.atan2(width/2 - mouseX, mouseY - height/2) / Math.PI*2 + 0.5) * 360)
				}

				if (root.outputType === VenusOS.SwitchableOutput_Type_ColorDimmerCct) {
					root.colorDimmerData.color.hsvHue = root.angleToTemperatureColor(mousearea.angle).hsvHue
					root.colorDimmerData.colorTemperature = root.angleToTemperature(mousearea.angle)
				} else {
					root.colorDimmerData.color.hsvHue = root.angleToColor(360 - mousearea.angle, 90 - colorGradient.angle, rightSlider.value).hsvHue
				}
				root.colorDimmerData.save()
			}

			onPressed: updateAngleAndColor()
			onPositionChanged: updateAngleAndColor()
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

	ConicalGradient {
		id: colorGradient
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

	LinearGradient {
		id: temperatureGradient
		x1: 0
		y1: colorWheel.height/2
		x2: colorWheel.width
		y2: colorWheel.height/2
		GradientStop { position: 0.0; color: Theme.color_temperature_warm }
		GradientStop { position: 0.5; color: Theme.color_white }
		GradientStop { position: 1.0; color: Theme.color_temperature_cool }
	}


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

	// Debug: will remove before merging
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

/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import QtQuick.Shapes
import QtQuick.Templates as T
import Victron.VenusOS

FocusScope {
	id: root

	property alias r: root.colorValue.r
	property alias g: root.colorValue.g
	property alias b: root.colorValue.b

	property color colorValue

	property real availableWidth

	readonly property real _sliderRadius: 150

	implicitWidth: 400
	implicitHeight: 210

	Control {
		id: control
		property real ringWidth: 32
		property real hsvValue: 1.0
		property real hsvSaturation: 1.0
		readonly property color color: Qt.hsva(mousearea.angle, rightSlider.value, 1.0, 1.0)

		contentItem: Item {
			implicitWidth: 316
			implicitHeight: 210

			T.Slider {
				id: leftSlider

				property real strokeWidth: 30
				property real _halfStrokeWidth: strokeWidth/2

				x: 0
				y: 0
				width: 62
				height: 208
				orientation: Qt.Vertical
				topInset: _halfStrokeWidth
				bottomInset: _halfStrokeWidth
				topPadding: _halfStrokeWidth
				bottomPadding: _halfStrokeWidth

				handle: Halo {
					x: 162 + leftSlider.availableWidth - 3.5 * Math.cos(0.5 - leftSlider.position) * (leftSlider.availableWidth)
					y: (leftSlider.availableHeight) * (1 - leftSlider.position)
					width: 24
				}

				background: Shape {
					ShapePath {
						id: borderPath
						strokeColor: Theme.color_blue
						strokeWidth: leftSlider.strokeWidth
						fillColor: "transparent"
						capStyle: ShapePath.RoundCap
						joinStyle: ShapePath.RoundJoin

						startX: leftSlider.width - leftSlider._halfStrokeWidth
						startY: leftSlider.availableHeight

						PathArc {
							radiusX: root._sliderRadius
							radiusY: root._sliderRadius

							x: leftSlider.width - leftSlider._halfStrokeWidth
							y: 0
							direction: PathArc.Clockwise
						}
					}
					ShapePath {
						id: backgroundPath
						strokeColor: Theme.color_darkOk
						strokeWidth: leftSlider.strokeWidth - 4
						fillColor: "transparent"
						capStyle: ShapePath.RoundCap
						joinStyle: ShapePath.RoundJoin
						startX: leftSlider.width - leftSlider._halfStrokeWidth
						startY: leftSlider.availableHeight// - borderPath.strokeWidth/2

						PathArc {
							radiusX: root._sliderRadius
							radiusY: root._sliderRadius
							x: leftSlider.width - leftSlider._halfStrokeWidth
							y: 0
							direction: PathArc.Clockwise // .Counterclockwise
						}
					}
					CP.ColorImage {
						id: icon
						x: leftSlider.width - leftSlider._halfStrokeWidth - width/2
						y: -10

						source: "qrc:/images/sunny.svg"
						color: Theme.color_font_primary
					}
				}

				contentItem: Shape {
					ShapePath {
						id: highlightPath
						strokeColor: Theme.color_blue
						strokeWidth: 30
						fillColor: "transparent"
						capStyle: ShapePath.RoundCap
						joinStyle: ShapePath.RoundJoin

						startX: leftSlider.width - leftSlider._halfStrokeWidth
						startY: leftSlider.availableHeight// - strokeWidth/2

						PathArc {
							radiusX: root._sliderRadius
							radiusY: root._sliderRadius

							x: leftSlider.handle.x + leftSlider.handle.width/2 //leftSlider.width - leftSlider._halfStrokeWidth //leftSlider.handle.x + leftSlider.handle.height/2// + leftSlider.handle.width/2// borderPath.strokeWidth
							y: leftSlider.handle.y //+ leftSlider.handle.height//borderPath.strokeWidth
							direction: PathArc.Clockwise
						}
					}
				}
			}
			T.Slider {
				id: rightSlider

				property real strokeWidth: 30
				property real strokeAngle: 45
				property real _halfStrokeWidth: strokeWidth/2

				x: colorWheel.x + colorWheel.width - 9
				y: 0
				width: 62
				height: 208
				orientation: Qt.Vertical
				topInset: 0
				bottomInset: 0
				topPadding: _halfStrokeWidth
				bottomPadding: _halfStrokeWidth

				handle: Halo {
					x: - (3 * rightSlider.availableWidth) + 3.5 * Math.cos(0.5 - rightSlider.position) * (rightSlider.availableWidth)
					y: (rightSlider.availableHeight) * (1 - rightSlider.position)// * Math.tan(1 - leftSlider.position)
					width: 24
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
							GradientStop { position: 0.1; color: Qt.hsva(mousearea.angle, 1.0, 1.0, 1.0) }
							GradientStop { position: .4; color: Qt.hsva(mousearea.angle, 0.0, 1.0, 1.0) }
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
			}

			Shape {
				id: colorWheel
				//anchors.left: leftSlider.right
				x: leftSlider.width - 9 // inset for color wheel
				y: 0
				width: 208 //Math.max(parent.width, parent.height)
				height: 208 //parent.width
				//anchors.centerIn: parent

				ShapePath {
					strokeWidth: 1
					strokeColor: "transparent"
					fillGradient: ConicalGradient {
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
					y: control.ringWidth * 0.1

					width: control.ringWidth

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

					color: control.color
					border.width: 23
					border.color: root.enabled ? Theme.color_darkOk : Theme.color_background_disabled
				}

				MouseArea {
					id: mousearea
					anchors.fill: parent
					property real angle: Math.atan2(width/2 - mouseX, mouseY - height/2) / 6.2831 + 0.5
				}
			}
		}
	}
	component Halo : Rectangle {
		height: width
		radius: width/2
		color: "transparent"
		border.width: 4
		border.color: "white"
	}

	// Antialiasing without requiring multisample framebuffers.
	layer.enabled: !BackendConnection.msaaEnabled
	layer.smooth: true
	layer.textureSize: Qt.size(colorSelector.width*2, colorSelector.height*2)
}

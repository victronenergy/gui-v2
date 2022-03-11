/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Shapes
import Victron.VenusOS
import "/components/Utils.js" as Utils

Item {
	id: root

	enum Location {
		Left,
		Right,
		Top,
		Bottom
	}

	property var startWidget
	property var endWidget
	property int startLocation
	property int endLocation

	// Forces a straight line by aligning the nubs using the centre of the smaller widget
	property bool straight

	// Animates from start to end
	property bool animationRunning
	property bool animationPaused

	property bool _animated: visible && animationRunning
	property real _animationProgress
	property real _diagonalDistance: Math.sqrt(connectorPath.width * connectorPath.width
		   + connectorPath.height * connectorPath.height
		   - (2 * connectorPath.width * connectorPath.height)
		   * Math.cos(90))

	visible: startWidget.visible && endWidget.visible

	// Animation doesn't appear to update duration when distance changes, so force it here.
	on_DiagonalDistanceChanged: {
		if (!animationPaused) {
			electronAnim.restart()
		}
	}

	WidgetConnectorPath {
		id: connectorPath

		// The path geometry encloses half of the start and end nubs precisely, so that the bounds
		// can clip the nubs to create the nub semicircles.
		x: Math.min(startX, endX) - (direction == Qt.Vertical ? startNub.width/2 : 0)
		y: Math.min(startY, endY) - (direction == Qt.Horizontal ? startNub.height/2 : 0)
		width: Math.max(startX, endX) - x + (direction == Qt.Vertical ? endNub.width/2 : 0)
		height: Math.max(startY, endY) - y + (direction == Qt.Horizontal ? endNub.height/2 : 0)
		clip: true

		direction: (startLocation == WidgetConnector.Location.Left
					|| startLocation == WidgetConnector.Location.Right)
					&& (endLocation == WidgetConnector.Location.Left
					|| endLocation == WidgetConnector.Location.Right)
				   ? Qt.Horizontal
				   : Qt.Vertical

		startNub.x: startX - x - startNub.width/2
		startNub.y: startY - y - startNub.height/2
		endNub.x: endX - x - endNub.width/2
		endNub.y: endY - y - endNub.height/2

		startX: {
			if (straight && connectorPath.direction == Qt.Vertical && startWidget.width > endWidget.width) {
				return endX
			}
			switch (startLocation) {
			case WidgetConnector.Location.Left:
				return startWidget.x
			case WidgetConnector.Location.Right:
				return startWidget.x + startWidget.width
			default:
				return startWidget.x + startWidget.width/2
			}
		}

		startY: {
			if (straight && connectorPath.direction == Qt.Horizontal && startWidget.height > endWidget.height) {
				return endY
			}
			switch (startLocation) {
			case WidgetConnector.Location.Top:
				return startWidget.y
			case WidgetConnector.Location.Bottom:
				return startWidget.y + startWidget.height
			default:
				return startWidget.y + startWidget.height/2
			}
		}

		endX: {
			if (straight && connectorPath.direction == Qt.Vertical && endWidget.width > startWidget.width) {
				return startX
			}
			switch (endLocation) {
			case WidgetConnector.Location.Left:
				return endWidget.x
			case WidgetConnector.Location.Right:
				return endWidget.x + endWidget.width
			default:
				return endWidget.x + endWidget.width/2
			}
		}

		endY: {
			if (straight && connectorPath.direction == Qt.Horizontal && endWidget.height > startWidget.height) {
				return startY
			}
			switch (endLocation) {
			case WidgetConnector.Location.Top:
				return endWidget.y
			case WidgetConnector.Location.Bottom:
				return endWidget.y + endWidget.height
			default:
				return endWidget.y + endWidget.height/2
			}
		}

		Shape {
			id: connectorShape

			anchors {
				left: {
					switch (startLocation) {
					case WidgetConnector.Location.Left:
						return connectorPath.startNub.left
					case WidgetConnector.Location.Right:
						return connectorPath.startNub.right
					default:
						return undefined
					}
				}
				horizontalCenter: {
					switch (startLocation) {
					case WidgetConnector.Location.Top:   // fall through
					case WidgetConnector.Location.Bottom:
						return connectorPath.startNub.horizontalCenter
					default:
						return undefined
					}
				}
				top: {
					switch (startLocation) {
					case WidgetConnector.Location.Top:
						return connectorPath.startNub.top
					case WidgetConnector.Location.Bottom:
						return connectorPath.startNub.bottom
					default:
						return connectorPath.startNub.verticalCenter
					}
				}
			}

			ShapePath {
				strokeWidth: Theme.geometry.overviewPage.connector.line.width
				strokeColor: Theme.color.overviewPage.widget.border
				fillColor: "transparent"
				pathElements: connectorPath.pathElements
			}

			Repeater {
				id: electronRepeater

				// electron interval = distance between electrons (i.e. how often to spawn a new electron)
				model: root._animated
					   ? Math.floor(root._diagonalDistance / Theme.geometry.overviewPage.connector.electron.interval)
					   : null

				delegate: Image {
					id: electron

					source: "qrc:/images/electron.svg"
					x: animPathInterpolator.x - width/2
					y: animPathInterpolator.y - height/2
					rotation: animPathInterpolator.angle
					opacity: animPathInterpolator.progress < 0.01 || animPathInterpolator.progress > 0.9 ? 0 : 1

					Behavior on opacity {
						NumberAnimation { duration: 250 }
					}

					// Cannot use PathAnimation, because after the first animation loop it ignores the
					// initial PathArc in the path.
					PathInterpolator {
						id: animPathInterpolator

						path: animPath

						// Evenly space out the progress of each electron
						progress: Utils.modulo(root._animationProgress - ((1 / electronRepeater.count) * model.index), 1)
					}
				}
			}
		}
	}

	// Create a separate Path for the animation, instead of using the ShapePath,
	// because PathInterpolator does not work for ShapePath.
	Path {
		id: animPath

		pathElements: connectorPath.pathElements
	}

	NumberAnimation {
		id: electronAnim

		target: root
		property: "_animationProgress"
		from: 0; to: 1

		running: root._animated
		paused: root.animationPaused && running
		loops: Animation.Infinite

		// animate at a constant rate of pixels/sec, based on the diagonal length of the shape
		duration: _diagonalDistance / Theme.geometry.overviewPage.connector.electron.velocity * 1000
	}
}

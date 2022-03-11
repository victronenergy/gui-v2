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

		// The path geometry encloses the space between the start and end widgets.
		x: Math.min(startX, endX) - (direction == Qt.Vertical ? startNub.width/2 : 0)
		y: Math.min(startY, endY) - (direction == Qt.Horizontal ? startNub.height/2 : 0)
		width: Math.max(startX, endX) - x + (direction == Qt.Vertical ? endNub.width/2 : 0)
		height: Math.max(startY, endY) - y + (direction == Qt.Horizontal ? endNub.height/2 : 0)

		direction: (startLocation == WidgetConnector.Location.Left
					|| startLocation == WidgetConnector.Location.Right)
					&& (endLocation == WidgetConnector.Location.Left
					|| endLocation == WidgetConnector.Location.Right)
				   ? Qt.Horizontal
				   : Qt.Vertical

		startNub.x: startX - x - (direction === Qt.Horizontal ? 0 : startNub.width)
		startNub.y: startY - y

		endNub.x: endX - x - endNub.width
		endNub.y: endY - y - (direction === Qt.Horizontal ? 0 : endNub.height)
		endNub.rotation: 180

		startX: (straight && connectorPath.direction == Qt.Vertical && startWidget.width > endWidget.width)
			? endX
			: startLocation === WidgetConnector.Location.Left
			  ? startWidget.x
			  : startLocation === WidgetConnector.Location.Right
				? startWidget.x + startWidget.width
				: startWidget.x + startWidget.width/2   // Top/Bottom location

		startY: (straight && connectorPath.direction == Qt.Horizontal && startWidget.height > endWidget.height)
				? endY
				: startLocation === WidgetConnector.Location.Top
				  ? startWidget.y
				  : startLocation === WidgetConnector.Location.Bottom
					? startWidget.y + startWidget.height
					: startWidget.y + startWidget.height/2  // Left/Right location

		endX: (straight && connectorPath.direction == Qt.Vertical && endWidget.width > startWidget.width)
			  ? startX
			  : endLocation === WidgetConnector.Location.Left
				? endWidget.x
				: endLocation === WidgetConnector.Location.Right
				  ? endWidget.x + endWidget.width
				  : endWidget.x + endWidget.width/2 // Top/Bottom location

		endY: (straight && connectorPath.direction == Qt.Horizontal && endWidget.height > startWidget.height)
			  ? startY
			  : endLocation === WidgetConnector.Location.Top
				? endWidget.y
				: endLocation === WidgetConnector.Location.Bottom
				  ? endWidget.y + endWidget.height
				  : endWidget.y + endWidget.height/2    // Left/Right location

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

					x: animPathInterpolator.x - width/2
					y: animPathInterpolator.y - height/2
					source: "qrc:/images/electron.svg"
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

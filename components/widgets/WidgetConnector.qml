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

	enum AnimationMode {
		NotAnimated,
		StartToEnd,
		EndToStart
	}

	property var startWidget
	property var endWidget
	property int startLocation
	property int endLocation

	property int animationMode: WidgetConnector.AnimationMode.NotAnimated
	property bool expanded
	property bool animateGeometry

	// Forces a straight line by aligning the nubs using the centre of the smaller widget
	property bool straight

	readonly property bool _animated: visible && animationMode !== WidgetConnector.AnimationMode.NotAnimated
	property real _animationProgress
	property real _electronTravelDistance

	readonly property rect _startWidgetRect: _widgetRect(startWidget)
	readonly property rect _endWidgetRect: _widgetRect(endWidget)

	function _widgetRect(widget) {
		return Qt.rect(
			widget.x,
			expanded ? widget.expandedY : widget.compactY,
			widget.width,
			expanded ? widget.expandedHeight : widget.compactHeight
		)
	}

	function _reset() {
		// Only calculate the model once, to avoid multiple model changes due to animation.
		_electronTravelDistance = _animated ? connectorPath.width + connectorPath.height : 0
		if (_animated) {
			electronAnim.restart()
		}
	}

	visible: startWidget.visible && endWidget.visible

	onAnimationModeChanged: Qt.callLater(_reset)
	Component.onCompleted: Qt.callLater(_reset)

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

		startX: (straight && connectorPath.direction == Qt.Vertical && _startWidgetRect.width > _endWidgetRect.width)
			? endX
			: startLocation === WidgetConnector.Location.Left
			  ? _startWidgetRect.x
			  : startLocation === WidgetConnector.Location.Right
				? _startWidgetRect.x + _startWidgetRect.width
				: _startWidgetRect.x + _startWidgetRect.width/2 - startNub.height/2   // Top/Bottom location

		startY: (straight && connectorPath.direction == Qt.Horizontal && _startWidgetRect.height > _endWidgetRect.height)
				? endY
				: startLocation === WidgetConnector.Location.Top
				  ? _startWidgetRect.y
				  : startLocation === WidgetConnector.Location.Bottom
					? _startWidgetRect.y + _startWidgetRect.height
					: _startWidgetRect.y + _startWidgetRect.height/2 - startNub.height/2  // Left/Right location

		endX: (straight && connectorPath.direction == Qt.Vertical && _endWidgetRect.width > _startWidgetRect.width)
			  ? startX
			  : endLocation === WidgetConnector.Location.Left
				? _endWidgetRect.x
				: endLocation === WidgetConnector.Location.Right
				  ? _endWidgetRect.x + _endWidgetRect.width
				  : _endWidgetRect.x + _endWidgetRect.width/2 - endNub.height/2 // Top/Bottom location

		endY: (straight && connectorPath.direction == Qt.Horizontal && _endWidgetRect.height > _startWidgetRect.height)
			  ? startY
			  : endLocation === WidgetConnector.Location.Top
				? _endWidgetRect.y
				: endLocation === WidgetConnector.Location.Bottom
				  ? _endWidgetRect.y + _endWidgetRect.height
				  : _endWidgetRect.y + _endWidgetRect.height/2 - endNub.height/2    // Left/Right location

		Behavior on startY {
			enabled: root.animateGeometry
			NumberAnimation {
				duration: Theme.animation.page.idleResize.duration
				easing.type: Easing.InOutQuad
			}
		}

		Behavior on endY {
			enabled: root.animateGeometry
			NumberAnimation {
				duration: Theme.animation.page.idleResize.duration
				easing.type: Easing.InOutQuad
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
				model: Math.floor(root._electronTravelDistance / Theme.geometry.overviewPage.connector.electron.interval)

				delegate: Image {
					id: electron

					readonly property real progress: root.animationMode === WidgetConnector.AnimationMode.StartToEnd
							? animPathInterpolator.progress
							: 1 - animPathInterpolator.progress

					x: animPathInterpolator.x - width/2
					y: animPathInterpolator.y - height/2
					source: "qrc:/images/electron.svg"
					rotation: root.animationMode === WidgetConnector.AnimationMode.StartToEnd
							  ? animPathInterpolator.angle
							  : animPathInterpolator.angle + 180
					opacity: progress < 0.01 || progress > 0.8 ? 0 : 1

					Behavior on opacity {
						NumberAnimation { duration: Theme.animation.overviewPage.connector.fade.duration }
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

		from: root.animationMode === WidgetConnector.AnimationMode.StartToEnd
			  ? 0
			  : 1
		to: root.animationMode === WidgetConnector.AnimationMode.StartToEnd
			? 1
			: 0

		running: root._animated
		loops: Animation.Infinite

		// animate at a constant rate of pixels/sec, based on the diagonal length of the shape
		duration: _electronTravelDistance / Theme.geometry.overviewPage.connector.electron.velocity * 1000
	}
}

/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Shapes
import Victron.VenusOS

Item {
	id: root

	property var startWidget
	property var endWidget
	property int startLocation
	property int endLocation

	property int animationMode: VenusOS.WidgetConnector_AnimationMode_NotAnimated
	property alias expanded: connectorPath.expanded
	property bool animateGeometry
	property bool animationEnabled
	readonly property bool defaultVisible: startWidget.visible && endWidget.visible && _initialized

	readonly property real animationElapsed: overviewPageRootAnimation.animationElapsed
	readonly property bool _animated: _initialized && visible && animationMode !== VenusOS.WidgetConnector_AnimationMode_NotAnimated && animationEnabled
	property real _electronTravelDistance
	property bool _initialized

	function reset() {
		// Disable _initialized to ensure path distance calculations are not updated before layout is complete.
		_initialized = false
		connectorPath.widgetConnectorLayoutChanged()
		_initialized = true
		Qt.callLater(_resetDistance)
	}

	function _widgetRect(widget, expandedGeometry) {
		return Qt.rect(
			widget.x,
			expandedGeometry ? widget.expandedY : widget.compactY,
			widget.width,
			expandedGeometry ? widget.expandedHeight : widget.compactHeight
		)
	}

	// Calculate the Repeater model imperatively, to avoid multiple model changes when the
	// animation state changes or when the connector path resizes.
	function _resetDistance() {
		if (!_initialized) {
			return
		}

		// Sets the distance between electrons (i.e. how often to spawn a new electron)
		const electronTravelDistance = _animated
				// Use a min value to ensure at least one electron is shown for short connectors
				? Math.max(Theme.geometry_overviewPage_connector_electron_interval, _electronTravelDistance)
				: 0
		const modelCount = Math.floor(electronTravelDistance / Theme.geometry_overviewPage_connector_electron_interval)

		if (electronRepeater.count !== modelCount) {
			electronRepeater.model = modelCount

			if (electronTravelDistance > 0) {
				const fadeDistance = 2 * Theme.geometry_overviewPage_connector_anchor_width
				pathUpdater.fadeOutThreshold = (electronTravelDistance - fadeDistance) / electronTravelDistance
			}
		}

		if (_animated) {
			// Animate at a constant rate of pixels/sec, based on the diagonal length of the shape
			pathUpdater.duration = electronTravelDistance / Theme.geometry_overviewPage_connector_electron_velocity * 1000
		}

		// Force drawing manually if the animations are paused
		if (overviewPageRootAnimation.paused) {
			pathUpdater.update()
		}
	}

	visible: defaultVisible
	on_AnimatedChanged: Qt.callLater(_resetDistance)
	onAnimationElapsedChanged: if (root._animated) pathUpdater.normalizedElapsed = 1000*animationElapsed/pathUpdater.duration

	// Ensure electrons are shown above connector paths that do not have electrons, to avoid a
	// situation where non-animated connector paths partially obscure electrons from other paths.
	z: electronRepeater.count === 0 ? -1 : 0

	states: State {
		name: "expanded"
		when: root.expanded && root._initialized

		PropertyChanges { target: connectorPath; y: connectorPath.expandedY; yDistance: connectorPath.expandedYDistance }
		PropertyChanges { target: connectorPath; startAnchorY: connectorPath.startAnchorExpandedY }
		PropertyChanges { target: connectorPath; endAnchorY: connectorPath.endAnchorExpandedY }
		PropertyChanges { target: root; _transitionUpdating: 1.0 }
	}

	transitions: Transition {
		enabled: root.animateGeometry
		NumberAnimation {
			properties: "y, yDistance, startAnchorY, endAnchorY, _transitionUpdating"
			duration: Theme.animation_page_idleResize_duration
			easing.type: Easing.InOutQuad
		}
	}

	WidgetConnectorPath {
		id: connectorPath

		function widgetConnectorLayoutChanged() {
			direction = (startLocation == VenusOS.WidgetConnector_Location_Left
						|| startLocation == VenusOS.WidgetConnector_Location_Right)
						&& (endLocation == VenusOS.WidgetConnector_Location_Left
						|| endLocation == VenusOS.WidgetConnector_Location_Right)
					   ? Qt.Horizontal
					   : Qt.Vertical

			// Initialize the path geometry to enclose the space between the start and end anchors.
			_initXGeometry()
			_initYGeometry(false)
			_initYGeometry(true)

			reloadPathLayout()
		}

		function _initXGeometry() {
			const startWidgetRect = _widgetRect(startWidget, false)
			const endWidgetRect = _widgetRect(endWidget, false)
			const anchorWidth = direction === Qt.Horizontal
					? Theme.geometry_overviewPage_connector_anchor_width
					: Theme.geometry_overviewPage_connector_anchor_height

			const startX = startLocation === VenusOS.WidgetConnector_Location_Left
				  ? startWidgetRect.x - anchorWidth
				  : startLocation === VenusOS.WidgetConnector_Location_Right
					? startWidgetRect.x + startWidgetRect.width + anchorWidth
					: startWidgetRect.x + startWidgetRect.width/2   // Top/Bottom location
			const endX = endLocation === VenusOS.WidgetConnector_Location_Left
				  ? endWidgetRect.x - anchorWidth
				  : endLocation === VenusOS.WidgetConnector_Location_Right
					? endWidgetRect.x + endWidgetRect.width + anchorWidth
					: endWidgetRect.x + endWidgetRect.width/2 // Top/Bottom location

			// x positions stay constant. The anchor points must be positioned with x value instead of
			// anchor bindings, else the position may be incorrect when reloadPathLayout() is called.
			x = Math.min(startX, endX)
			width = Math.max(1, Math.max(startX, endX) - x)
			startAnchorX = startX
			endAnchorX = endX
		}

		function _initYGeometry(expandedGeometry) {
			const startWidgetRect = _widgetRect(startWidget, expandedGeometry)
			const endWidgetRect = _widgetRect(endWidget, expandedGeometry)
			const anchorHeight = direction === Qt.Horizontal
					? Theme.geometry_overviewPage_connector_anchor_height
					: Theme.geometry_overviewPage_connector_anchor_width

			// Work out the start and end of the path depending on the direction and orientation.
			const startY = startLocation === VenusOS.WidgetConnector_Location_Top
				  ? startWidgetRect.y - anchorHeight
				  : startLocation === VenusOS.WidgetConnector_Location_Bottom
					? startWidgetRect.y + startWidgetRect.height + anchorHeight
					: startWidgetRect.y + startWidgetRect.height/2  // Left/Right location
			const endY = endLocation === VenusOS.WidgetConnector_Location_Top
				  ? endWidgetRect.y - anchorHeight
				  : endLocation === VenusOS.WidgetConnector_Location_Bottom
					? endWidgetRect.y + endWidgetRect.height + anchorHeight
					: endWidgetRect.y + endWidgetRect.height/2  // Left/Right location

			// y and height change depending on compact/expanded state
			if (expandedGeometry) {
				expandedY = Math.min(startY, endY)
				startAnchorExpandedY = startY - expandedY
				endAnchorExpandedY = endY - expandedY
			} else {
				compactY = Math.min(startY, endY)
				startAnchorCompactY = startY - compactY
				endAnchorCompactY = endY - compactY

				// We could also set a different electron travel distance in expanded mode, but it
				// makes little difference visually and results in more Repeater model changes.
				const compactHeight = Math.max(startY, endY) - compactY
				_electronTravelDistance = width + compactHeight
			}
		}

		Shape {
			id: connectorShape

			y: connectorPath.startAnchorY

			ShapePath {
				strokeWidth: Theme.geometry_overviewPage_connector_line_width
				strokeColor: Theme.color_overviewPage_widget_border
				fillColor: "transparent"
				pathElements: connectorPath.pathElements
			}

			Repeater {
				id: electronRepeater

				delegate: Image {
					opacity: 0.0
					source: "qrc:/images/electron.svg"

					Behavior on opacity {
						enabled: root._animated
						OpacityAnimator {
							duration: Theme.animation_overviewPage_connector_fade_duration
						}
					}
					Component.onCompleted: pathUpdater.add(this)
					Component.onDestruction: pathUpdater.remove(this)
				}
			}
		}
	}

	// Force drawing during the expanding transition even if the animations are paused
	property real _transitionUpdating
	on_TransitionUpdatingChanged: if (overviewPageRootAnimation.paused) pathUpdater.update()

	WidgetConnectorPathUpdater {
		id: pathUpdater

		property real normalizedElapsed
		property real duration
		readonly property real loopedElapsed: normalizedElapsed - Math.trunc(normalizedElapsed)
		readonly property bool startToEnd: root.animationMode === VenusOS.WidgetConnector_AnimationMode_StartToEnd
		progress: startToEnd ? loopedElapsed : 1.0 - loopedElapsed

		animationMode: root.animationMode

		// Create a separate Path for the animation, instead of using the ShapePath,
		// because WidgetConnectorPathUpdater does not work for ShapePath.
		path: Path {
			pathElements: connectorPath.pathElements
		}
	}
}

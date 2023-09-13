/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Shapes
import Victron.VenusOS
import Utils

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

	// Forces a straight line by aligning the anchor points using the centre of the smaller widget
	property bool straight

	readonly property bool _animated: _initialized && visible && animationMode !== VenusOS.WidgetConnector_AnimationMode_NotAnimated && animationEnabled
	property real _animationProgress

	property real _electronTravelDistance
	property real _electronFadeEnd

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
				? Math.max(Theme.geometry.overviewPage.connector.electron.interval, _electronTravelDistance)
				: 0
		const modelCount = Math.floor(electronTravelDistance / Theme.geometry.overviewPage.connector.electron.interval)

		if (electronRepeater.count !== modelCount) {
			electronRepeater.model = modelCount

			if (electronTravelDistance > 0) {
				const fadeDistance = 2 * Theme.geometry.overviewPage.connector.anchor.width
				_electronFadeEnd = (electronTravelDistance - fadeDistance) / electronTravelDistance
			}
		}

		if (_animated) {
			// Animate at a constant rate of pixels/sec, based on the diagonal length of the shape
			electronAnim.duration = electronTravelDistance / Theme.geometry.overviewPage.connector.electron.velocity * 1000
			electronAnim.restart()
		}
	}

	visible: defaultVisible
	on_AnimatedChanged: Qt.callLater(_resetDistance)

	// Ensure electrons are shown above connector paths that do not have electrons, to avoid a
	// situation where non-animated connector paths partially obscure electrons from other paths.
	z: electronRepeater.count === 0 ? -1 : 0

	states: State {
		name: "expanded"
		when: root.expanded && root._initialized

		PropertyChanges { target: connectorPath; y: connectorPath.expandedY; yDistance: connectorPath.expandedYDistance }
		PropertyChanges { target: connectorPath; startAnchorY: connectorPath.startAnchorExpandedY }
		PropertyChanges { target: connectorPath; endAnchorY: connectorPath.endAnchorExpandedY }
	}

	transitions: Transition {
		enabled: root.animateGeometry

		NumberAnimation {
			properties: "y,yDistance,startAnchorY,endAnchorY"
			duration: Theme.animation.page.idleResize.duration
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
					? Theme.geometry.overviewPage.connector.anchor.width
					: Theme.geometry.overviewPage.connector.anchor.height

			const _startX = startLocation === VenusOS.WidgetConnector_Location_Left
				  ? startWidgetRect.x - anchorWidth
				  : startLocation === VenusOS.WidgetConnector_Location_Right
					? startWidgetRect.x + startWidgetRect.width + anchorWidth
					: startWidgetRect.x + startWidgetRect.width/2   // Top/Bottom location
			const _endX = endLocation === VenusOS.WidgetConnector_Location_Left
				  ? endWidgetRect.x - anchorWidth
				  : endLocation === VenusOS.WidgetConnector_Location_Right
					? endWidgetRect.x + endWidgetRect.width + anchorWidth
					: endWidgetRect.x + endWidgetRect.width/2 // Top/Bottom location
			let startX = _startX
			let endX = _endX

			// If the path is straight, align the path to the smaller of the start/end widgets.
			if (straight && direction === Qt.Vertical) {
				if (startWidgetRect.width > endWidgetRect.width) {
					startX = _endX
				} else if (startWidgetRect.width < endWidgetRect.width) {
					endX = _startX
				}
			}

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
					? Theme.geometry.overviewPage.connector.anchor.height
					: Theme.geometry.overviewPage.connector.anchor.width

			// Work out the start and end of the path depending on the direction and orientation.
			const _startY = startLocation === VenusOS.WidgetConnector_Location_Top
				  ? startWidgetRect.y - anchorHeight
				  : startLocation === VenusOS.WidgetConnector_Location_Bottom
					? startWidgetRect.y + startWidgetRect.height + anchorHeight
					: startWidgetRect.y + startWidgetRect.height/2  // Left/Right location
			const _endY = endLocation === VenusOS.WidgetConnector_Location_Top
				  ? endWidgetRect.y - anchorHeight
				  : endLocation === VenusOS.WidgetConnector_Location_Bottom
					? endWidgetRect.y + endWidgetRect.height + anchorHeight
					: endWidgetRect.y + endWidgetRect.height/2  // Left/Right location
			let startY = _startY
			let endY = _endY

			// If the path is straight, align the path to the smaller of the start/end widgets.
			if (straight && direction === Qt.Horizontal) {
				if (startWidgetRect.height > endWidgetRect.height) {
					startY = _endY
				} else if (startWidgetRect.height < endWidgetRect.height) {
					endY = _startY
				}
			}

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
				strokeWidth: Theme.geometry.overviewPage.connector.line.width
				strokeColor: Theme.color.overviewPage.widget.border
				fillColor: "transparent"
				pathElements: connectorPath.pathElements
			}

			Repeater {
				id: electronRepeater

				delegate: Image {
					id: electron

					readonly property real progress: root.animationMode === VenusOS.WidgetConnector_AnimationMode_StartToEnd
							? animPathInterpolator.progress
							: 1 - animPathInterpolator.progress

					x: animPathInterpolator.x - width/2
					y: animPathInterpolator.y - height/2
					source: "qrc:/images/electron.svg"
					rotation: root.animationMode === VenusOS.WidgetConnector_AnimationMode_StartToEnd
							  ? animPathInterpolator.angle
							  : animPathInterpolator.angle + 180

					// Fade out the electron just before it reaches the end of the path, so that it
					// disappears nicely into the end anchor point, instead of disappearing abruptly.
					opacity: progress > _electronFadeEnd ? 0 : 1
					Behavior on opacity {
						enabled: root._animated
						NumberAnimation {
							duration: Theme.animation.overviewPage.connector.fade.duration
						}
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

		from: root.animationMode === VenusOS.WidgetConnector_AnimationMode_StartToEnd
			  ? 0
			  : 1
		to: root.animationMode === VenusOS.WidgetConnector_AnimationMode_StartToEnd
			? 1
			: 0

		running: root._animated
		loops: Animation.Infinite
	}
}

import QtQuick
import Victron.VenusOS
import QtQuick.Controls.impl as CP

Item {
	id: root

	property alias startNub: startNub
	property alias endNub: endNub
	property int direction: Qt.Horizontal

	property real startX
	property real startY
	property real endX
	property real endY

	readonly property real _midpointX: _xDistanceBetweenNubs / 2
	readonly property real _midpointY: _yDistanceBetweenNubs / 2
	readonly property real _xDistanceBetweenNubs: endNub.x > startNub.x
			? (endNub.x - (startNub.x + startNub.width - _adjustedNubWidth))
			: (endNub.x - (startNub.x - startNub.width + _adjustedNubWidth))
	readonly property real _yDistanceBetweenNubs:  endNub.y - startNub.y + _adjustedNubHeight

	// Cache some intermediate values using optimised bindings for performance
	// Use the x radius to show a more evenly-rounded radius when possible
	property int _absMidpointX: _midpointX >= 0 ? _midpointX : -_midpointX
	property int _absMidpointY: _midpointY >= 0 ? _midpointY : -_midpointY
	property int _smallestRadius: _absMidpointX < _absMidpointY ? _absMidpointX : _absMidpointY
	// for vertical connectors, take the nub width into account
	property int _adjustedNubWidth: direction === Qt.Vertical ? endNub.width : 0
	// for vertical connectors, take the nub height into account
	property int _adjustedNubHeight: startLocation === WidgetConnector.Location.Top ? endNub.height
			: startLocation === WidgetConnector.Location.Bottom ? -endNub.height
			: 0

	property list<QtObject> pathElements: [
		PathArc {
			id: startArc

			x: _midpointX
			y: startNub.y < endNub.y ? _smallestRadius : -_smallestRadius

			radiusX: x
			radiusY: y
			direction: (_midpointX < 0 && _midpointY < 0) || (_midpointX > 0 && _midpointY > 0)
					   ? PathArc.Clockwise : PathArc.Counterclockwise
		},

		PathLine {
			id: line
			relativeX: startNub.y == endNub.y ? _xDistanceBetweenNubs : 0
			relativeY: _yDistanceBetweenNubs - startArc.radiusY - endArc.radiusY
		},

		PathArc {
			id: endArc

			relativeX: startArc.x
			relativeY: startArc.y
			radiusX: startArc.radiusX
			radiusY: startArc.radiusY
			direction: startArc.direction == PathArc.Counterclockwise
					   ? PathArc.Clockwise
					   : PathArc.Counterclockwise
		}
	]

	CP.ColorImage {
		id: startNub

		source: root.direction === Qt.Horizontal
				? "qrc:/images/widget_connector_nub_horizontal.svg"
				: "qrc:/images/widget_connector_nub_vertical.svg"
	}

	CP.ColorImage {
		id: endNub

		source: root.direction === Qt.Horizontal
				? "qrc:/images/widget_connector_nub_horizontal.svg"
				: "qrc:/images/widget_connector_nub_vertical.svg"
	}
}

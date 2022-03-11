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
	readonly property real _xDistanceBetweenNubs: {
		// for vertical connectors, take the nub width into account
		var nubWidth = 0
		if (direction == Qt.Vertical) {
			nubWidth += endNub.width
		}
		var dist = endNub.x > startNub.x
				? endNub.x - (startNub.x + startNub.width - nubWidth)
				: (endNub.x - (startNub.x - startNub.width + nubWidth))
		return dist
	}
	readonly property real _yDistanceBetweenNubs: {
		var dist = endNub.y - startNub.y
		// for vertical connectors, take the nub height into account
		if (startLocation == WidgetConnector.Location.Top) {
			dist += endNub.height
		} else if (startLocation == WidgetConnector.Location.Bottom) {
			dist -= endNub.height
		}
		return dist
	}

	property list<QtObject> pathElements: [
		PathArc {
			id: startArc

			x: _midpointX
			y: {
				// Use the x radius to show a more evenly-rounded radius when possible
				var smallestRadius = Math.min(Math.abs(_midpointX), Math.abs(_midpointY))
				return startNub.y < endNub.y ? smallestRadius : -smallestRadius
			}

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

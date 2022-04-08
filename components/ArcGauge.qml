/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Window
import Victron.VenusOS

// A progress gauge running an on arc, where 0° is at the top, and positive is clockwise
Item {
	id: gauge

	property real value
	property int valueType: Gauges.FallingPercentage
	property alias startAngle: arc.startAngle
	property alias endAngle: arc.endAngle
	property alias radius: arc._radius
	property alias strokeWidth: arc._strokeWidth
	property alias direction: arc.direction
	property int alignment: Qt.AlignLeft
	property var arcX
	property var arcY

	Item {
		id: arcGauge
		readonly property int antialiasingFactor: 2
		width: parent.width*antialiasingFactor
		height: parent.height*antialiasingFactor
		visible: false

		ProgressArc {
			id: arc

			property int status: Gauges.getValueStatus(gauge.value, gauge.valueType)
			property real margin: strokeWidth/2

			property real _radius
			property real _strokeWidth: Theme.geometry.progressArc.strokeWidth
			radius: _radius * arcGauge.antialiasingFactor
			strokeWidth: _strokeWidth * arcGauge.antialiasingFactor

			width: radius*2 - strokeWidth
			height: width
			x: arcX !== undefined ? arcX*arcGauge.antialiasingFactor : (gauge.alignment === Qt.AlignRight ? (parent.width - 2*radius) - margin : margin)
			y: arcY !== undefined ? arcY*arcGauge.antialiasingFactor : ((parent.height - height) / 2 - margin)
			value: gauge.value
			progressColor: Theme.statusColorValue(status)
			remainderColor: Theme.statusColorValue(status, true)
		}
	}
	ShaderEffectSource {
		id: antialiasedArcGauge
		anchors.fill: parent
		sourceItem: arcGauge
		smooth: true
	}
}

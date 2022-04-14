/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.Velib
import Victron.VenusOS
import "/components/Utils.js" as Utils
import "../data"

ArcGauge {
	id: root

	property int gaugeAlignmentY: Qt.AlignTop // valid values: Qt.AlignTop, Qt.AlignBottom
	readonly property int maxAngle: Theme.geometry.briefPage.edgeGauge.maxAngle
	readonly property int arcOffset: -(radius - root.height) - strokeWidth / 2
	readonly property int maxArcHeight: Math.sin(Utils.degreesToRadians(maxAngle)) * radius

	implicitWidth: Theme.geometry.briefPage.edgeGauge.width
	implicitHeight: gaugeAlignmentY === Qt.AlignVCenter ? Theme.geometry.briefPage.largeEdgeGauge.height : Theme.geometry.briefPage.smallEdgeGauge.height
	alignment: Qt.AlignRight
	direction: PathArc.Counterclockwise
	startAngle: gaugeAlignmentY === Qt.AlignTop ? 90 : 90 + maxAngle
	endAngle: startAngle - maxAngle
	radius: Theme.geometry.briefPage.edgeGauge.radius
	strokeWidth: Theme.geometry.arc.strokeWidth
	value: 50//system ? system.loads.power / Utils.maximumValue("system.loads.power") * 100 : 0
	arcY: gaugeAlignmentY === Qt.AlignTop ? arcOffset : arcOffset - maxArcHeight

	ArcGaugeValueDisplay {
		anchors {
			right: parent.right
			rightMargin: Theme.geometry.loadMiniGauge.label.rightMargin
			top: root.gaugeAlignmentY ===  Qt.AlignBottom ? parent.top : undefined
			bottom: root.gaugeAlignmentY ===  Qt.AlignTop ? parent.bottom : undefined
		}
		gaugeAlignmentY: root.gaugeAlignmentY
		layoutDirection: Qt.RightToLeft  // load gauges are always on the RHS, and look like "1 kW [icon]", not "[icon] 1kW"
		source: "qrc:/images/consumption.svg"
		physicalQuantity: Units.Power
		value: system ? system.loads.power : 0
	}
	Rectangle {
		anchors.fill: parent
		color: gaugeAlignmentY === Qt.AlignTop ? "red" : "green"
		opacity: 0.1
	}
}

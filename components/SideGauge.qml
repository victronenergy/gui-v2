/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "Utils.js" as Utils

ArcGauge {
	id: root

	property int gaugeAlignmentY: Qt.AlignTop // valid values: Qt.AlignTop, Qt.AlignVCenter, Qt.AlignBottom
	property int gaugeAlignmentX: Qt.AlignRight // valid values: Qt.AlignLeft, Qt.AlignRight
	readonly property int maxAngle: gaugeAlignmentY === Qt.AlignVCenter ? Theme.geometry.briefPage.largeEdgeGauge.maxAngle : Theme.geometry.briefPage.smallEdgeGauge.maxAngle
	readonly property int arcOffset: -(radius - root.height) - strokeWidth / 2
	readonly property int maxArcHeight: Math.sin(Utils.degreesToRadians(maxAngle)) * radius

	property alias icon: quantityLabel.icon
	property alias quantityLabel: quantityLabel.quantityLabel

	implicitWidth: Theme.geometry.briefPage.edgeGauge.width
	implicitHeight: gaugeAlignmentY === Qt.AlignVCenter ? Theme.geometry.briefPage.largeEdgeGauge.height : Theme.geometry.briefPage.smallEdgeGauge.height
	alignment: gaugeAlignmentX
	direction: PathArc.Counterclockwise
	startAngle: gaugeAlignmentY === Qt.AlignTop ? 90 : gaugeAlignmentY === Qt.AlignVCenter ? 90 + maxAngle/2 : 90 + maxAngle
	endAngle: direction === PathArc.Counterclockwise ? startAngle - maxAngle : startAngle + maxAngle
	radius: Theme.geometry.briefPage.edgeGauge.radius
	strokeWidth: Theme.geometry.arc.strokeWidth
	arcY: gaugeAlignmentY === Qt.AlignTop ? arcOffset : gaugeAlignmentY === Qt.AlignVCenter ? undefined : arcOffset - maxArcHeight

	ArcGaugeQuantityLabel {
		id: quantityLabel

		gaugeAlignmentX: root.gaugeAlignmentX
		gaugeAlignmentY: root.gaugeAlignmentY
	}
}

/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "Utils.js" as Utils

ArcGauge {
	id: root

	property alias label: quantityLabel
	property alias icon: quantityLabel.icon
	property alias quantityLabel: quantityLabel.quantityLabel

	readonly property int _maxArcHeight: Math.sin(Utils.degreesToRadians(_maxAngle)) * radius
	readonly property int _arcOffset: -(radius - root.height) - strokeWidth / 2
	readonly property real _maxAngle: alignment & Qt.AlignVCenter ? Theme.geometry.briefPage.largeEdgeGauge.maxAngle : Theme.geometry.briefPage.smallEdgeGauge.maxAngle

	implicitWidth: Theme.geometry.briefPage.edgeGauge.width
	implicitHeight: alignment & Qt.AlignVCenter ? Theme.geometry.briefPage.largeEdgeGauge.height : Theme.geometry.briefPage.smallEdgeGauge.height
	alignment: Qt.AlignTop | Qt.AlignLeft
	direction: PathArc.Counterclockwise
	startAngle: alignment & Qt.AlignTop ? 90 : alignment & Qt.AlignVCenter ? 90 + _maxAngle/2 : 90 + _maxAngle
	endAngle: direction === PathArc.Counterclockwise ? startAngle - _maxAngle : startAngle + _maxAngle
	radius: Theme.geometry.briefPage.edgeGauge.radius
	strokeWidth: Theme.geometry.arc.strokeWidth
	arcY: alignment & Qt.AlignTop ? _arcOffset : alignment & Qt.AlignVCenter ? undefined : _arcOffset - _maxArcHeight

	ArcGaugeQuantityLabel {
		id: quantityLabel

		alignment: root.alignment
	}
}

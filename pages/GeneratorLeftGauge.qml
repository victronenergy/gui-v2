/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.Velib
import Victron.VenusOS
import QtQuick.Controls.impl as CP
import "/components/Utils.js" as Utils
import "../data"

ArcGauge {
	id: root

	property int gaugeAlignmentY: Qt.AlignVCenter // valid values: Qt.AlignTop, Qt.AlignVCenter, Qt.AlignBottom
	readonly property int maxAngle: Theme.geometry.briefPage.edgeGauge.maxAngle

	implicitWidth: Theme.geometry.briefPage.edgeGauge.width
	implicitHeight: gaugeAlignmentY === Qt.AlignVCenter ? Theme.geometry.briefPage.largeEdgeGauge.height : Theme.geometry.briefPage.smallEdgeGauge.height
	value: system ? system.generator.power / Utils.maximumValue("system.generator.power") * 100 : 0
	startAngle: gaugeAlignmentY === Qt.AlignTop ? 270 : 270 - maxAngle
	endAngle: startAngle + (gaugeAlignmentY === Qt.AlignTop ? maxAngle : 2 * maxAngle)
	radius: Theme.geometry.briefPage.edgeGauge.radius
	strokeWidth: Theme.geometry.arc.strokeWidth
	arcY: gaugeAlignmentY == Qt.AlignTop ? (-(radius - parent.height) - strokeWidth / 2) : -radius / 2

	ArcGaugeValueDisplay {
		anchors {
			left: parent.left
			leftMargin: Theme.geometry.briefPage.edgeGauge.icon.leftMargin - root.strokeWidth / 2
			bottom: gaugeAlignmentY === Qt.AlignTop ? parent.bottom : undefined
			verticalCenter: gaugeAlignmentY === Qt.AlignTop ? undefined : parent.verticalCenter
		}
		source: "qrc:/images/generator.svg"
		physicalQuantity: Units.Power
		value: system ? system.generator.power : 0
	}
/*
	CP.ColorImage {
		id: icon

		anchors {
			left: parent.left
			leftMargin: Theme.geometry.briefPage.edgeGauge.icon.leftMargin - root.strokeWidth / 2
			bottom: gaugeAlignmentY === Qt.AlignTop ? parent.bottom : undefined
			verticalCenter: gaugeAlignmentY === Qt.AlignTop ? undefined : parent.verticalCenter
		}
		width: Theme.geometry.valueDisplay.icon.width
		fillMode: Image.Pad
		source: "qrc:/images/generator.svg"
	}
	ValueQuantityDisplay {
		id: quantityRow

		anchors {
			verticalCenter: icon.verticalCenter
			left: icon.right
			leftMargin: Theme.geometry.briefPage.edgeGauge.quantity.leftMargin
		}
		font.pixelSize: Theme.font.size.l
		physicalQuantity: Units.Power
		value: system ? system.generator.power : 0
	}
	*/
	Rectangle {
		anchors.fill: parent
		color: "red"
		opacity: 0.1
	}
}

/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.Velib
import Victron.VenusOS
import QtQuick.Controls.impl as CP
import "/components/Utils.js" as Utils
import "../data"

// TODO
Item {
	id: root

	property int gaugeAlignmentY: Qt.AlignVCenter // valid values: Qt.AlignVCenter, Qt.AlignBottom
	property int gaugeAlignmentX: Qt.AlignLeft
	readonly property int maxAngle: gaugeAlignmentY === Qt.AlignVCenter ? Theme.geometry.briefPage.largeEdgeGauge.maxAngle : Theme.geometry.briefPage.smallEdgeGauge.maxAngle


	implicitHeight: gaugeAlignmentY === Qt.AlignVCenter ? Theme.geometry.briefPage.largeEdgeGauge.height : Theme.geometry.briefPage.smallEdgeGauge.height

	Repeater {
		id: repeater

		model: solarChargers ? solarChargers.model : null
		delegate: ScaledArcGauge {
			width: Theme.geometry.briefPage.edgeGauge.width
			x: index*strokeWidth
			opacity: 1.0 - index * 0.3
			height: root.height
			startAngle: root.gaugeAlignmentY === Qt.AlignVCenter ? 270 + maxAngle / 2 : 270
			endAngle: startAngle - maxAngle
			radius: Theme.geometry.briefPage.edgeGauge.radius - index*strokeWidth
			direction: PathArc.Counterclockwise
			strokeWidth: Theme.geometry.arc.strokeWidth
			arcY: root.gaugeAlignmentY === Qt.AlignVCenter ? undefined : -radius + strokeWidth/2
			value: 100 // solarTracker.power / Utils.maximumValue("solarTracker.power") * 100
		}
	}
	ArcGaugeValueDisplay {
		id: valueDisplay

		gaugeAlignmentX: root.gaugeAlignmentX
		gaugeAlignmentY: root.gaugeAlignmentY
		layoutDirection: root.gaugeAlignmentX === Qt.AlignRight ? Qt.RightToLeft : Qt.LeftToRight
		source: "qrc:/images/solaryield.svg"
		physicalQuantity: Units.Power
		value: 100 //solarTracker.power / Utils.maximumValue("solarTracker.power") * 100
	}

	/*
	CP.ColorImage {
		id: icon

		anchors {
			left: parent.left
			leftMargin: 36 - Theme.geometry.arc.strokeWidth / 2
			top: parent.top
		}
		width: Theme.geometry.valueDisplay.icon.width
		fillMode: Image.Pad
		source: "qrc:/images/solaryield.svg"
	}
	ValueQuantityDisplay {
		id: quantityRow

		anchors {
			verticalCenter: icon.verticalCenter
			left: icon.right
			leftMargin: 6
		}
		font.pixelSize: Theme.font.size.l
		physicalQuantity: Units.Power
		value: system ? system.generator.power : 0
	}
	ValueDisplay {
		id: valueDisplay

		anchors {
			left: repeater.left
			leftMargin: Theme.geometry.solarYieldGauge.valueDisplay.leftMargin
			verticalCenter: parent.verticalCenter
			verticalCenterOffset: Theme.geometry.solarYieldGauge.valueDisplay.verticalCenterOffset
		}
		title.text: qsTrId("brief_solar_yield")
		physicalQuantity: Units.Power
		value: solarChargers ? solarChargers.power : 0
		icon.source: "qrc:/images/solaryield.svg"
		fontSize: Theme.font.size.xl
	}
	*/
	Rectangle {
		anchors.fill: parent
		color: "green"
		opacity: 0.1
	}
}


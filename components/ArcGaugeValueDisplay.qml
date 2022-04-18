/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

Row {
	id: root

	property int gaugeAlignmentY: Qt.AlignTop // valid values: Qt.AlignTop, Qt.AlignBottom
	property int gaugeAlignmentX: Qt.AlignLeft
	property alias source: icon.source
	property alias value: quantityRow.value
	property alias physicalQuantity: quantityRow.physicalQuantity

	anchors {
		right: root.gaugeAlignmentX === Qt.AlignRight ? parent.right : undefined
		rightMargin: root.gaugeAlignmentX === Qt.AlignRight ? Theme.geometry.loadMiniGauge.label.rightMargin : undefined
		left: root.gaugeAlignmentX === Qt.AlignLeft ? parent.left : undefined
		leftMargin: root.gaugeAlignmentX === Qt.AlignLeft ? Theme.geometry.loadMiniGauge.label.rightMargin : undefined
		top: root.gaugeAlignmentY === Qt.AlignBottom ? parent.top : undefined
		verticalCenter: root.gaugeAlignmentY === Qt.AlignVCenter ? parent.verticalCenter : undefined
		bottom: root.gaugeAlignmentY ===  Qt.AlignTop ? parent.bottom : undefined
	}
	spacing: 4

	CP.ColorImage {
		id: icon

		anchors {
			top: root.gaugeAlignmentY === Qt.AlignBottom ? parent.top : undefined
			verticalCenter: root.gaugeAlignmentY === Qt.AlignVCenter ? parent.verticalCenter : undefined
			bottom: root.gaugeAlignmentY === Qt.AlignTop ? parent.bottom : undefined
		}

		width: Theme.geometry.valueDisplay.icon.width
		fillMode: Image.Pad
	}
	ValueQuantityDisplay {
		id: quantityRow

		anchors {
			verticalCenter: icon.verticalCenter
		}
		font.pixelSize: Theme.font.size.l
	}
}

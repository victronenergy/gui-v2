/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

Row {
	id: root

	property int gaugeAlignmentY: Qt.AlignTop // valid values: Qt.AlignTop, Qt.AlignVCenter, Qt.AlignBottom
	property int gaugeAlignmentX: Qt.AlignLeft // valid values: Qt.AlignLeft, Qt.AlignRight
	property alias icon: icon
	property alias quantityLabel: quantityLabel
	property real leftMargin

	// Use x/y bindings as the layout sometimes did not update dynamically when multiple anchor
	// bindings were used instead.
	x: root.gaugeAlignmentX === Qt.AlignLeft
	   ? Theme.geometry.loadMiniGauge.label.rightMargin + leftMargin
	   : parent.width - width - Theme.geometry.loadMiniGauge.label.rightMargin + leftMargin
	y: gaugeAlignmentY === Qt.AlignVCenter
	   ? parent.height/2 - height/2
	   : gaugeAlignmentY === Qt.AlignTop
		 ? parent.height - height
		 : 0    // root.gaugeAlignmentY === Qt.AlignBottom

	spacing: Theme.geometry.briefPage.edgeGauge.quantityLabel.spacing
	layoutDirection: root.gaugeAlignmentX === Qt.AlignRight ? Qt.RightToLeft : Qt.LeftToRight

	CP.ColorImage {
		id: icon

		width: Theme.geometry.widgetHeader.icon.width
		fillMode: Image.Pad
	}

	EnergyQuantityLabel {
		id: quantityLabel

		height: icon.height
		anchors.verticalCenter: icon.verticalCenter
		font.pixelSize: Theme.geometry.briefPage.edgeGauge.font.size
	}
}

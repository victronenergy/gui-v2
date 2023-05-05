/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

Row {
	id: root

	property int alignment: Qt.AlignTop | Qt.AlignLeft
	property alias icon: icon
	property alias quantityLabel: quantityLabel
	property real leftMargin

	// Use x/y bindings as the layout sometimes did not update dynamically when multiple anchor
	// bindings were used instead.
	x: root.alignment & Qt.AlignLeft
	   ? Theme.geometry.loadMiniGauge.label.rightMargin + leftMargin
	   : parent.width - width - Theme.geometry.loadMiniGauge.label.rightMargin + leftMargin
	y: alignment & Qt.AlignVCenter
	   ? parent.height/2 - height/2
	   : alignment & Qt.AlignTop
		 ? parent.height - height
		 : 0    // root.alignment & Qt.AlignBottom

	spacing: Theme.geometry.briefPage.edgeGauge.quantityLabel.spacing
	layoutDirection: root.alignment & Qt.AlignRight ? Qt.RightToLeft : Qt.LeftToRight

	CP.ColorImage {
		id: icon

		width: Theme.geometry.widgetHeader.icon.width
		fillMode: Image.Pad
		color: Theme.color.font.primary
	}

	ElectricalQuantityLabel {
		id: quantityLabel

		height: icon.height
		anchors.verticalCenter: icon.verticalCenter
		font.pixelSize: Theme.font.briefPage.quantityLabel.size
	}
}

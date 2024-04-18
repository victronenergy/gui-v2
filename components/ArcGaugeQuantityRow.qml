/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

Row {
	id: root

	property int alignment: Qt.AlignTop | Qt.AlignLeft
	property alias icon: icon
	property alias quantityLabel: quantityLabel

	// Use x/y bindings as the layout sometimes did not update dynamically when multiple anchor
	// bindings were used instead.
	x: root.alignment & Qt.AlignLeft
	   ? Theme.geometry_briefPage_edgeGauge_quantityLabel_horizontalMargin
	   : parent.width - width - Theme.geometry_briefPage_edgeGauge_quantityLabel_horizontalMargin
	y: alignment & Qt.AlignVCenter
	   ? parent.height/2 - height/2
	   : alignment & Qt.AlignBottom
		 ? parent.height - height - Theme.geometry_briefPage_edgeGauge_quantityLabel_bottomMargin
		 : Theme.geometry_briefPage_edgeGauge_quantityLabel_topMargin    // root.alignment & Qt.AlignTop

	spacing: Theme.geometry_briefPage_edgeGauge_quantityLabel_spacing
	layoutDirection: root.alignment & Qt.AlignRight ? Qt.RightToLeft : Qt.LeftToRight

	CP.ColorImage {
		id: icon

		anchors.verticalCenter: parent.verticalCenter
		width: Theme.geometry_widgetHeader_icon_width
		fillMode: Image.Pad
		color: Theme.color_font_primary
	}

	ElectricalQuantityLabel {
		id: quantityLabel

		height: icon.height
		anchors.verticalCenter: parent.verticalCenter
		font.pixelSize: Theme.font_briefPage_quantityLabel_size
	}
}

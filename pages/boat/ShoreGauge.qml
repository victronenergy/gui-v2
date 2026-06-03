/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

Row {
	id: root

	spacing: Theme.geometry_boatPage_row_spacing

	CP.ColorImage {
		id: icon

		anchors.verticalCenter: parent.verticalCenter
		width: Theme.geometry_boatPage_shoreGauge_icon_size
		height: width
		color: Theme.color_boatPage_icon
		source: "qrc:/images/shore.svg"
	}

	ElectricalQuantityLabel {
		id: label

		anchors.verticalCenter: parent.verticalCenter
		font.pixelSize: Theme.font_boatPage_shoreGauge_label_pixelSize
		sourceType: VenusOS.ElectricalQuantity_Source_Ac
		dataObject: Global.acInputs.activeInSource === VenusOS.AcInputs_InputSource_Shore ? Global.acInputs.highlightedInput : null
	}
}
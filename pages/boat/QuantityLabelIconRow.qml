/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import QtQuick.Controls.impl as CP

Row {
	id: root

	property alias dataObject: label.dataObject
	property alias value: label.value
	property alias icon: icon
	property alias font: label.font

	spacing: Theme.geometry_boatPage_row_spacing

	ElectricalQuantityLabel {
		id: label

		anchors.verticalCenter: parent.verticalCenter
		verticalAlignment: Text.AlignVCenter
		font.pixelSize: Theme.font_boatPage_batterySoc_pixelSize
	}

	CP.ColorImage {
		id: icon

		anchors.verticalCenter: parent.verticalCenter
		width: Theme.geometry_boatPage_batteryGauge_iconWidth
		height: width
		color: Theme.color_boatPage_icon
	}
}

/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.BoatPageComponents as BoatPageComponents
import QtQuick.Controls.impl as CP
import Victron.VenusOS
import Victron.Gauges

Row {
	required property VeQuickItem veQuickItem
	required property int unit
	required property string source

	spacing: Theme.geometry_boatPage_motorDrive_temperaturesRow_spacing

	QuantityLabel {
		anchors.verticalCenter: parent.verticalCenter
		verticalAlignment: Text.AlignVCenter
		font.pixelSize: Theme.geometry_boatPage_batteryTemperature_pixelSize
		value: veQuickItem && veQuickItem.value || 0
		unit: parent.unit
	}

	CP.ColorImage {
		anchors.verticalCenter: parent.verticalCenter
		color: Theme.color_boatPage_icon
		source: parent.source
	}
}

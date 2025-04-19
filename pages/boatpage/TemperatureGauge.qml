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
	required property VeQuickItem dataItem
	required property string iconSource

	spacing: Theme.geometry_boatPage_row_spacing
	visible: dataItem && dataItem.valid

	QuantityLabel {
		anchors.verticalCenter: parent.verticalCenter
		verticalAlignment: Text.AlignVCenter
		font.pixelSize: Theme.font_boatPage_batteryTemperature_pixelSize
		value: dataItem && dataItem.valid ? dataItem.value : NaN
		unit: Global.systemSettings.temperatureUnit
	}

	CP.ColorImage {
		anchors.verticalCenter: parent.verticalCenter
		color: Theme.color_boatPage_icon
		source: parent.iconSource
	}
}

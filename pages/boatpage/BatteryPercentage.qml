/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

Row {
	id: row

	readonly property var battery: Global.system && Global.system.battery ? Global.system.battery : null

	spacing: Theme.geometry_boatPage_batteryGauge_rowSpacing

	CP.ColorImage {
		anchors.verticalCenter: parent.verticalCenter
		width: Theme.geometry_boatPage_batteryGauge_iconWidth
		height: width
		color: Theme.color_font_primary
		source: "qrc:/images/icon_battery_40.png"
	}

	QuantityLabel {
		id: stateOfCharge

		anchors.verticalCenter: parent.verticalCenter
		font.pixelSize: Theme.geometry_boatPage_batterySoc_pixelSize
		unit: VenusOS.Units_Percentage
		value: battery.stateOfCharge
	}
}

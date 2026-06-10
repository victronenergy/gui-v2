/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

Row {
	id: root

	required property MotorDrives motorDrives

	spacing: Theme.geometry_boatPage_row_spacing

	CP.ColorImage {
		anchors.verticalCenter: parent.verticalCenter
		width: Theme.geometry_boatPage_batteryGauge_iconWidth
		height: width
		color: (Global.system.battery.mode === VenusOS.Battery_Mode_Charging || root.motorDrives.isRegenerating)
			? Theme.color_boatPage_regenProgress
			: Theme.color_font_primary
		source: (Global.system.battery.mode === VenusOS.Battery_Mode_Charging || root.motorDrives.isRegenerating)
			? "qrc:/images/icon_battery_charging_24.svg"
			: "qrc:/images/icon_battery_24.svg"
	}

	QuantityLabel {
		id: stateOfCharge

		anchors.verticalCenter: parent.verticalCenter
		font.pixelSize: Theme.font_boatPage_batterySoc_pixelSize
		unit: VenusOS.Units_Percentage
		value: Global.system.battery.stateOfCharge
	}
}

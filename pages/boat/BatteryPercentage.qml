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

	readonly property ActiveSystemBattery battery: Global.system && Global.system.battery ? Global.system.battery : null

	spacing: Theme.geometry_boatPage_row_spacing
	visible: battery && !isNaN(battery.stateOfCharge)

	CP.ColorImage {
		anchors.verticalCenter: parent.verticalCenter
		width: Theme.geometry_boatPage_batteryGauge_iconWidth
		height: width
		color: root.motorDrives.isRegenerating ? Theme.color_boatPage_regenProgress : Theme.color_font_primary
		source: root.motorDrives.isRegenerating ? "qrc:/images/icon_battery_charging_24.svg" : "qrc:/images/icon_battery_24.svg"
	}

	QuantityLabel {
		id: stateOfCharge

		anchors.verticalCenter: parent.verticalCenter
		font.pixelSize: Theme.font_boatPage_batterySoc_pixelSize
		unit: VenusOS.Units_Percentage
		value: battery.stateOfCharge
	}
}

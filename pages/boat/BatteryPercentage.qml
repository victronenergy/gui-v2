/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

Row {
	id: root

	required property Gps gps
	required property MotorDrives motorDrives
	required property bool isShoreConnected
	required property bool isBatteryCharging

	// The boat is considered moving if the GPS speed is above 0.2 m/s (0.72 km/h).
	readonly property bool isMoving: root.gps.valid && root.gps.numerator > 0.2

	spacing: Theme.geometry_boatPage_row_spacing

	Item {
		width: Theme.geometry_boatPage_batteryGauge_iconWidth - Theme.geometry_boatPage_row_spacing
		height: Theme.geometry_boatPage_batteryGauge_iconWidth

		CP.ColorImage {
			anchors.verticalCenter: parent.verticalCenter
			width: Theme.geometry_boatPage_batteryGauge_iconWidth
			height: width
			color: (root.isBatteryCharging || root.motorDrives.isRegenerating)
				? Theme.color_boatPage_regenProgress
				: Theme.color_font_primary
			source: (isBatteryCharging || root.motorDrives.isRegenerating)
				? "qrc:/images/icon_battery_charging_24.svg"
				: "qrc:/images/icon_battery_24.svg"
		}
	}

	QuantityLabel {
		id: stateOfCharge

		anchors.verticalCenter: parent.verticalCenter
		font.pixelSize: Theme.font_boatPage_batterySoc_pixelSize
		unit: VenusOS.Units_Percentage
		value: Global.system.battery.stateOfCharge
	}

	CP.ColorImage {
		id: icon

		anchors.verticalCenter: parent.verticalCenter
		visible: isShoreConnected
		width: Theme.geometry_boatPage_shoreGauge_icon_size
		height: width
		fillMode: Image.PreserveAspectFit
		color: isMoving ? Theme.color_red : Theme.color_orange
		source: isMoving ? "qrc:/images/icon_shore_error.svg" : "qrc:/images/icon_shore.svg"
	}
}

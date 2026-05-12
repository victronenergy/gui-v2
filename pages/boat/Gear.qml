/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Item {
	id: root

	required property MotorDrive motorDrive
	readonly property int direction: motorDrive.direction.valid ? motorDrive.direction.value : NaN

	implicitWidth: gearLabel.width
	implicitHeight: gearLabel.height

	visible: motorDrive.direction.valid

	Label {
		id: gearLabel

		color: {
			switch (direction) {
				case VenusOS.MotorDriveGear_Forward:
					return Theme.color_boatPage_regenProgress
				case VenusOS.MotorDriveGear_Reverse:
					return Theme.color_temperatureslider_gradient_max_border
				case VenusOS.MotorDriveGear_Neutral:
				default:
					return Theme.color_font_primary
			}
		}
		font.pixelSize: Theme.font_boatPage_gear_pixelSize
		width: Theme.geometry_boatPage_gearIndicator_width
		horizontalAlignment: Text.AlignHCenter
		text: {
			switch (direction) {
				case VenusOS.MotorDriveGear_Forward:
					return "F"
				case VenusOS.MotorDriveGear_Reverse:
					return "R"
				case VenusOS.MotorDriveGear_Neutral:
				default:
					return "N"
			}
		}
	}
}


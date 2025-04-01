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
	id: root

	readonly property int direction: _direction.valid ? _direction.value : NaN
	readonly property var _motorDrive: Global.allDevicesModel.motorDriveDevices.firstObject

	spacing: Theme.geometry_boatPage_gearRow_spacing

	VeQuickItem { //  0=neutral, 1=reverse, 2=forward (optional)
		id: _direction

		uid: _motorDrive ? _motorDrive.serviceUid + "/Motor/Direction" : ""
	}

	component GearIndicator : Label {
		required property int gear

		color: direction === gear ? Theme.color_font_primary : Theme.color_font_secondary
		font.pixelSize: Theme.geometry_boatPage_gear_pixelSize
		width: Theme.geometry_boatPage_gearIndicator_width
		height: width
		horizontalAlignment: Text.AlignHCenter

		Rectangle {
			anchors {
				bottom: parent.top
				bottomMargin: Theme.geometry_boatPage_gearHighlighter_bottomMargin
				horizontalCenter: parent.horizontalCenter
			}
			radius: Theme.geometry_boatPage_gearHighlighter_radius
			height: Theme.geometry_boatPage_gearHighlighter_height
			width: Theme.geometry_boatPage_gearHighlighter_width
			color: Theme.color_boatPage_gearHighlighter
			visible: direction === gear
		}
	}

	GearIndicator {
		gear: VenusOS.MotorDriveGear_Forward
		text: "F" // intentionally not translated
	}

	GearIndicator {
		gear: VenusOS.MotorDriveGear_Neutral
		text: "N" // intentionally not translated
	}

	GearIndicator {
		gear: VenusOS.MotorDriveGear_Reverse
		text: "R" // intentionally not translated
	}
}


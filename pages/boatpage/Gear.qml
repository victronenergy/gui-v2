/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.BoatPageComponents as BoatPageComponents
import QtQuick.Controls.impl as CP
import Victron.VenusOS
import Victron.Gauges

// Only show the "F N R" if the /Motor/Direction path exists and has valid data
Row {
	id: root

	readonly property int direction: _direction.valid ? _direction.value : NaN
	readonly property var _motorDrive: Global.allDevicesModel.motorDriveDevices.firstObject

	spacing: Theme.geometry_boatPage_gearRow_spacing
	visible: _direction.valid

	VeQuickItem { //  0=neutral, 1=reverse, 2=forward (optional)
		id: _direction

		uid: _motorDrive ? _motorDrive.serviceUid + "/Motor/Direction" : ""
	}

	component GearIndicator : Item {
		required property int gear
		property alias text: gearLabel.text

		width: Theme.geometry_boatPage_gearHighlighter_width
		height: Theme.geometry_boatPage_gearHighlighter_height + Theme.geometry_boatPage_gear_verticalMargin + gearLabel.height

		Rectangle {
			id: highlighter

			anchors {
				top: parent.top
				horizontalCenter: parent.horizontalCenter
			}
			radius: Theme.geometry_boatPage_gearHighlighter_radius
			height: Theme.geometry_boatPage_gearHighlighter_height
			width: Theme.geometry_boatPage_gearHighlighter_width
			color: Theme.color_boatPage_gearHighlighter
			visible: direction === gear
		}

		Label {
			id: gearLabel

			anchors {
				horizontalCenter: parent.horizontalCenter
				bottom: parent.bottom
			}
			color: direction === parent.gear ? Theme.color_font_primary : Theme.color_font_secondary
			font.pixelSize: Theme.font_boatPage_gear_pixelSize
			width: Theme.geometry_boatPage_gearIndicator_width
			horizontalAlignment: Text.AlignHCenter
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


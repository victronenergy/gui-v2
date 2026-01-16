/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Gauges

// Only show the "F N R" if the /Motor/Direction path exists and has valid data
Row {
	id: root

	required property MotorDrive motorDrive
	readonly property int direction: motorDrive.direction.valid ? motorDrive.direction.value : NaN

	spacing: Theme.geometry_boatPage_gearRow_spacing
	visible: motorDrive.direction.valid

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


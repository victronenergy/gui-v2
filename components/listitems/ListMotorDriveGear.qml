/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListItem {
	id: root

	readonly property alias dataItem: dataItem

	VeQuickItem {
		id: dataItem
	}

	content.children: [
		Row {
			id: gearRow

			spacing: Theme.geometry_listItem_content_spacing
			visible: dataItem.valid

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
	]

	component GearIndicator : Item {
		required property int gear
		property alias text: gearLabel.text

		width: gearLabel.width
		height: gearLabel.height

		Label {
			id: gearLabel

			anchors {
				horizontalCenter: parent.horizontalCenter
				bottom: parent.bottom
			}
			color: dataItem.value === parent.gear ? Theme.color_font_primary : Theme.color_font_secondary
			font.pixelSize: Theme.font_size_body2
			horizontalAlignment: Text.AlignHCenter
		}
	}
}

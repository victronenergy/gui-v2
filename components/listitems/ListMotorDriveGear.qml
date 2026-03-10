/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import Victron.VenusOS

ListSetting {
	id: root

	readonly property alias dataItem: dataItem

	VeQuickItem {
		id: dataItem
	}

	contentItem: RowLayout {
		spacing: root.spacing

		Label {
			text: root.text
			textFormat: root.textFormat
			font: root.font
			wrapMode: Text.Wrap

			Layout.fillWidth: true
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

	component GearIndicator : Label {
		required property int gear

		color: dataItem.value === gear ? Theme.color_font_primary : Theme.color_font_secondary
		font.pixelSize: Theme.font_size_body2
		visible: dataItem.valid
	}
}

/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

// Displays measurements for one or more phases.
// For OverviewWidget_Size_XS / S:
//  - show 3 columns, with quantities below the phase names
// For OverviewWidget_Size_M and above:
//  - show 3 rows, with quantities and phase names on the same line.
//  - for OverviewWidget_Size_L / XL, use a larger font size.

Flow {
	id: root

	property alias model: phaseRepeater.model
	property int widgetSize: VenusOS.OverviewWidget_Size_S

	Repeater {
		id: phaseRepeater

		delegate: Item {
			width: root.widgetSize <= VenusOS.OverviewWidget_Size_S
				   ? parent.width / 3
				   : parent.width
			height: root.widgetSize <= VenusOS.OverviewWidget_Size_S
					? quantityLabel.y + quantityLabel.height
					: phaseLabel.height

			Label {
				id: phaseLabel

				text: model.name + ":"
				color: Theme.color_font_secondary
				font.pixelSize: root.widgetSize >= VenusOS.OverviewWidget_Size_L
						? Theme.font_size_body1
						: Theme.font_size_phase_small
			}

			ElectricalQuantityLabel {
				id: quantityLabel

				// Using x/y positioning; anchor changes do not work reliably when dynamically
				// changing the overview widgets layout.
				// For size XS / S: QuantityLabel is below phaseLabel.
				// For size M+: QuantityLabel is on the right.
				x: root.widgetSize <= VenusOS.OverviewWidget_Size_S ? 0 : parent.width - width
				y: root.widgetSize <= VenusOS.OverviewWidget_Size_S
						? phaseLabel.height + Theme.geometry_three_phase_column_spacing
						: 0
				dataObject: model
				font.pixelSize: phaseLabel.font.pixelSize
				unitVisible: root.widgetSize >= VenusOS.OverviewWidget_Size_M
			}
		}
	}
}

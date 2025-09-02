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

	required property PhaseModel model
	property int widgetSize: VenusOS.OverviewWidget_Size_S

	// These properties are used to change the text color depending on the phase value.
	property int valueType: VenusOS.Gauges_ValueType_NeutralPercentage
	property real minimumValue
	property real maximumValue

	// If true, the color text will be green when the phase is feeding back to the grid.
	property bool inputMode

	readonly property real availableWidth: width - leftPadding - rightPadding

	Repeater {
		id: phaseRepeater

		model: root.model
		delegate: Item {
			id: phaseDelegate

			required property int index
			required property real power
			required property real current
			required property string name

			readonly property bool feedingToGrid: root.inputMode && power < -1.0 // ignore noise values (close to zero)
			readonly property int valueStatus: Theme.getValueStatus(valueRange.valueAsRatio * 100, root.valueType)
			readonly property bool criticalOrWarning: valueStatus === Theme.Critical || valueStatus === Theme.Warning
			readonly property color textColor: Theme.color_darkOk,feedingToGrid ? Theme.color_green
					: criticalOrWarning ? Theme.statusColorValue(valueStatus)
					: Theme.color_font_primary

			width: root.widgetSize <= VenusOS.OverviewWidget_Size_S
				   ? root.availableWidth / 3
				   : root.availableWidth
			height: root.widgetSize <= VenusOS.OverviewWidget_Size_S
					? quantityLabel.y + quantityLabel.height
					: phaseLabel.height

			Label {
				id: phaseLabel

				text: phaseDelegate.name + ":"
				color: quantityLabel.unitColor
				font.pixelSize: root.widgetSize >= VenusOS.OverviewWidget_Size_L
						? Theme.font_size_body1
						: Theme.font_overviewPage_phase_pixelSize
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
				dataObject: QtObject {
					readonly property real power: phaseDelegate.power
					readonly property real current: phaseDelegate.current
				}
				font.pixelSize: phaseLabel.font.pixelSize
				valueColor: phaseDelegate.textColor
				unitColor: valueColor == Theme.color_font_primary
						   ? Theme.color_font_secondary
						   : phaseDelegate.textColor
			}

			ValueRange {
				id: valueRange

				value: phaseDelegate.current
				minimumValue: root.minimumValue
				maximumValue: root.maximumValue
			}
		}
	}
}

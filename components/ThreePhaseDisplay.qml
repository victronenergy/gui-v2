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

	// These properties are used to change the text color depending on the phase value.
	property int valueType: VenusOS.Gauges_ValueType_NeutralPercentage
	property string phaseModelProperty
	property real minimumValue
	property real maximumValue

	// If true, the color text will be green when the phase is feeding back to the grid.
	property bool inputMode

	Repeater {
		id: phaseRepeater

		delegate: Item {
			id: phaseDelegate

			// ignore noise values (close to zero)
			readonly property real modelValue: Math.floor(Math.abs(model[root.phaseModelProperty] || 0)) < 1.0 ? 0.0 : model[root.phaseModelProperty]
			readonly property bool feedingToGrid: root.inputMode && modelValue < 0.0
			readonly property int valueStatus: feedingToGrid ? Theme.Ok : root.phaseModelProperty ? Theme.getValueStatus(valueRange.valueAsRatio * 100, root.valueType) : Theme.Ok
			readonly property bool criticalOrWarning: valueStatus === Theme.Critical || valueStatus === Theme.Warning
			readonly property color textColor: Theme.color_darkOk, feedingToGrid ? Theme.color_green : criticalOrWarning ? Theme.statusColorValue(valueStatus) : Theme.color_font_primary

			width: root.widgetSize <= VenusOS.OverviewWidget_Size_S ? parent.width / 3 : parent.width
			height: root.widgetSize <= VenusOS.OverviewWidget_Size_S ? quantityLabel.y + quantityLabel.height : phaseLabel.height

			Label {
				id: phaseLabel

				text: model.name + ":"
				color: quantityLabel.unitColor
				font.pixelSize: root.widgetSize >= VenusOS.OverviewWidget_Size_L ? Theme.font_size_body1 : Theme.font_overviewPage_phase_pixelSize
			}

			ElectricalQuantityLabel {
				id: quantityLabel

				// Using x/y positioning; anchor changes do not work reliably when dynamically
				// changing the overview widgets layout.
				// For size XS / S: QuantityLabel is below phaseLabel.
				// For size M+: QuantityLabel is on the right.
				x: root.widgetSize <= VenusOS.OverviewWidget_Size_S ? 0 : parent.width - width
				y: root.widgetSize <= VenusOS.OverviewWidget_Size_S ? phaseLabel.height + Theme.geometry_three_phase_column_spacing : 0
				dataObject: model
				font.pixelSize: phaseLabel.font.pixelSize
				valueColor: phaseDelegate.textColor
				unitColor: valueColor == Theme.color_font_primary ? Theme.color_font_secondary : phaseDelegate.textColor
			}

			ValueRange {
				id: valueRange

				value: phaseDelegate.modelValue
				minimumValue: root.minimumValue
				maximumValue: root.maximumValue
			}
		}
	}
}

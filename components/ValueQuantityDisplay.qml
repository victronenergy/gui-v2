/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

Row {
	id: root

	property real value: NaN   // in SI units, eg. 1234 for 1234W
	property var physicalQuantity: Units.Power // eg. Units.Voltage, Units.Current, Units.Power
	property int precision: 3 // this will display 1.23kW, given a value of 1234
	property alias valueColor: valueLabel.color
	property alias font: valueLabel.font

	readonly property var _displayValue: Units.getDisplayText(physicalQuantity, value, precision)

	spacing: Theme.geometry.valueDisplay.quantityRow.spacing

	// Restrict the height to the baseline to align the baseline of labels in different
	// ValueQuantityDisplay items with different font sizes (e.g. horizontally-aligned
	// EnvironmentGauge labels with different sizes).
	height: Math.ceil(valueLabel.baselineOffset)

	Label {
		id: valueLabel

		color: Theme.color.font.primary
		text: root._displayValue.number
	}

	Label {
		id: unitLabel

		text: root._displayValue.units
		font: valueLabel.font
		color: Theme.color.font.secondary
	}
}

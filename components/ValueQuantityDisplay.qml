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

	Label {
		id: valueLabel

		anchors.verticalCenter: parent.verticalCenter
		color: Theme.color.font.primary
		text: root._displayValue.number
	}

	Label {
		id: unitLabel

		anchors.verticalCenter: parent.verticalCenter
		opacity: 0.7 // TODO: use a Theme color instead
		text: root._displayValue.units
		font: valueLabel.font
	}
}

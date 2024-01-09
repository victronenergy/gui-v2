/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Item {
	id: root

	property real value
	property int unit: VenusOS.Units_None
	property alias font: valueLabel.font
	property alias valueColor: valueLabel.color
	property alias unitColor: unitLabel.color
	property int alignment: Qt.AlignHCenter
	property int precision: Units.defaultUnitPrecision(unit)

	readonly property quantityInfo _quantity: Units.getDisplayText(unit, value, precision)

	// Restrict the height to the baseline to help align the baseline of labels in different
	// QuantityLabel items with different font sizes. E.g. Environments tab may have multiple gauges
	// with different font sizes, that need to align side-by-side at the font baseline.
	implicitHeight: Math.ceil(valueLabel.baselineOffset) + Theme.geometry_quantityLabel_bottomMargin

	// For width, we want fixed-for-text-length-width for the value and units labels.
	// Cache some values to reduce binding re-evaluations.
	readonly property int _unitLength: unitLabel.text.length
	readonly property int _valueLength: valueLabel.text.length
	readonly property bool _containsDot: (valueLabel.text.indexOf('.') >= 0) || (valueLabel.text.indexOf(',') >= 0)
	readonly property real _dotDeltaWidth: _containsDot ? Theme.characterDotDeltaWidth(valueLabel.font) : 0
	readonly property bool _containsMinus: valueLabel.text.indexOf('-') >= 0
	readonly property real _minusDeltaWidth: _containsMinus ? Theme.characterMinusDeltaWidth(valueLabel.font) : 0
	// special case "100" for cases where "100" is the largest possible value
	// since 99 will always been thinner than 100, but no 104 or 444 is possible.
	readonly property real _oneHundredWidth: (root.unit === VenusOS.Units_Percentage
			&& _valueLength === 3 && !_containsMinus && !_containsDot)
			? Theme.charactersOneHundredWidth(valueLabel.font) : 0
	readonly property real _valueDigitsWidth: _valueLength * (Theme.characterWidthNumber(valueLabel.font) + Theme.characterAdvanceWidth(valueLabel.font))
	readonly property int _quantityLabelSpacing: Theme.geometry_quantityLabel_spacing
	readonly property real _implicitValueWidth: (_oneHundredWidth !== 0 ? _oneHundredWidth
				: (_valueDigitsWidth - _dotDeltaWidth - _minusDeltaWidth)) + 4 // some extra space for inaccuracy from FontMetrics.
	readonly property real _implicitUnitWidth: _unitLength*Theme.characterWidthAlpha(unitLabel.font) + Theme.characterAdvanceWidth(unitLabel.font)
	implicitWidth: _implicitValueWidth + _quantityLabelSpacing + _implicitUnitWidth

	Label {
		id: valueLabel

		y: (root.height - height)/2
		x: root.alignment === Qt.AlignLeft ? 0
			: root.alignment === Qt.AlignRight ? root.width - width - _quantityLabelSpacing - unitLabel.width
			: (root.width - width - _quantityLabelSpacing - unitLabel.width)/2
		color: Theme.color_font_primary
		text: root._quantity.number
		width: Math.min(_implicitValueWidth, root.width - _quantityLabelSpacing - unitLabel.width)
		elide: Text.ElideRight
		// Usually align right, to reduce gap between units label text and value text
		// (since we usually over-allocate space for value, due to fixed-width).
		// But if we intentionally left align the whole thing, then left align the value text.
		horizontalAlignment: root.alignment & Qt.AlignLeft ? Text.AlignLeft : Text.AlignRight
	}

	Label {
		id: unitLabel

		y: valueLabel.y
		x: valueLabel.x + valueLabel.width + _quantityLabelSpacing

		text: root._quantity.unit
		font: valueLabel.font
		color: Theme.color_font_secondary
		horizontalAlignment: root.alignment & Qt.AlignHCenter ? Text.AlignHCenter
			: root.alignment & Qt.AlignLeft ? Text.AlignLeft
			: Text.AlignRight
	}
}

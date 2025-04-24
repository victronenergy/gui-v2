/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/
import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	required property string numeratorUid
	required property string denominatorUid

	// this may be an int or a float, so we can't use 'real' here
	readonly property var numerator: _numerator.valid ? _numerator.value : NaN

	// this may be an int or a float, so we can't use 'real' here
	readonly property var denominator: _denominator.valid ? _denominator.value : NaN
	readonly property real normalizedValue: denominator === 0 ? NaN : numerator / denominator
	readonly property real percentage: 100 * normalizedValue
	readonly property bool valid: numeratorUid && denominatorUid && !isNaN(percentage)
	required property int sourceUnit
	required property int displayUnit

	property VeQuickItem _numerator: VeQuickItem {
		sourceUnit: Units.unitToVeUnit(root.sourceUnit)
		displayUnit: Units.unitToVeUnit(root.displayUnit)
	}
	property VeQuickItem _denominator: VeQuickItem {
		sourceUnit: Units.unitToVeUnit(root.sourceUnit)
		displayUnit: Units.unitToVeUnit(root.displayUnit)
	}

	onNumeratorUidChanged: {
		if (numeratorUid && !_numerator.uid) {
			_numerator.uid = numeratorUid
		}
	}
	onDenominatorUidChanged: {
		if (denominatorUid && !_denominator.uid) {
			_denominator.uid = denominatorUid
		}
	}
}

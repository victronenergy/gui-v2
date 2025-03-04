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
	required property int unit
	readonly property var numerator: _numerator.valid ? _numerator.value : NaN
	readonly property var denominator: _denominator.valid ? _denominator.value : NaN
	readonly property real normalizedValue: numerator / denominator
	readonly property real percentage: 100 * normalizedValue
	readonly property bool valid: !isNaN(percentage)

	property VeQuickItem _numerator: VeQuickItem { }
	property VeQuickItem _denominator: VeQuickItem { }

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

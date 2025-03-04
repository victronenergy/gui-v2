/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/
import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	property string numeratorUid
	property string denominatorUid
	readonly property var numerator: _numerator.valid ? _numerator.value : NaN
	property var denominator: _denominator.valid ? _denominator.value : NaN // TODO - make this readonly once ".../Settings/Gui/Gauges/Speed/Max" has platform support
	readonly property real normalizedValue: numerator / denominator
	readonly property real percentage: 100 * normalizedValue

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

/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

NumberSelectorDialog {
	id: root

	property int inputType: -1
	property int inputIndex

	title: Global.acInputs.currentLimitTypeToText(inputType)
	suffix: Units.defaultUnitString(VenusOS.Units_Amp)
	stepSize: 1
	to: 1000
	decimals: 1
}

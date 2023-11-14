/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

NumberSelectorDialog {
	property var inputSettings
	property int inputIndex

	title: Global.acInputs.currentLimitTypeToText(inputSettings ? inputSettings.inputType : 0)
	suffix: "A"
	stepSize: 1
	to: 1000
	decimals: 1
}

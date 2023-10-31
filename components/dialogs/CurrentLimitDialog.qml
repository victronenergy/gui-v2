/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

NumberSelectorDialog {
	id: root

	property var inputSettings
	property int inputIndex

	function openDialog(inputSettings, index) {
		root.inputSettings = inputSettings
		root.inputIndex = index
		root.value = inputSettings.currentLimit
		open()
	}

	title: Global.acInputs.currentLimitTypeToText(inputSettings ? inputSettings.inputType : 0)
	suffix: "A"
	stepSize: 1
	to: 1000
	decimals: 1
}

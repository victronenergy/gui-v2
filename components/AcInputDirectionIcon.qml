/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

// When ESS feedback to grid is enabled, show an arrow indicating the flow direction.
CP.ColorImage {
	visible: Global.systemSettings.essFeedbackToGridEnabled && Global.acInputs.activeInput
	source: !!Global.acInputs.activeInput
			? (Global.acInputs.activeInput.power < 0 ? "qrc:/images/icon_to_grid.svg" : "qrc:/images/icon_from_grid.svg")
			: ""
	color: !Global.acInputs.activeInput || (Global.acInputs.activeInput.power || 0) === 0 ? Theme.color_background_disabled
			: Global.acInputs.activeInput.power < 0 ? Theme.color_green
			: Theme.color_blue
}

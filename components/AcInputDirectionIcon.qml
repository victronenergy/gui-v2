/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

// When the power is negative, show the "<" green arrow, and don't show a minus symbol. Do this
// regardless of whether ESS feedback is enabled.
// When the power is positive, show the ">" blue arrow if ESS feedback is enabled.
CP.ColorImage {
	required property AcInput input

	visible: input && (input.power < 0 || Global.system.feedbackEnabled)
	source: !!input
			? (input.power < 0 ? "qrc:/images/icon_to_grid.svg" : "qrc:/images/icon_from_grid.svg")
			: ""
	color: !input || (input.power || 0) === 0 ? Theme.color_background_disabled
			: input.power < 0 ? Theme.color_green
			: Theme.color_blue
}

/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Rectangle {
	implicitWidth: modeLabel.implicitWidth
	implicitHeight: modeLabel.implicitHeight
	topLeftRadius: Theme.geometry_radius_8
	topRightRadius: Theme.geometry_radius_8
	color: Theme.color_demoModeIndicator_background

	Label {
		id: modeLabel

		leftPadding: Theme.geometry_space_12
		rightPadding: Theme.geometry_space_12
		topPadding: Theme.geometry_demoModeIndicator_topPadding
		bottomPadding: Theme.geometry_demoModeIndicator_bottomPadding
		color: Theme.color_demoModeIndicator_foreground
		font.pixelSize: Theme.font_demoModeIndicator_size
		font.capitalization: Font.AllUppercase
		font.letterSpacing: Theme.font_demoModeIndicator_letterSpacing
		//% "Demo mode"
		text: qsTrId("demo_mode_indicator_text")
	}
}

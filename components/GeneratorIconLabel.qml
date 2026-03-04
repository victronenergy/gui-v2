/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

Label {
	id: root

	required property Generator generator

	leftPadding: icon.width + Theme.geometry_generatorIconLabel_icon_margin
	font.pixelSize: Theme.font_size_body2
	color: root.generator && root.generator_runtime > 0 ? Theme.color_font_primary : Theme.color_font_secondary
	verticalAlignment: Text.AlignVCenter

	// When generator runtime < 60 it has second precision, otherwise when >= 60, it is only
	// updated every minute. So, show mm:ss when < 60, and hh:mm when >= 60.
	text: root.generator && root.generator.state !== VenusOS.Generators_State_Stopped && root.generator.runtime !== 0
			? Utils.formatGeneratorRuntime(root.generator.runtime)
			: "--:--"

	CP.IconImage {
		id: icon

		anchors.verticalCenter: parent.verticalCenter
		width: visible ? Theme.geometry_generatorIconLabel_icon_width : 0
		height: Theme.geometry_generatorIconLabel_icon_width
		color: Theme.color_font_primary
		visible: root.generator && root.generator.state !== VenusOS.Generators_RunningBy_NotRunning
		source: {
			if (!visible) {
				return ""
			}
			if (root.generator.runningBy === VenusOS.Generators_RunningBy_Manual) {
				if (root.generator.manualStartTimer > 0) {
					return "qrc:/images/icon_manualstart_timer_24.svg"
				} else {
					return "qrc:/images/icon_manualstart_24.svg"
				}
			}
			return "qrc:/images/icon_autostart_24.svg"
		}
	}
}

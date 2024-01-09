/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls as C
import QtQuick.Controls.impl as CP
import Victron.VenusOS

Item {
	id: root

	property Generator generator
	property alias fontSize: label.font.pixelSize

	implicitHeight: label.height
	implicitWidth: label.x + label.width

	CP.IconImage {
		id: icon

		anchors.top: label.top
		width: Theme.geometry_generatorIconLabel_icon_width
		height: Theme.geometry_generatorIconLabel_icon_width
		color: Theme.color_font_primary
		source: {
			if (!root.generator || root.generator.state === VenusOS.Generators_RunningBy_NotRunning) {
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

	Label {
		id: label

		anchors {
			left: icon.right
			leftMargin: Theme.geometry_generatorIconLabel_icon_margin
		}
		width: Theme.geometry_generatorIconLabel_duration_width
				* (root.generator && root.generator.runtime > 60 * 60 ? 1.5 : 1)    // wider if over an hour
		font.pixelSize: Theme.font_size_body2
		color: root.generator && root.generator_runtime > 0 ? Theme.color_font_primary : Theme.color_font_secondary

		// When generator runtime < 60 it has second precision, otherwise when >= 60, it is only
		// updated every minute. So, show mm:ss when < 60, and hh:mm when >= 60.
		text: root.generator && root.generator.state !== VenusOS.Generators_State_Stopped && root.generator.runtime !== 0
				? root.generator.runtime < 60
				  ? Utils.formatAsHHMMSS(root.generator.runtime)
				  : Utils.formatAsHHMMSS(root.generator.runtime / 60)
				: "--:--"
	}
}

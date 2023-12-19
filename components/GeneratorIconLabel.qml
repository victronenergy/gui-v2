/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Utils

Item {
	id: root

	property var generator

	implicitHeight: icon.height
	implicitWidth: label.x + label.width

	Image {
		id: icon

		width: Theme.geometry.generatorIconLabel.icon.width
		height: Theme.geometry.generatorIconLabel.icon.width
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

	FixedWidthLabel {
		id: label

		anchors.left: icon.right
		text: root.generator
			  ? root.generator.state !== VenusOS.Generators_State_Running
				? "--:--"
				: Utils.formatAsHHMMSS(root.generator.runtime)
			  : ""
		font.pixelSize: Theme.font.size.body2
		color: root.generator && root.generator.runtime > 0 ? Theme.color.font.primary : Theme.color.font.secondary
	}
}

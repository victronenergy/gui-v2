/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Controls as C
import QtQuick.Controls.impl as CP
import Victron.VenusOS
import "/components/Utils.js" as Utils

Item {
	id: root

	property var generator

	implicitHeight: icon.height
	implicitWidth: label.x + label.width

	Image {
		id: icon

		width: Theme.geometry.generatorIconLabel.icon.width
		height: Theme.geometry.generatorIconLabel.icon.width
		source: !!root.generator
			? root.generator.state !== VenusOS.Generators_State_Running ? ""
				: root.generator.runningBy === VenusOS.Generators_RunningBy_Manual
					? root.generator.runtime > 0
						? "qrc:/images/icon_manualstart_timer_24.svg"
						: "qrc:/images/icon_manualstart_24.svg"
				: "qrc:/images/icon_autostart_24.svg"
			: ""
	}

	Label {
		id: label

		anchors {
			left: icon.right
			leftMargin: Theme.geometry.generatorIconLabel.spacing
		}
		// set a fixed width to prevent the label from resizing when the runtime changes
		width: Theme.geometry.generatorIconLabel.label.width
		text: root.generator ? Utils.formatAsHHMMSS(root.generator.runtime) : ""
		font.pixelSize: Theme.font.size.body2
		color: root.generator && root.generator.runtime > 0 ? Theme.color.font.primary : Theme.color.font.secondary
	}
}

/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Controls as C
import QtQuick.Controls.impl as CP
import Victron.VenusOS
import "/components/Utils.js" as Utils

CP.IconLabel {
	id: root

	property int state
	property int runtime
	property int runningBy

	spacing: Theme.geometry.generatorIconLabel.spacing
	display: C.AbstractButton.TextBesideIcon

	icon.width: Theme.geometry.generatorIconLabel.icon.width
	icon.height: Theme.geometry.generatorIconLabel.icon.width
	icon.source: root.state !== Generators.GeneratorState.Running ? ""
			: root.runningBy === Generators.GeneratorRunningBy.Manual
				? root.runtime > 0
					? "qrc:/images/icon_manualstart_timer_24.svg"
					: "qrc:/images/icon_manualstart_24.svg"
			: "qrc:/images/icon_autostart_24.svg"
	text: Utils.formatAsHHMM(root.runtime)
	font.family: VenusFont.normal.name
	font.pixelSize: Theme.font.size.m
	color: root.runtime > 0 ? Theme.color.font.primary : Theme.color.font.tertiary
}

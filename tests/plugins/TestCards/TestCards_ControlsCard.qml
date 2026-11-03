/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.GuiPlugins

PluginCard {
	title: "Controls"

	PluginListSwitch {
		objectName: "firstSwitch"
		flat: true
		text: "First"
		writeAccessLevel: PluginAccessLevel.User
	}

	PluginListSwitch {
		objectName: "lastSwitch"
		flat: true
		text: "Last"
		writeAccessLevel: PluginAccessLevel.User
	}
}

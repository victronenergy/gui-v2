/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.GuiPlugins

// Taller than the screen, so that the pane must scroll to show each switch.
PluginCard {
	title: "Tall controls"

	PluginListSwitch {
		objectName: "firstSwitch"
		flat: true
		text: "First"
		writeAccessLevel: PluginAccessLevel.User
	}

	Item {
		width: 1
		height: 600
	}

	PluginListSwitch {
		objectName: "middleSwitch"
		flat: true
		text: "Middle"
		writeAccessLevel: PluginAccessLevel.User
	}

	Item {
		width: 1
		height: 600
	}

	PluginListSwitch {
		objectName: "lastSwitch"
		flat: true
		text: "Last"
		writeAccessLevel: PluginAccessLevel.User
	}
}

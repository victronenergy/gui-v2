/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.GuiPlugins

// Counts while loaded. The navigation page loads this file only once the page
// is current. The root must be a PluginPage, or that load removes the page.
PluginPage {
	id: root

	property int ticks: 0

	Timer {
		interval: 200
		repeat: true
		running: true
		onTriggered: root.ticks++
	}
}

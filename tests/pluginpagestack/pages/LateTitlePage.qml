/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.GuiPlugins

PluginPage {
	objectName: "lateTitlePage"
	property bool arrived: false
	title: arrived ? "Late title" : ""

	Component.onCompleted: PluginPageTestTracker.born()
	Component.onDestruction: PluginPageTestTracker.died()
}

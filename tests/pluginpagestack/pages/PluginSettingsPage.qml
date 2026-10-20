/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.GuiPlugins

PluginPage {
	objectName: "pluginSettingsPage"
	title: "Cell Voltages"

	Component.onCompleted: PluginPageTestTracker.born()
	Component.onDestruction: PluginPageTestTracker.died()
}

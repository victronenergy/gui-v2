/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	objectName: "venusPage"
	title: "Built-in"

	Component.onCompleted: PluginPageTestTracker.born()
	Component.onDestruction: PluginPageTestTracker.died()
}

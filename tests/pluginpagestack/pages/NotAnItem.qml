/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick

QtObject {
	objectName: "notAnItem"

	Component.onCompleted: PluginPageTestTracker.born()
	Component.onDestruction: PluginPageTestTracker.died()
}

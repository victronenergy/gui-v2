/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	readonly property int demoMode: dbusConnected && Global.systemSettings.demoMode.value === undefined && !forceValidDemoMode
			? VenusOS.SystemSettings_DemoModeUnknown
			: Global.systemSettings.demoMode.value === 1 || !dbusConnected
			  ? VenusOS.SystemSettings_DemoModeActive
			  : VenusOS.SystemSettings_DemoModeInactive

	property bool forceValidDemoMode
}

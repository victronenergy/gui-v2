/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

DataPoint {
	id: root

	readonly property int demoMode: dbusConnected && value === undefined && !forceValidDemoMode
			? VenusOS.SystemSettings_DemoModeUnknown
			: value === 1 || !dbusConnected
			  ? VenusOS.SystemSettings_DemoModeActive
			  : VenusOS.SystemSettings_DemoModeInactive

	property bool forceValidDemoMode

	source: "com.victronenergy.settings/Settings/Gui/DemoMode"
	sourceType: dbusConnected
				? VenusOS.DataPoint_DBusSource
				: VenusOS.DataPoint_MockSource

	property Connections sysSettingsConn: Connections {
		target: Global.systemSettings || null

		function onSetDemoModeRequested(demoMode) {
			if (root.sourceObject) {
				root.sourceObject.setValue(demoMode)
			} else {
				console.warn("Demo mode cannot be deactivated, no backend source available")
			}
		}
	}

	property Connections globalConn: Connections {
		target: Global
		function onSystemSettingsChanged() { root._updateSystemSettings() }
	}

	function _updateSystemSettings() {
		if (Global.systemSettings != null) {
			Global.systemSettings.demoMode = demoMode
		}
	}

	onDemoModeChanged: _updateSystemSettings()
}

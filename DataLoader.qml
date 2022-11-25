/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "/components/Utils.js" as Utils
import "data" as Data
import "demo" as Demo

QtObject {
	id: root

	property Data.DataManager dataManager: Data.DataManager { }

	property Loader demoManagerLoader: Loader {
		active: false
		sourceComponent: Demo.DemoManager {}
		onStatusChanged: {
			if (status === Loader.Ready) {
				if (Global.demoManager != null) {
					console.warn("Global.demoManager is already set, overwriting")
				}
				Global.demoManager = item
			} else if (status === Loader.Error) {
				console.warn("Unable to load DemoManager:", errorString())
			}
		}
	}

	property DemoModeDataPoint demoModeDataPoint: DemoModeDataPoint {
		forceValidDemoMode: true
		property bool backendReady: Global.backendConnectionReady // TODO: also handle the Failed case and transition to DemoMode.
		onBackendReadyChanged: _initializeDataSourceType()
		onDemoModeChanged: _initializeDataSourceType()
		Component.onCompleted: _initializeDataSourceType()
		function _initializeDataSourceType() {
			if (demoMode === VenusOS.SystemSettings_DemoModeActive) {
				// Ensure Global.demoManager is set before initializing the DataManager.
				console.warn("Demo mode is active, setting mock data source")
				root.demoManagerLoader.active = true
				root.dataManager.dataSourceType = VenusOS.DataPoint_MockSource
			} else if (demoMode === VenusOS.SystemSettings_DemoModeInactive) {
				if (BackendConnection.type === VenusOS.DataPoint_DBusSource && Global.backendConnectionReady) {
					console.warn("Demo mode is inactive, setting DBus data source type")
					root.demoManagerLoader.active = false
					root.dataManager.dataSourceType = VenusOS.DataPoint_DBusSource
					Global.dataManager = root.dataManager
				} else if (BackendConnection.type === VenusOS.DataPoint_MqttSource && Global.backendConnectionReady) {
					console.warn("Demo mode is inactive, setting MQTT data source type")
					root.demoManagerLoader.active = false
					root.dataManager.dataSourceType = VenusOS.DataPoint_MqttSource
					Global.dataManager = root.dataManager
				}
			}
		}
	}
}

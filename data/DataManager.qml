/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

import "mock" as MockData

Item {
	id: root

	property int dataSourceType: BackendConnection.UnknownSource

	property bool _ready: !!Global.acInputs
			&& !!Global.battery
			&& !!Global.dcInputs
			&& !!Global.environmentInputs
			&& !!Global.ess
			&& !!Global.generators
			&& !!Global.inverters
			&& !!Global.notifications
			&& !!Global.relays
			&& !!Global.solarChargers
			&& !!Global.system
			&& !!Global.systemSettings
			&& !!Global.tanks
	readonly property bool _shouldInitialize: _ready && dataSourceType != BackendConnection.UnknownSource
			&& (dataSourceType != BackendConnection.MqttSource || Global.backendConnectionReady)

	function _setBackendSource() {
		if (!_shouldInitialize) {
			return
		}
		if (dataSourceType == BackendConnection.DBusSource && Global.backendConnectionReady) {
			console.warn("Loading D-Bus data backend...")
			demoDataLoader.active = false
			_resetData()
			dbusDataLoader.active = true
		} else if (dataSourceType == BackendConnection.MqttSource && Global.backendConnectionReady) {
			console.warn("Loading MQTT data backend...")
			demoDataLoader.active = false
			_resetData()
			mqttDataLoader.active = true
		} else if (dataSourceType == BackendConnection.MockSource) {
			console.warn("Loading mock data backend...")
			dbusDataLoader.active = false
			_resetData()
			demoDataLoader.active = true
		}
	}

	function _resetData() {
		Global.acInputs.reset()
		Global.battery.reset()
		Global.dcInputs.reset()
		Global.environmentInputs.reset()
		Global.ess.reset()
		Global.generators.reset()
		Global.inverters.reset()
		Global.notifications.reset()
		Global.relays.reset()
		Global.solarChargers.reset()
		Global.system.reset()
		Global.systemSettings.reset()
		Global.tanks.reset()
	}

	on_ShouldInitializeChanged: _setBackendSource()
	onDataSourceTypeChanged: _setBackendSource()

	// Global data types
	AcInputs {}
	Battery {}
	DcInputs {}
	EnvironmentInputs {}
	Ess {}
	Generators {}
	Inverters {}
	Notifications {}
	Relays {}
	SolarChargers {}
	System {}
	SystemSettings {}
	Tanks {}

	Loader {
		id: dbusDataLoader

		active: false
		source: active ? "qrc:/data/dbus/DBusDataManager.qml" : ""

		onStatusChanged: if (status === Loader.Error) console.warn("Unable to load dbus data manager:", errorString())
		onLoaded: Global.dataBackendLoaded = true
	}

	Loader {
		id: mqttDataLoader

		active: false
		source: active ? "qrc:/data/mqtt/MqttDataManager.qml" : ""

		onStatusChanged: if (status === Loader.Error) console.warn("Unable to load mqtt data manager:", errorString())
		onLoaded: Global.dataBackendLoaded = true
	}

	Loader {
		id: demoDataLoader

		active: false
		sourceComponent: MockData.MockDataManager {}

		onStatusChanged: if (status === Loader.Error) console.warn("Unable to load mock data manager:", errorString())
		onLoaded: Global.dataBackendLoaded = true
	}
}

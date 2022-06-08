/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

import "mock" as MockData

Item {
	id: root

	property int dataSourceType: VenusOS.DataPoint_UnknownSource

	property bool _ready
	readonly property bool _shouldInitialize: _ready && dataSourceType != VenusOS.DataPoint_UnknownSource

	function _setBackendSource() {
		if (!_shouldInitialize) {
			return
		}
		if (dataSourceType == VenusOS.DataPoint_DBusSource && dbusConnected) {
			console.warn("Loading D-Bus data backend...")
			demoDataLoader.active = false
			_resetData()
			dbusDataLoader.active = true
		} else {
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

	Component.onCompleted: {
		// Delay the call to ensure all Global data property types (Global.tanks, Global.acInputs
		// etc.) have been set, as they are required by the impl types.
		Qt.callLater(function() { root._ready = true })
	}

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

		onLoaded: Global.dataBackendLoaded = true
	}

	Loader {
		id: demoDataLoader

		active: false
		sourceComponent: MockData.MockDataManager {}

		onLoaded: Global.dataBackendLoaded = true
	}
}

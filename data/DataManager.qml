/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Dbus
import Victron.Mqtt
import Victron.Mock

Item {
	id: root

	readonly property bool _dataObjectsReady: !!Global.acInputs
			&& !!Global.dcInputs
			&& !!Global.environmentInputs
			&& !!Global.ess
			&& !!Global.evChargers
			&& !!Global.generators
			&& !!Global.inverterChargers
			&& !!Global.notifications
			&& !!Global.pvInverters
			&& !!Global.solarDevices
			&& !!Global.system
			&& !!Global.systemSettings
			&& !!Global.switches
			&& !!Global.tanks
			&& !!Global.venusPlatform

	readonly property bool _shouldInitialize: _dataObjectsReady
			&& BackendConnection.type !== BackendConnection.UnknownSource
			&& Global.backendReady

	function _setBackendSource() {
		if (!_shouldInitialize) {
			console.warn("DataManager: not setting backend source: not ready to initialize")
			return
		}
		if (dataManagerLoader.active) {
			console.warn("DataManager: source is already set to: ", dataManagerLoader.source,
				" cannot be changed after initialization")
			return
		}
		switch (BackendConnection.type) {
		case BackendConnection.DBusSource:
			console.warn("DataManager: loading D-Bus data backend...")
			dataManagerLoader.sourceComponent = dbus
			break
		case BackendConnection.MqttSource:
			console.warn("DataManager: loading MQTT data backend...")
			dataManagerLoader.sourceComponent = mqtt
			break
		case BackendConnection.MockSource:
			console.warn("DataManager: loading mock data backend...")
			dataManagerLoader.sourceComponent = mock
			break
		default:
			console.warn("DataManager: unsupported data backend: ", BackendConnection.type)
			return
		}
		dataManagerLoader.active = true
	}

	Component {
		id: dbus

		DBusDataManager {}
	}

	Component {
		id: mqtt

		MqttDataManager {}
	}

	Component {
		id: mock

		MockDataManager {}
	}

	on_DataObjectsReadyChanged: if (_dataObjectsReady) console.info("DataManager: data objects ready")
	on_ShouldInitializeChanged: _setBackendSource()

	Connections {
		target: BackendConnection

		function onTypeChanged() {
			_setBackendSource()
		}
	}

	// Global data types
	AcInputs {}
	DcInputs {}
	EnvironmentInputs {}
	Ess {}
	EvChargers {}
	Generators {}
	InverterChargers {}
	Notifications {}
	PvInverters {}
	SolarDevices {}
	Switches {}
	System {}
	SystemSettings {}
	Tanks {}
	VenusPlatform {}

	AllDevicesModel {
		id: allDevicesModel
		Component.onCompleted: { console.info("DataManager: all devices model ready"); Global.allDevicesModel = allDevicesModel }
	}

	Loader {
		id: dataManagerLoader

		active: false
		asynchronous: true
		onStatusChanged: if (status === Loader.Error) console.warn("DataManager: unable to load backend: ", source)
		onLoaded: Qt.callLater(function() { console.info("DataManager: backend finished loading!"); Global.dataManagerLoaded = true })
	}
}

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
			&& !!Global.acInputs
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
			return
		}
		if (dataManagerLoader.active) {
			console.warn("Data manager source is already set to", dataManagerLoader.source,
				"cannot be changed after initialization")
			return
		}
		switch (BackendConnection.type) {
		case BackendConnection.DBusSource:
			console.warn("Loading D-Bus data backend...")
			dataManagerLoader.sourceComponent = dbus
			break
		case BackendConnection.MqttSource:
			console.warn("Loading MQTT data backend...")
			dataManagerLoader.sourceComponent = mqtt
			break
		case BackendConnection.MockSource:
			console.warn("Loading mock data backend...")
			dataManagerLoader.sourceComponent = mock
			break
		default:
			console.warn("Unsupported data backend!", BackendConnection.type)
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
		Component.onCompleted: Global.allDevicesModel = allDevicesModel
	}

	Loader {
		id: dataManagerLoader

		active: false
		asynchronous: true
		onStatusChanged: if (status === Loader.Error) console.warn("Unable to load data manager:", source)
		onLoaded: Qt.callLater(function() { Global.dataManagerLoaded = true })
	}
}

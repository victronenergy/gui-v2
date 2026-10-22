/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

pragma Singleton

import QtQuick
import Victron.VenusOS

Item {
	id: root

	// These object properties provide an interface to the VenusOS backend service data. Note these
	// objects are loaded asynchronously, and are not valid until Services.appDataReady = true. Any
	// code loaded by ApplicationContent and its children do not need to worry about this, because
	// Main.qml loads ApplicationContent conditionally on Services.appDataReady, but code loaded
	// elsewhere (e.g. Main.qml, Global.qml) must check appDataReady before accessing these objects.
	readonly property AcInputs acInputs: acInputsLoader.item
	readonly property DcInputs dcInputs: dcInputsLoader.item
	readonly property EnvironmentInputs environment: environmentLoader.item
	readonly property EvChargers evChargers: evchargerLoader.item
	readonly property Generators generators: generatorsLoader.item
	readonly property InverterChargers inverterChargers: inverterChargersLoader.item
	readonly property IOChannels ioChannels: ioChannelsLoader.item
	readonly property Notifications notifications: notificationsLoader.item
	readonly property SolarInputs solar: solarLoader.item
	readonly property System system: systemLoader.item
	readonly property SystemSettings settings: settingsLoader.item
	readonly property Tanks tanks: tanksLoader.item
	readonly property VenusPlatform platform: platformLoader.item

	readonly property bool appDataReady: Global.backendReady
			&& _servicesLoaded
			&& (BackendConnection.type !== BackendConnection.MockSource || mockSetupLoader.mockLoaded)
			&& !GuiPluginLoader.busy
			&& !!RuntimeDeviceModel // ensure singleton is created

	readonly property bool _servicesLoaded: settingsLoader.status === Loader.Ready
			&& systemLoader.status === Loader.Ready
			&& acInputsLoader.status === Loader.Ready
			&& dcInputsLoader.status === Loader.Ready
			&& environmentLoader.status === Loader.Ready
			&& evchargerLoader.status === Loader.Ready
			&& generatorsLoader.status === Loader.Ready
			&& inverterChargersLoader.status === Loader.Ready
			&& ioChannelsLoader.status === Loader.Ready
			&& notificationsLoader.status === Loader.Ready
			&& solarLoader.status === Loader.Ready
			&& tanksLoader.status === Loader.Ready
			&& platformLoader.status === Loader.Ready

	function _checkLoaderStatus(status, name) {
		if (status === Loader.Error) {
			console.warn("Failed to load '%1' service data!".arg(name))
		}
	}

	onAppDataReadyChanged: {
		if (appDataReady) {
			console.info("Services: app data loading complete")
		} else {
			console.warn("Services: app data not ready!")
		}
	}

	Loader {
		id: settingsLoader
		active: BackendConnection.type !== BackendConnection.UnknownSource
		asynchronous: true
		sourceComponent: SystemSettings {}
		onStatusChanged: root._checkLoaderStatus(status, "settings")
	}
	Loader {
		id: systemLoader
		active: BackendConnection.type !== BackendConnection.UnknownSource
				&& settingsLoader.status === Loader.Ready
		asynchronous: true
		sourceComponent: System { settingsServiceUid: settingsLoader.item.serviceUid }
		onStatusChanged: root._checkLoaderStatus(status, "system")
	}
	Loader {
		id: acInputsLoader
		asynchronous: true
		active: BackendConnection.type !== BackendConnection.UnknownSource
				&& systemLoader.status === Loader.Ready
				&& settingsLoader.status === Loader.Ready
		sourceComponent: AcInputs {
			systemServiceUid: systemLoader.item.serviceUid
			settingsServiceUid: settingsLoader.item.serviceUid
		}
		onStatusChanged: root._checkLoaderStatus(status, "acInputs")
	}
	Loader {
		id: dcInputsLoader
		active: BackendConnection.type !== BackendConnection.UnknownSource
				&& settingsLoader.status === Loader.Ready
		asynchronous: true
		sourceComponent: DcInputs { settingsServiceUid: settingsLoader.item.serviceUid }
		onStatusChanged: root._checkLoaderStatus(status, "dcInputs")
	}
	Loader {
		id: environmentLoader
		active: BackendConnection.type !== BackendConnection.UnknownSource
		asynchronous: true
		sourceComponent: EnvironmentInputs {}
		onStatusChanged: root._checkLoaderStatus(status, "environment")
	}
	Loader {
		id: evchargerLoader
		active: BackendConnection.type !== BackendConnection.UnknownSource
		asynchronous: true
		sourceComponent: EvChargers {}
		onStatusChanged: root._checkLoaderStatus(status, "evcharger")
	}
	Loader {
		id: generatorsLoader
		active: BackendConnection.type !== BackendConnection.UnknownSource
		asynchronous: true
		sourceComponent: Generators {}
		onStatusChanged: root._checkLoaderStatus(status, "generators")
	}
	Loader {
		id: inverterChargersLoader
		active: BackendConnection.type !== BackendConnection.UnknownSource
		asynchronous: true
		sourceComponent: InverterChargers {}
		onStatusChanged: root._checkLoaderStatus(status, "inverterChargers")
	}
	Loader {
		id: ioChannelsLoader
		active: BackendConnection.type !== BackendConnection.UnknownSource
		asynchronous: true
		sourceComponent: IOChannels {}
		onStatusChanged: root._checkLoaderStatus(status, "ioChannels")
	}
	Loader {
		id: notificationsLoader
		active: BackendConnection.type !== BackendConnection.UnknownSource
		asynchronous: true
		sourceComponent: Notifications {}
		onStatusChanged: root._checkLoaderStatus(status, "notifications")
	}
	Loader {
		id: solarLoader
		active: BackendConnection.type !== BackendConnection.UnknownSource
		asynchronous: true
		sourceComponent: SolarInputs {}
		onStatusChanged: root._checkLoaderStatus(status, "solar")
	}
	Loader {
		id: tanksLoader
		active: BackendConnection.type !== BackendConnection.UnknownSource
		asynchronous: true
		sourceComponent: Tanks {}
		onStatusChanged: root._checkLoaderStatus(status, "tanks")
	}
	Loader {
		id: platformLoader
		active: BackendConnection.type !== BackendConnection.UnknownSource
		asynchronous: true
		sourceComponent: VenusPlatform {}
		onStatusChanged: root._checkLoaderStatus(status, "platform")
	}

	Loader {
		property bool mockLoaded

		id: mockSetupLoader
		active: BackendConnection.type === BackendConnection.MockSource && root._servicesLoaded
		asynchronous: true

		// Load by url to avoid importing Victron.Mock module for non-mock backends.
		// Note this means filesystem deployments on GX will not load a user-edited MockSetup.qml.
		source: "qrc:/qt/qml/Victron/Mock/data/mock/MockSetup.qml"
		onStatusChanged: {
			if (status === Loader.Ready) {
				console.info("Services: mock setup loaded!")
				mockLoaded = true
			} else if (status === Loader.Error) {
				console.warn("Services: Unable to load mock setup")
			}
		}
	}
}

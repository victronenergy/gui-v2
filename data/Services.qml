/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

pragma Singleton

import QtQuick
import Victron.VenusOS
import Victron.Mock

Item {
	id: root

	readonly property alias acInputs: acInputs
	readonly property alias dcInputs: dcInputs
	readonly property alias temperature: temperature
	readonly property alias evcs: evcs
	readonly property alias generators: generators
	readonly property alias inverterChargers: inverterChargers
	readonly property alias notifications: notifications
	readonly property alias solarInputs: solarInputs
	readonly property alias switches: switches
	readonly property alias system: system
	readonly property alias settings: settings
	readonly property alias tanks: tanks
	readonly property alias platform: platform

	readonly property bool ready: Global.backendReady
			&& (BackendConnection.type !== BackendConnection.MockSource || mockSetupLoader.mockLoaded)
			&& !GuiPluginLoader.busy

	onReadyChanged: {
		if (ready) {
			console.info("Services: loading complete")
		} else {
			console.info("Services: not ready!")
		}
	}

	// Global data types
	AcInputs {
		id: acInputs
		systemServiceUid: system.serviceUid
		settingsServiceUid: settings.serviceUid
	}
	DcInputs {
		id: dcInputs
		settingsServiceUid: settings.serviceUid
	}
	EnvironmentInputs { id: temperature }
	EvChargers { id: evcs }
	Generators { id: generators }
	InverterChargers { id: inverterChargers }
	Notifications { id: notifications }
	SolarInputs { id: solarInputs }
	Switches { id: switches }
	System {
		id: system
		settingsServiceUid: settings.serviceUid
	}
	SystemSettings {
		id: settings
		platformServiceUid: platform.serviceUid
	}
	Tanks { id: tanks }
	VenusPlatform {
		id: platform
	}

	Loader {
		id: mockSetupLoader
		active: BackendConnection.type === BackendConnection.MockSource
		asynchronous: true
		sourceComponent: MockSetup {}
		property bool mockLoaded
		onLoaded: { console.info("Services: mock setup loaded!"); mockLoaded = true }
		onStatusChanged: {
			if (status === Loader.Error) {
				console.warn("Services: Unable to load mock setup")
			}
		}
	}
}

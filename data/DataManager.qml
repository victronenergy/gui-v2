/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Mock

Item {
	id: root

	readonly property bool _dataObjectsReady: !!Global.acInputs
			&& !!Global.dcInputs
			&& !!Global.environmentInputs
			&& !!Global.evChargers
			&& !!Global.generators
			&& !!Global.inverterChargers
			&& !!Global.notifications
			&& !!Global.solarInputs
			&& !!Global.system
			&& !!Global.systemSettings
			&& !!Global.switches
			&& !!Global.tanks
			&& !!Global.venusPlatform

	readonly property bool _ready: _dataObjectsReady
			&& Global.backendReady
			&& dataServiceModel.rowCount > 0
			&& (!mockSetupLoader.active || mockSetupLoader.status === Loader.Ready)


	on_DataObjectsReadyChanged: if (_dataObjectsReady) console.info("DataManager: data objects ready")
	on_ReadyChanged: {
		if (_ready) {
			console.info("DataManager: loading complete")
			Global.dataManagerLoaded = true
		}
	}

	// Global data types
	AcInputs {}
	DcInputs {}
	EnvironmentInputs {}
	EvChargers {}
	Generators {}
	InverterChargers {}
	Notifications {}
	SolarInputs {}
	Switches {}
	System {}
	SystemSettings {}
	Tanks {}
	VenusPlatform {}

	AllDevicesModel {
		id: allDevicesModel
		Component.onCompleted: { console.info("DataManager: all devices model ready"); Global.allDevicesModel = allDevicesModel }
	}

	VeQItemTableModel {
		id: dataServiceModel
		uids: [ BackendConnection.uidPrefix() ]
		flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
		Component.onCompleted: Global.dataServiceModel = dataServiceModel
	}

	Loader {
		id: mockSetupLoader
		active: root._dataObjectsReady && BackendConnection.type === BackendConnection.MockSource
		asynchronous: true
		sourceComponent: MockSetup {}
		onLoaded: console.info("DataManager: mock setup loaded!")
		onStatusChanged: {
			if (status === Loader.Error) {
				console.warn("DataManager: Unable to load mock setup:", errorString())
			}
		}
	}
}

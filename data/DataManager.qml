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
			&& !!Global.acInputs
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
			&& (!mockManagerLoader.active || mockManagerLoader.status === Loader.Ready)

	on_ReadyChanged: {
		if (_ready) {
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
		Component.onCompleted: Global.allDevicesModel = allDevicesModel
	}

	VeQItemTableModel {
		id: dataServiceModel
		uids: [ BackendConnection.uidPrefix() ]
		flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
		Component.onCompleted: Global.dataServiceModel = dataServiceModel
	}

	Loader {
		id: mockManagerLoader
		active: root._dataObjectsReady && BackendConnection.type === BackendConnection.MockSource
		asynchronous: true
		sourceComponent: MockDataManager {}
		onStatusChanged: if (status === Loader.Error) console.warn("Unable to load mock data manager:", errorString())
	}
}

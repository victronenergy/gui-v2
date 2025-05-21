/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

AggregateDeviceModel {
	id: aggregateModel

	retainDevices: true
	sourceModels: [
		batteryDevices,
		Global.dcInputs.model,
		combinedDcLoadDevices,
		digitalInputDevices,
		Global.environmentInputs.model,
		Global.evChargers.model,
		Global.inverterChargers.veBusDevices,
		Global.inverterChargers.acSystemDevices,
		Global.inverterChargers.inverterDevices,
		Global.inverterChargers.chargerDevices,
		gpsDevices,
		meteoDevices,
		motorDriveDevices,
		pulseMeterDevices,
		solarChargerDevices,
		switchDevices,
		Global.pvInverters.model,
		unsupportedDevices,

		// AC input models
		gridDevices,
		gensetDevices,
		acLoadDevices,
		heatPumpInputDevices,
		heatPumpOutputDevices,

	].concat(Global.tanks.allTankModels)

	readonly property ServiceDeviceModel acLoadDevices: ServiceDeviceModel {
		serviceType: "acload"
		modelId: "acload"
	}

	readonly property ServiceDeviceModel batteryDevices: ServiceDeviceModel {
		serviceType: "battery"
		modelId: "battery"
	}

	readonly property MultiServiceDeviceModel combinedDcLoadDevices: MultiServiceDeviceModel {
		serviceTypes: ["dcload", "dcsystem", "dcdc"]
		modelId: "combinedDcloads"
	}

	readonly property ServiceDeviceModel digitalInputDevices: ServiceDeviceModel {
		serviceType: "digitalinput"
		modelId: "digitalinput"
	}

	readonly property ServiceDeviceModel gpsDevices: ServiceDeviceModel {
		serviceType: "gps"
		modelId: "gps"
	}

	readonly property ServiceDeviceModel gridDevices: ServiceDeviceModel {
		serviceType: "grid"
		modelId: "grid"
	}

	readonly property ServiceDeviceModel gensetDevices: ServiceDeviceModel {
		serviceType: "genset"
		modelId: "genset"
	}

	readonly property ServiceDeviceModel heatPumpInputDevices: HeatPumpModel {
		position: VenusOS.AcPosition_AcInput
	}

	readonly property ServiceDeviceModel heatPumpOutputDevices: HeatPumpModel {
		position: VenusOS.AcPosition_AcOutput
	}

	readonly property ServiceDeviceModel meteoDevices: ServiceDeviceModel {
		serviceType: "meteo"
		modelId: "meteo"
	}

	readonly property ServiceDeviceModel motorDriveDevices: ServiceDeviceModel {
		serviceType: "motordrive"
		modelId: "motordrive"
	}

	readonly property ServiceDeviceModel pulseMeterDevices: ServiceDeviceModel {
		serviceType: "pulsemeter"
		modelId: "pulsemeter"
	}

	readonly property ServiceDeviceModel solarChargerDevices: ServiceDeviceModel {
		serviceType: "solarcharger"
		modelId: "solarcharger"
	}

	readonly property ServiceDeviceModel switchDevices: ServiceDeviceModel {
		serviceType: "switch"
		modelId: "switch"
	}

	readonly property ServiceDeviceModel unsupportedDevices: ServiceDeviceModel {
		serviceType: "unsupported"
		modelId: "unsupported"
	}
}

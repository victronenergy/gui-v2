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
		Global.solarInputs.pvInverterDevices,
		unsupportedDevices,

		// AC input models
		gridDevices,
		gensetDevices,
		acLoadDevices,
		heatPumpInputDevices,
		heatPumpOutputDevices,

	].concat(Global.tanks.allTankModels)

	readonly property ServiceDeviceModel acLoadDevices: ServiceDeviceModel {
		serviceTypes: ["acload"]
		modelId: "acload"
	}

	readonly property ServiceDeviceModel batteryDevices: ServiceDeviceModel {
		serviceTypes: ["battery"]
		modelId: "battery"
	}

	readonly property ServiceDeviceModel combinedDcLoadDevices: ServiceDeviceModel {
		serviceTypes: ["dcload", "dcsystem", "dcdc"]
		modelId: "combinedDcloads"
	}

	readonly property ServiceDeviceModel digitalInputDevices: ServiceDeviceModel {
		serviceTypes: ["digitalinput"]
		modelId: "digitalinput"
	}

	readonly property ServiceDeviceModel gpsDevices: ServiceDeviceModel {
		serviceTypes: ["gps"]
		modelId: "gps"
	}

	readonly property ServiceDeviceModel gridDevices: ServiceDeviceModel {
		serviceTypes: ["grid"]
		modelId: "grid"
	}

	readonly property ServiceDeviceModel gensetDevices: ServiceDeviceModel {
		serviceTypes: ["genset"]
		modelId: "genset"
	}

	readonly property ServiceDeviceModel heatPumpInputDevices: HeatPumpModel {
		position: VenusOS.AcPosition_AcInput
	}

	readonly property ServiceDeviceModel heatPumpOutputDevices: HeatPumpModel {
		position: VenusOS.AcPosition_AcOutput
	}

	readonly property ServiceDeviceModel meteoDevices: ServiceDeviceModel {
		serviceTypes: ["meteo"]
		modelId: "meteo"
	}

	readonly property ServiceDeviceModel motorDriveDevices: ServiceDeviceModel {
		serviceTypes: ["motordrive"]
		modelId: "motordrive"
	}

	readonly property ServiceDeviceModel pulseMeterDevices: ServiceDeviceModel {
		serviceTypes: ["pulsemeter"]
		modelId: "pulsemeter"
	}

	readonly property ServiceDeviceModel solarChargerDevices: ServiceDeviceModel {
		serviceTypes: ["solarcharger"]
		modelId: "solarcharger"
	}

	readonly property ServiceDeviceModel switchDevices: ServiceDeviceModel {
		serviceTypes: ["switch"]
		modelId: "switch"
	}

	readonly property ServiceDeviceModel unsupportedDevices: ServiceDeviceModel {
		serviceTypes: ["unsupported"]
		modelId: "unsupported"
	}
}

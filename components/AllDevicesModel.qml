/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

AggregateDeviceModel {
	id: aggregateModel

	sourceModels: [
		batteryModel,
		Global.dcInputs.model,
		Global.dcLoads.model,
		Global.digitalInputs.model,
		Global.environmentInputs.model,
		Global.evChargers.model,
		Global.inverterChargers.veBusDevices,
		Global.inverterChargers.acSystemDevices,
		Global.inverterChargers.inverterDevices,
		Global.inverterChargers.chargerDevices,
		meteoDeviceModel,
		motorDriveDeviceModel,
		pulseMeterDeviceModel,
		Global.pvInverters.model,
		Global.solarChargers.model,
		unsupportedDeviceModel,

		// AC input models
		gridDeviceModel,
		gensetDeviceModel,
		acLoadDeviceModel,
		heatPumpDeviceModel

	].concat(Global.tanks.allTankModels)

	readonly property ServiceDeviceModel batteryModel: ServiceDeviceModel {
		serviceType: "battery"
		modelId: "battery"
	}

	readonly property ServiceDeviceModel gridDeviceModel: ServiceDeviceModel {
		serviceType: "grid"
		modelId: "grid"
	}

	readonly property ServiceDeviceModel gensetDeviceModel: ServiceDeviceModel {
		serviceType: "genset"
		modelId: "genset"
	}

	readonly property ServiceDeviceModel acLoadDeviceModel: ServiceDeviceModel {
		serviceType: "acload"
		modelId: "acload"
	}

	readonly property ServiceDeviceModel heatPumpDeviceModel: ServiceDeviceModel {
		serviceType: "heatpump"
		modelId: "heatpump"
	}

	readonly property ServiceDeviceModel meteoDeviceModel: ServiceDeviceModel {
		serviceType: "meteo"
		modelId: "meteo"
	}

	readonly property ServiceDeviceModel motorDriveDeviceModel: ServiceDeviceModel {
		serviceType: "motordrive"
		modelId: "motordrive"
	}

	readonly property ServiceDeviceModel pulseMeterDeviceModel: ServiceDeviceModel {
		serviceType: "pulsemeter"
		modelId: "pulsemeter"
	}

	readonly property ServiceDeviceModel unsupportedDeviceModel: ServiceDeviceModel {
		serviceType: "unsupported"
		modelId: "unsupported"
	}
}

/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

AggregateDeviceModel {
	id: aggregateModel

	sourceModels: [
		Global.acSystemDevices.model,
		Global.batteries.model,
		Global.chargers.model,
		Global.dcInputs.model,
		Global.dcLoads.model,
		Global.digitalInputs.model,
		Global.environmentInputs.model,
		Global.evChargers.model,
		Global.inverterChargers.veBusDevices,
		Global.inverterChargers.inverterDevices,
		meteoDeviceModel,
		motorDriveDeviceModel,
		Global.pulseMeters.model,
		Global.pvInverters.model,
		Global.solarChargers.model,
		Global.unsupportedDevices.model,

		// AC input models
		gridDeviceModel,
		gensetDeviceModel,
		acLoadDeviceModel,
		heatPumpDeviceModel

	].concat(Global.tanks.allTankModels)

	readonly property AcInDeviceModel gridDeviceModel: AcInDeviceModel {
		serviceType: "grid"
		modelId: "grid"
	}

	readonly property AcInDeviceModel gensetDeviceModel: AcInDeviceModel {
		serviceType: "genset"
		modelId: "genset"
	}

	readonly property AcInDeviceModel acLoadDeviceModel: AcInDeviceModel {
		serviceType: "acload"
		modelId: "acload"
	}

	readonly property AcInDeviceModel heatPumpDeviceModel: AcInDeviceModel {
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
}

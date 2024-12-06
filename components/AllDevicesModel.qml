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
		digitalInputModel,
		Global.environmentInputs.model,
		Global.evChargers.model,
		Global.inverterChargers.veBusDevices,
		Global.inverterChargers.acSystemDevices,
		Global.inverterChargers.inverterDevices,
		Global.inverterChargers.chargerDevices,
		meteoModel,
		motorDriveModel,
		pulseMeterModel,
		Global.pvInverters.model,
		Global.solarChargers.model,
		unsupportedModel,

		// AC input models
		gridModel,
		gensetModel,
		acLoadModel,
		heatPumpModel

	].concat(Global.tanks.allTankModels)

	readonly property ServiceDeviceModel batteryModel: ServiceDeviceModel {
		serviceType: "battery"
		modelId: "battery"
	}

	readonly property ServiceDeviceModel digitalInputModel: ServiceDeviceModel {
		serviceType: "digitalinput"
		modelId: "digitalinput"
	}

	readonly property ServiceDeviceModel gridModel: ServiceDeviceModel {
		serviceType: "grid"
		modelId: "grid"
	}

	readonly property ServiceDeviceModel gensetModel: ServiceDeviceModel {
		serviceType: "genset"
		modelId: "genset"
	}

	readonly property ServiceDeviceModel acLoadModel: ServiceDeviceModel {
		serviceType: "acload"
		modelId: "acload"
	}

	readonly property ServiceDeviceModel heatPumpModel: ServiceDeviceModel {
		serviceType: "heatpump"
		modelId: "heatpump"
	}

	readonly property ServiceDeviceModel meteoModel: ServiceDeviceModel {
		serviceType: "meteo"
		modelId: "meteo"
	}

	readonly property ServiceDeviceModel motorDriveModel: ServiceDeviceModel {
		serviceType: "motordrive"
		modelId: "motordrive"
	}

	readonly property ServiceDeviceModel pulseMeterModel: ServiceDeviceModel {
		serviceType: "pulsemeter"
		modelId: "pulsemeter"
	}

	readonly property ServiceDeviceModel unsupportedModel: ServiceDeviceModel {
		serviceType: "unsupported"
		modelId: "unsupported"
	}
}

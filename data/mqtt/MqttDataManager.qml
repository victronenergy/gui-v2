/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Mqtt

QtObject {
	id: root

	property var chargers: ChargersImpl { }
	property var batteries: BatteriesImpl { }
	property var dcInputs: DcInputsImpl { }
	property var dcLoads: DcLoadsImpl { }
	property var dcSystems: DcSystemsImpl { }
	property var digitalInputs: DigitalInputsImpl {}
	property var environmentInputs: EnvironmentInputsImpl { }
	property var ess: EssImpl { }
	property var evChargers: EvChargersImpl { }
	property var generators: GeneratorsImpl { }
	property var inverterChargers: InverterChargersImpl {}
	property var meteoDevices: MeteoDevicesImpl { }
	property var motorDrives: MotorDrivesImpl { }
	property var multiRsDevices: MultiRsDevicesImpl { }
	property var notifications: NotificationsImpl {}
	property var pulseMeters: PulseMetersImpl { }
	property var pvInverters: PvInvertersImpl { }
	property var relays: RelaysImpl {}
	property var solarChargers: SolarChargersImpl { }
	property var system: SystemImpl { }
	property var systemSettings: SystemSettingsImpl { }
	property var tanks: TanksImpl { }
	property var unsupportedDevices: UnsupportedDevicesImpl { }
}

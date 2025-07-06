/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Mock

Item {
	// Key shortcuts for mock mode
	MockShortcuts {}

	// Mock service implementations that configure various settings, mimic some system operations
	// (in a limited manner) and animate data values to simulate a working system.
	BatteriesImpl {}
	DevicesImpl {}
	EvChargersImpl {}
	GeneratorsImpl {}
	InverterChargersImpl {}
	MiscServicesImpl {}
	MotorDrivesImpl {}
	NotificationsImpl {}
	SolarInputsImpl {}
	SystemAcImpl {}
	SystemDcImpl {}
	TanksImpl {}
	TemperaturesImpl {}
}

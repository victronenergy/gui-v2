/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Mqtt

QtObject {
	id: root

	property var dcInputs: DcInputsImpl { }
	property var evChargers: EvChargersImpl { }
	property var inverterChargers: InverterChargersImpl {}
	property var notifications: NotificationsImpl {}
	property var pvInverters: PvInvertersImpl { }
	property var systemSettings: SystemSettingsImpl { }
	property var tanks: TanksImpl { }
}

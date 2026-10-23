/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListQuantity {
	id: root

	dataItem.sourceUnit: Units.unitToVeUnit(VenusOS.Units_Temperature_Celsius)
	dataItem.displayUnit: Units.unitToVeUnit(Services.settings.temperatureUnit)
	unit: Services.settings.temperatureUnit
}

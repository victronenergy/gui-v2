/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Units

ListQuantityItem {
	id: root

	readonly property real temperature: Global.systemSettings.convertFromCelsius(dataItem.value)

	value: Units.getDisplayText(Global.systemSettings.temperatureUnit, temperature, 1).number
	unit: Global.systemSettings.temperatureUnit
	precision: 1
}

/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Units

ListQuantityItem {
	id: root

	readonly property real temperature: Units.convertFromCelsius(dataItem.value, Global.systemSettings.temperatureUnit.value)

	value: Units.getDisplayText(Global.systemSettings.temperatureUnit.value, temperature, 1).number
	unit: Global.systemSettings.temperatureUnit.value
	precision: 1
}

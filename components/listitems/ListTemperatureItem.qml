/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListQuantityItem {
	id: root

	value: Global.systemSettings.convertFromCelsius(dataItem.value)
	unit: Global.systemSettings.temperatureUnit
	precision: 1
}

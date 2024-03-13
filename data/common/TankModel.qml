/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

DeviceModel {
	property int type
	property real averageLevel
	property real totalCapacity
	property real totalRemaining

	onCountChanged: Global.tanks.updateTankModelTotals(type)
}

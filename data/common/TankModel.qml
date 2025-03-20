/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

BaseTankDeviceModel {
	objectName: modelId
	onCountChanged: Global.tanks.updateTankModelTotals(type)
}

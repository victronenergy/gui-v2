/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QuantityLabel {
	required property IOChannel ioChannel

	valueText: quantityInfo.number
	unit: Global.systemSettings.toPreferredUnit(ioChannel.unitType)
	unitText: quantityInfo.unit === VenusOS.Units_None ? ioChannel.unitText : quantityInfo.unit
	precision: ioChannel.decimals
	font.pixelSize: Theme.font_size_body2
	precisionAdjustmentAllowed: false // Always respect the decimals setting
}

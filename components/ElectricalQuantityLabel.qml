/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Units

QuantityLabel {
	id: root

	property var dataObject
	readonly property bool unitAmps: !!dataObject && !isNaN(dataObject.current) && Global.systemSettings.electricalQuantity.value === VenusOS.Units_Amp
	value: dataObject == null ? NaN // double equals to catch undefined and null
		: unitAmps ? dataObject.current
		: dataObject.power
	unit: unitAmps ? VenusOS.Units_Amp
		: VenusOS.Units_Watt
}

/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

QuantityLabel {
	id: root

	property var dataObject

	value: dataObject == null
			? NaN
			: Global.systemSettings.electricalQuantity.value === VenusOS.Units_Amp
				&& !isNaN(dataObject.current)
			  ? dataObject.current
			  : dataObject.power
	unit: Global.systemSettings.electricalQuantity.value === VenusOS.Units_Amp
			&& dataObject != null && !isNaN(dataObject.current)
		  ? VenusOS.Units_Amp
		  : VenusOS.Units_Watt
}

/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "/components/Units.js" as Units

QuantityLabel {
	id: root

	property var dataObject

	value: dataObject == null
			? NaN
			: Global.systemSettings.energyUnit === VenusOS.Units_Energy_Amp
				&& !isNaN(dataObject.current)
			  ? dataObject.current
			  : dataObject.power
	unit: Global.systemSettings.energyUnit === VenusOS.Units_Energy_Amp
			&& dataObject != null && !isNaN(dataObject.current)
		  ? VenusOS.Units_Energy_Amp
		  : VenusOS.Units_Energy_Watt
}

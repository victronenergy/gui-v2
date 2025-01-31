/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListQuantityGroup {
	property var data

	model: QuantityObjectModel {
		QuantityObject { object: data; key: "power"; unit: VenusOS.Units_Watt }
		QuantityObject { object: data; key: "voltage"; unit: VenusOS.Units_Volt_AC }
		QuantityObject { object: data; key: "current"; unit: VenusOS.Units_Amp }
		QuantityObject { object: data; key: "frequency"; unit: VenusOS.Units_Hertz }
	}

	maximumContentWidth: availableWidth
}

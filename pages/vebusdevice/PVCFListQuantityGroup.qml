/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListQuantityGroup {
	property var data

	textModel: [
		{
			value: data.power,
			unit: VenusOS.Units_Watt
		},
		{
			value: data.voltage,
			unit: VenusOS.Units_Volt_AC
		},
		{
			value: data.current,
			unit: VenusOS.Units_Amp
		},
		{
			value: data.frequency,
			unit: VenusOS.Units_Hertz
		}
	]

	maximumContentWidth: availableWidth
}

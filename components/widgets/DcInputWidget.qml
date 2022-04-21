/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

OverviewWidget {
	id: root

	property var input

	value: input ? input.current : NaN
	physicalQuantity: Enums.Units_PhysicalQuantity_Current
}

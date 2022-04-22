/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

OverviewWidget {
	id: root

	objectName: "DcInputWidget"
	property var input

	value: input ? input.current : NaN
	physicalQuantity: VenusOS.Units_PhysicalQuantity_Current
}

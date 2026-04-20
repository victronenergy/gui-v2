/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

OverviewWidget {
	id: root

	required property int phaseCount
	property AcInput input

	preferredSize: phaseCount > 1 ? VenusOS.OverviewWidget_PreferredSize_PreferLarge : VenusOS.OverviewWidget_PreferredSize_Any
}

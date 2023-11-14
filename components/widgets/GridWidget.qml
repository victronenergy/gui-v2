/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

AcInputWidget {
	id: root

	//% "Grid"
	title: qsTrId("overview_widget_grid_title")
	icon.source: "qrc:/images/grid.svg"
	type: VenusOS.OverviewWidget_Type_Grid
}

/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

AcInputWidget {
	id: root

	//% "Grid"
	title: qsTrId("overview_widget_grid_title")
	icon.source: "qrc:/images/grid.svg"
	type: VenusOS.OverviewWidget_Type_Grid

	sideGaugeVisible: true
}

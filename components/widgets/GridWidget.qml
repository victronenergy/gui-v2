/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

AcInputWidget {
	id: root

	//% "Grid"
	title.text: qsTrId("overview_widget_grid_title")
	icon.source: "qrc:/images/grid.svg"

	sideGaugeVisible: true
}

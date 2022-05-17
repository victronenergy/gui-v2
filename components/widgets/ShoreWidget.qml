/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

AcInputWidget {
	id: root

	//% "Shore"
	title: qsTrId("overview_widget_shore_title")
	icon.source: "qrc:/images/shore.svg"
	type: VenusOS.OverviewWidget_Type_Shore

	sideGaugeVisible: true
}

/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

DcInputWidget {
	id: root

	//% "Wind"
	title.text: qsTrId("overview_widget_wind_title")
	icon.source: "qrc:/images/wind.svg"
	type: VenusOS.OverviewWidget_Type_Wind
}

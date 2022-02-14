/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

OverviewWidget {
	id: root

	//% "Wind"
	title.text: qsTrId("overview_widget_wind_title")
	icon.source: "qrc:/images/wind.svg"
}

/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

DcInputWidget {
	id: root

	//% "Wind"
	title: qsTrId("overview_widget_wind_title")
	icon.source: "qrc:/images/wind.svg"
	type: VenusOS.OverviewWidget_Type_Wind
}

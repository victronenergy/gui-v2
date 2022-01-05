/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

OverviewWidget {
	id: root

	//% "Battery"
	title.text: qsTrId("overview_widget_battery_title")
	icon.source: "qrc:/images/solaryield.svg"
}

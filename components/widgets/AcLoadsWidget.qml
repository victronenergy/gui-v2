/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

OverviewWidget {
	id: root

	//% "AC Loads"
	title.text: qsTrId("overview_widget_acloads_title")
	icon.source: "qrc:/images/solaryield.svg"
	interactive: false
}

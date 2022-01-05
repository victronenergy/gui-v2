/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

OverviewWidget {
	id: root

	//% "DC Loads"
	title.text: qsTrId("overview_widget_dcloads_title")
	icon.source: "qrc:/images/solaryield.svg"
	interactive: false
}

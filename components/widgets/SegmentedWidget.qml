/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

OverviewWidget {
	id: root

	//% "Solar yield"
	title.text: qsTrId("overview_widget_solaryield_title")
	icon.source: "qrc:/images/solaryield.svg"
}

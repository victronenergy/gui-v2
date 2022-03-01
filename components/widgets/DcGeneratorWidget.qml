/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

OverviewWidget {
	id: root

	//% "DC Generator"
	title.text: qsTrId("overview_widget_dcgenerator_title")
	icon.source: "qrc:/images/generator.svg"
}

/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

DcInputWidget {
	id: root

	//% "DC Generator"
	title: qsTrId("overview_widget_dcgenerator_title")
	icon.source: "qrc:/images/generator.svg"
	type: VenusOS.OverviewWidget_Type_DcGenerator
}

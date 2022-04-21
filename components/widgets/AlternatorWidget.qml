/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

DcInputWidget {
	id: root

	//% "Alternator"
	title.text: qsTrId("overview_widget_alternator_title")
	icon.source: "qrc:/images/alternator.svg"
	type: VenusOS.OverviewWidget_Type_Alternator
}

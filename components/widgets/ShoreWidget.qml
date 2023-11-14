/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

AcInputWidget {
	id: root

	//% "Shore"
	title: qsTrId("overview_widget_shore_title")
	icon.source: "qrc:/images/shore.svg"
	type: VenusOS.OverviewWidget_Type_Shore
}

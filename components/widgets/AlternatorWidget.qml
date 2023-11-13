/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

DcInputWidget {
	id: root

	icon.source: "qrc:/images/alternator.svg"
	type: VenusOS.OverviewWidget_Type_Alternator
	detailUrl: "/pages/settings/devicelist/dc-in/PageAlternator.qml"
}

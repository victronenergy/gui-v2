/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import Victron.VenusOS

DcInputWidget {
	id: root

	icon.source: "qrc:/images/alternator.svg"
	type: Enums.OverviewWidget_Type_Alternator
	detailUrl: "/pages/settings/devicelist/dc-in/PageAlternator.qml"
}

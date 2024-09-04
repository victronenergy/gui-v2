/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

DcInputWidget {
	id: root

	icon.source: "qrc:/images/generator.svg"
	type: VenusOS.OverviewWidget_Type_DcGenerator
	detailUrl: "/pages/settings/devicelist/PageGenset.qml"
}

/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

OverviewWidget {
	id: root

	onClicked: {
		Global.pageManager.pushPage(root.detailUrl, {
			"title": root.input.name,
			"bindPrefix": root.input.serviceUid
		})
	}

	property var input
	property string detailUrl: "/pages/settings/devicelist/dc-in/PageDcMeter.qml"

	title: input ? Global.dcInputs.inputTypeToText(Global.dcInputs.inputType(input.serviceUid, input.monitorMode)) : ""
	quantityLabel.dataObject: input
	icon.source: "qrc:/images/icon_dc_24.svg"
	enabled: true
}

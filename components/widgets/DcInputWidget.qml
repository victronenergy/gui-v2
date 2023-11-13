/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

OverviewWidget {
	id: root

	property var input

	title: input ? Global.dcInputs.inputTypeToText(Global.dcInputs.inputType(input.serviceType, input.monitorMode)) : ""
	quantityLabel.dataObject: input
	icon.source: "qrc:/images/icon_dc_24.svg"
}

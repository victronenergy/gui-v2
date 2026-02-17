/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

IOChannelCardDelegateHeader {
	id: root

	required property GenericInput genericInput

	formattedName: genericInput.formattedName
	statusText: VenusOS.genericInput_statusToText(genericInput.status)
	statusVisible: genericInput.status !== VenusOS.GenericInput_Status_On
	statusColor: {
		switch (root.genericInput.status) {
		case VenusOS.GenericInput_Status_Fault:
			return Theme.color_red
		case VenusOS.GenericInput_Type_SensorBatteryLow:
			return Theme.color_orange
		default:
			return Theme.color_red
		}
	}
}

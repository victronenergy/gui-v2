/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import Victron.VenusOS

IOChannelCardDelegateHeader {
	id: root

	required property SwitchableOutput switchableOutput

	formattedName: switchableOutput.formattedName
	statusText: VenusOS.switchableOutput_statusToText(switchableOutput.status, switchableOutput.type)
	statusVisible: !(switchableOutput.status === VenusOS.SwitchableOutput_Status_Off
			|| switchableOutput.status === VenusOS.SwitchableOutput_Status_On
			|| switchableOutput.status === VenusOS.SwitchableOutput_Status_Powered)
	statusColor: {
		switch (root.switchableOutput.status) {
		case VenusOS.SwitchableOutput_Status_Off:
			return Theme.color_font_secondary
		case VenusOS.SwitchableOutput_Status_Powered:
			return Theme.color_green
		case VenusOS.SwitchableOutput_Status_On:
			if (root.switchableOutput.type === VenusOS.SwitchableOutput_Type_BilgePump) {
				// A running Bilge Pump is not a normal state, so use a warning colour.
				return Theme.color_orange
			} else {
				return Theme.color_green
			}
		case VenusOS.SwitchableOutput_Status_ExternalControl:
			return Theme.color_green
		case VenusOS.SwitchableOutput_Status_OutputFault:
		case VenusOS.SwitchableOutput_Status_Bypassed:
		case VenusOS.SwitchableOutput_Status_Disabled_On:
			return Theme.color_orange
		case VenusOS.SwitchableOutput_Status_Tripped:
		case VenusOS.SwitchableOutput_Status_OverTemperature:
		case VenusOS.SwitchableOutput_Status_OverTemperature_Tripped:
		case VenusOS.SwitchableOutput_Status_ShortFault:
		case VenusOS.SwitchableOutput_Status_Disabled:
		case VenusOS.SwitchableOutput_Status_Disabled_Tripped:
		case VenusOS.SwitchableOutput_Status_Disabled_OverTemperature:
		case VenusOS.SwitchableOutput_Status_Bypassed_Tripped:
		case VenusOS.SwitchableOutput_Status_Bypassed_OverTemperature:
		case VenusOS.SwitchableOutput_Status_ExternalControl_Tripped:
		case VenusOS.SwitchableOutput_Status_ExternalControl_OverTemperature:
			return Theme.color_red
		default:
			return Theme.color_red
		}
	}
}

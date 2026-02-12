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
		// Mask the 'output on' bit so that if any error bit is set (e.g. over temperature,
		// disabled) the background will be red, even if the output is on.
		// Don't do this for Bilge Pump as they have special status handling.
		const maskedValue = root.switchableOutput.type === VenusOS.SwitchableOutput_Type_BilgePump
						  ? root.switchableOutput.status
						  : root.switchableOutput.status &~ VenusOS.SwitchableOutput_Status_On
		switch (maskedValue) {
		case VenusOS.SwitchableOutput_Status_Off:
			return Theme.color_font_secondary
		case VenusOS.SwitchableOutput_Status_Powered:
			return Theme.color_green
		case VenusOS.SwitchableOutput_Status_On:
			if (root.switchableOutput.type === VenusOS.SwitchableOutput_Type_BilgePump) {
				break
			}
			return Theme.color_green
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
			break
		}

		// For Bilge Pumps: a running Bilge Pump is not a normal state, so use a warning
		// colour, unless it is a known error state, and in that case use red instead.
		if (root.switchableOutput.type === VenusOS.SwitchableOutput_Type_BilgePump
				&& (root.switchableOutput.status & VenusOS.SwitchableOutput_Status_On)) {
			if ((root.switchableOutput.status & VenusOS.SwitchableOutput_Status_OverTemperature)
				|| (root.switchableOutput.status & VenusOS.SwitchableOutput_Status_Disabled)) {
				return Theme.color_red
			} else {
				return Theme.color_orange
			}
		}
		return Theme.color_red
	}
}

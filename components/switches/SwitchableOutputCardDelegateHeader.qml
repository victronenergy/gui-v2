/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import Victron.VenusOS

RowLayout {
	id: root

	required property SwitchableOutput switchableOutput
	property string secondaryTitle
	property bool statusVisible: !(switchableOutput.status === VenusOS.SwitchableOutput_Status_Off
			|| switchableOutput.status === VenusOS.SwitchableOutput_Status_On
			|| switchableOutput.status === VenusOS.SwitchableOutput_Status_Powered)

	Label {
		id: nameLabel
		Layout.fillWidth: true
		Layout.alignment: Qt.AlignBaseline
		bottomPadding: Theme.geometry_switchableoutput_label_margin
		rightPadding: Theme.geometry_switchableoutput_label_margin
		text: root.switchableOutput.formattedName
		elide: Text.ElideMiddle // don't elide right, as it may obscure a trailing channel id
	}

	Label {
		id: secondaryTitleLabel
		Layout.alignment: Qt.AlignBaseline
		bottomPadding: Theme.geometry_switchableoutput_label_margin
		text: root.secondaryTitle
		font.pixelSize: Theme.font_size_body2
	}

	Rectangle {
		id: statusRect

		Layout.bottomMargin: Theme.geometry_switchableoutput_label_margin
		Layout.maximumWidth: parent.width / 2
		Layout.minimumWidth: statusLabel.implicitWidth
		Layout.alignment: Qt.AlignRight
		height: statusLabel.height
		color: statusLabel.color === Theme.color_green ? Theme.color_darkGreen
				: statusLabel.color === Theme.color_orange ? Theme.color_darkOrange
				: statusLabel.color === Theme.color_red ? Theme.color_darkRed
				: Theme.color_switch_status_disabled
		radius: Theme.geometry_switchableoutput_status_radius
		visible: root.statusVisible

		Label {
			id: statusLabel

			anchors.centerIn: parent
			text: VenusOS.switchableOutput_statusToText(root.switchableOutput.status, root.switchableOutput.type)
			width: parent.width
			topPadding: Theme.geometry_switchableoutput_status_verticalPadding
			bottomPadding: Theme.geometry_switchableoutput_status_verticalPadding
			leftPadding: Theme.geometry_switchableoutput_status_horizontalPadding
			rightPadding: Theme.geometry_switchableoutput_status_horizontalPadding
			horizontalAlignment: Text.AlignHCenter
			elide: Text.ElideRight
			font.pixelSize: Theme.font_size_tiny

			color: {
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
	}
}

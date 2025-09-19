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

	Label {
		id: nameLabel
		Layout.fillWidth: true
		bottomPadding: Theme.geometry_switchableoutput_label_margin
		rightPadding: Theme.geometry_switchableoutput_label_margin
		text: root.switchableOutput.formattedName
		elide: Text.ElideMiddle // don't elide right, as it may obscure a trailing channel id
	}

	Label {
		id: secondaryTitleLabel
		bottomPadding: Theme.geometry_switchableoutput_label_margin
		text: root.secondaryTitle
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
		visible: !(switchableOutput.status === VenusOS.SwitchableOutput_Status_Off
				   || switchableOutput.status === VenusOS.SwitchableOutput_Status_On
				   || switchableOutput.status === VenusOS.SwitchableOutput_Status_Powered)

		Label {
			id: statusLabel

			anchors.centerIn: parent
			text: VenusOS.switchableOutput_statusToText(root.switchableOutput.status)
			width: parent.width
			topPadding: Theme.geometry_switchableoutput_status_verticalPadding
			bottomPadding: Theme.geometry_switchableoutput_status_verticalPadding
			leftPadding: Theme.geometry_switchableoutput_status_horizontalPadding
			rightPadding: Theme.geometry_switchableoutput_status_horizontalPadding
			horizontalAlignment: Text.AlignHCenter
			elide: Text.ElideRight
			font.pixelSize: Theme.font_size_tiny
			color: {
				switch (root.switchableOutput.status) {
				case VenusOS.SwitchableOutput_Status_Off:
					return Theme.color_font_secondary
				case VenusOS.SwitchableOutput_Status_Powered:
				case VenusOS.SwitchableOutput_Status_On:
					return Theme.color_green
				case VenusOS.SwitchableOutput_Status_Output_Fault:
					return Theme.color_orange
				case VenusOS.SwitchableOutput_Status_Disabled:
				case VenusOS.SwitchableOutput_Status_TripLowVoltage:
				case VenusOS.SwitchableOutput_Status_Over_Temperature:
				case VenusOS.SwitchableOutput_Status_Short_Fault:
				case VenusOS.SwitchableOutput_Status_Tripped:
					return Theme.color_red
				default:
					return Theme.color_red
				}
			}
		}
	}
}

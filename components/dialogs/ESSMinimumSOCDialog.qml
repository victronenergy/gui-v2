/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ModalDialog {
	id: root

	property int minimumStateOfCharge

	onAboutToShow: {
		minimumStateOfCharge = Global.ess.minimumStateOfCharge
	}

	onAccepted: {
		Global.ess.setMinimumStateOfChargeRequested(minimumStateOfCharge)
	}

	//% "Minimum SOC"
	title: qsTrId("ess_card_minimum_soc")

	contentItem: Item {
		Column {
			width: parent.width

			Label {
				anchors.horizontalCenter: parent.horizontalCenter
				font.pixelSize: Theme.font_size_h3
				text: qsTrId("%1%").arg(root.minimumStateOfCharge)
			}

			Label {
				anchors.horizontalCenter: parent.horizontalCenter
				color: Theme.color_font_secondary
				//: Shown below the minimum state of charge, as configured by the user
				//% "Unless grid fails"
				text: qsTrId("ess_unless_grid_fails")
			}

			Item {
				width: 1
				height: Theme.geometry_modalDialog_content_margins / 2
			}

			Slider {
				focus: true
				anchors.horizontalCenter: parent.horizontalCenter
				width: parent.width - (2 * Theme.geometry_modalDialog_content_horizontalMargin)
				value: root.minimumStateOfCharge
				from: 0
				to: 100
				stepSize: 1
				onValueChanged: root.minimumStateOfCharge = value
			}

			Item {
				width: 1
				height: Theme.geometry_modalDialog_content_margins
			}

			Label {
				anchors.horizontalCenter: parent.horizontalCenter
				width: parent.width - (2 * Theme.geometry_page_content_horizontalMargin)
				wrapMode: Text.Wrap
				color: Theme.color_font_secondary
				horizontalAlignment: Text.AlignHCenter
				font.pixelSize: Theme.font_size_caption

				//% "For Lithium batteries, below 10% charge is not recommended. For other battery types, check the datasheet for the minimum level recommended by the manufacturer."
				text: qsTrId("ess_recommended")
			}
		}
	}
}

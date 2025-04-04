/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ModalDialog {
	id: root

	property int minimumStateOfCharge

	//% "Minimum SOC"
	title: qsTrId("ess_card_minimum_soc")

	contentItem: ModalDialog.FocusableContentItem {
		Column {
			width: parent.width

			Label {
				anchors.horizontalCenter: parent.horizontalCenter
				font.pixelSize: Theme.font_size_h3
				text: "%1%".arg(root.minimumStateOfCharge)
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
				anchors.horizontalCenter: parent.horizontalCenter
				width: parent.width - (2 * Theme.geometry_modalDialog_content_horizontalMargin)
				value: root.minimumStateOfCharge
				from: 0
				to: 100
				stepSize: 1
				focus: true
				onMoved: root.minimumStateOfCharge = value

				KeyNavigationHighlight {
					anchors {
						fill: parent
						leftMargin: -Theme.geometry_listItem_flat_content_horizontalMargin
						rightMargin: -Theme.geometry_listItem_flat_content_horizontalMargin
						topMargin: -Theme.geometry_listItem_content_verticalMargin
						bottomMargin: -Theme.geometry_listItem_content_verticalMargin
					}
					active: parent.activeFocus
				}
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

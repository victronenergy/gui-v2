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
		implicitHeight: contentColumn.height

		Column {
			id: contentColumn
			x: Theme.geometry_modalDialog_content_horizontalMargin
			width: parent.width - (2 * Theme.geometry_modalDialog_content_horizontalMargin)
			bottomPadding: Theme.geometry_modalDialog_content_spacing

			Label {
				anchors.horizontalCenter: parent.horizontalCenter
				font.pixelSize: Theme.font_dialog_control_largeSize
				text: "%1%".arg(root.minimumStateOfCharge)
			}

			Label {
				anchors.horizontalCenter: parent.horizontalCenter
				color: Theme.color_font_secondary
				bottomPadding: Theme.geometry_modalDialog_content_spacing
				//: Shown below the minimum state of charge, as configured by the user
				//% "Unless grid fails"
				text: qsTrId("ess_unless_grid_fails")
			}

			Slider {
				id: slider

				anchors.horizontalCenter: parent.horizontalCenter
				width: parent.width - (2 * Theme.geometry_modalDialog_content_spacing)
				value: root.minimumStateOfCharge
				from: 0
				to: 100
				stepSize: 5
				focus: true
				onMoved: root.minimumStateOfCharge = value

				KeyNavigationHighlight.active: slider.activeFocus
				KeyNavigationHighlight.leftMargin: -Theme.geometry_listItem_flat_content_horizontalMargin
				KeyNavigationHighlight.rightMargin: -Theme.geometry_listItem_flat_content_horizontalMargin
				KeyNavigationHighlight.topMargin: -Theme.geometry_listItem_content_verticalMargin
				KeyNavigationHighlight.bottomMargin: -Theme.geometry_listItem_content_verticalMargin
			}

			Label {
				anchors.horizontalCenter: parent.horizontalCenter
				width: parent.width - (2 * Theme.geometry_page_content_horizontalMargin)
				topPadding: Theme.geometry_modalDialog_content_spacing
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

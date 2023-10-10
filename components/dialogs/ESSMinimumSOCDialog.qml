/*
** Copyright (C) 2021 Victron Energy B.V.
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
				font.pixelSize: Theme.font.size.h3
				text: qsTrId("%1%").arg(root.minimumStateOfCharge)
			}

			Label {
				anchors.horizontalCenter: parent.horizontalCenter
				color: Theme.color.font.secondary
				//: Shown below the minimum state of charge, as configured by the user
				//% "Unless grid fails"
				text: qsTrId("ess_unless_grid_fails")
			}

			Item {
				width: 1
				height: Theme.geometry.modalDialog.content.margins / 2
			}

			Slider {
				anchors.horizontalCenter: parent.horizontalCenter
				width: parent.width - (2 * Theme.geometry.modalDialog.content.horizontalMargin)
				value: root.minimumStateOfCharge
				from: 0
				to: 100
				onMoved: root.minimumStateOfCharge = value
			}

			Item {
				width: 1
				height: Theme.geometry.modalDialog.content.margins
			}

			Label {
				anchors.horizontalCenter: parent.horizontalCenter
				width: parent.width - (2 * Theme.geometry.page.content.horizontalMargin)
				wrapMode: Text.Wrap
				color: Theme.color.font.secondary
				horizontalAlignment: Text.AlignHCenter
				font.pixelSize: Theme.font.size.caption

				//% "For Lithium batteries, below 10% is not recommended. For other battery types, check the datasheet for the manufacturer recommended minimum."
				text: qsTrId("ess_recommended")
			}
		}
	}
}

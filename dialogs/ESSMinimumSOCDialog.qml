/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

ModalDialog {
	id: root

	property int minimumStateOfCharge

	//% "Minimum SOC"
	title: qsTrId("ess_card_minimum_soc")

	contentItem: Item {
		width: parent.width
		Label {
			id: label

			anchors {
				top: parent.top
				topMargin: 27
				horizontalCenter: parent.horizontalCenter
			}
			font.pixelSize: Theme.font.size.xxl
			text: qsTrId("%1%").arg(root.minimumStateOfCharge)
		}
		Label {
			id: label2

			anchors {
				top: label.bottom
				horizontalCenter: parent.horizontalCenter
			}
			color: Theme.color.font.secondary
			//% "Unless grid fails"
			text: qsTrId("ess_unless_grid_fails")
		}
		Slider {
			id: slider

			anchors {
				top: label2.bottom
				topMargin: 19
				horizontalCenter: parent.horizontalCenter
			}
			from: 0
			to: 100
			width: parent.width - 128
			height: 24
			value: root.minimumStateOfCharge
			onMoved: root.minimumStateOfCharge = value
		}
		Label {
			id: recommendation

			anchors {
				top: slider.bottom
				topMargin: 31
				horizontalCenter: parent.horizontalCenter
			}
			color: Theme.color.font.secondary
			// TODO set this text depending on battery type?
			//% "For xxx type batteries, below 10% is not recommended"
			text: qsTrId("ess_recommended")
		}
	}
}

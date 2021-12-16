/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

ModalDialog {
	id: root

	property int newMinimumSOC

	signal setMinimumSOC(var newValue)

	//% "Minimum SOC"
	titleText: qsTrId("ess_card_minimum_soc")

	contentItem: Item {
		width: parent.width
		Label {
			id: label

			anchors {
				top: parent.top
				topMargin: 27
				horizontalCenter: parent.horizontalCenter
			}
			font.pixelSize: Theme.fontSizeXXL
			text: qsTrId("%1%").arg(root.newMinimumSOC)
		}
		Label {
			id: label2

			anchors {
				top: label.bottom
				horizontalCenter: parent.horizontalCenter
			}
			color: Theme.weatherColor
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
			value: newMinimumSOC
			onMoved: newMinimumSOC = value
		}
		Label {
			id: recommendation

			anchors {
				top: slider.bottom
				topMargin: 31
				horizontalCenter: parent.horizontalCenter
			}
			color: Theme.weatherColor
			//% "For xxx type batteries, below 10% is not recommended"
			text: qsTrId("ess_recommended")
		}
	}

	onAccepted: root.setMinimumSOC(newMinimumSOC)
}
